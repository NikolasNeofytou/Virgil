-- 0013_dev_skip_to_end.sql
-- DEV-ONLY helper: fast-forward an estimation game straight to the finish
-- screen for two-sim testing of the GameOverPanel (laurel reveal,
-- narration, awards, share PNG, moments) without playing all 14 rounds.
--
-- The client equivalent is gated on `kDebugMode`, but client-side mutations
-- run into the `estimation_players_update_self` RLS policy: only one
-- player's `total_score` can be bumped per call. This RPC runs as
-- SECURITY DEFINER so all peer rows can be updated in one transaction.
--
-- Caller must be a participant in the target game. The function is
-- otherwise destructive (overwrites prediction/actual_tricks/score for
-- every round from current_round onward), so we keep it labelled `dev_`
-- as a soft signal that release builds shouldn't expose it.

create or replace function public.dev_skip_estimation_game_to_end(
  p_game_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_caller         uuid := auth.uid();
  v_current_round  int;
  v_total_rounds   int;
  v_max_cards      int;
  v_status         text;
  v_winner_id      uuid;
  v_player         record;
  v_round          int;
  v_cards          int;
  v_actual         int;
  v_score          int;
  v_score_delta    int;
begin
  if v_caller is null then
    raise exception 'dev_skip: not authenticated' using errcode = '42501';
  end if;

  -- Caller must be a participant in this game.
  if not exists (
    select 1 from public.estimation_players ep
    where ep.game_id = p_game_id and ep.player_id = v_caller
  ) then
    raise exception 'dev_skip: caller is not a participant of game %',
      p_game_id using errcode = '42501';
  end if;

  select current_round, total_rounds, max_cards, status
    into v_current_round, v_total_rounds, v_max_cards, v_status
    from public.estimation_games
    where id = p_game_id
    for update;

  if v_status = 'finished' then
    return;
  end if;

  -- Seat-0 player is the chosen "winner" — takes every trick from
  -- current_round onward; everyone bids exactly what they end up with so
  -- all players collect the +10 bonus each round.
  for v_player in
    select player_id, seat
      from public.estimation_players
      where game_id = p_game_id
      order by seat
  loop
    v_score_delta := 0;
    for v_round in v_current_round .. v_total_rounds loop
      if v_round <= v_max_cards then
        v_cards := v_round;
      else
        v_cards := 2 * v_max_cards - v_round + 1;
      end if;
      v_actual := case when v_player.seat = 0 then v_cards else 0 end;
      v_score  := v_actual + 10; -- prediction == actual → +10 bonus

      insert into public.estimation_rounds
        (game_id, player_id, round_number, cards_this_round,
         prediction, actual_tricks, score, validated)
      values
        (p_game_id, v_player.player_id, v_round, v_cards,
         v_actual, v_actual, v_score, true)
      on conflict (game_id, player_id, round_number)
      do update set
        cards_this_round = excluded.cards_this_round,
        prediction       = excluded.prediction,
        actual_tricks    = excluded.actual_tricks,
        score            = excluded.score,
        validated        = excluded.validated;

      v_score_delta := v_score_delta + v_score;
    end loop;

    update public.estimation_players
      set total_score = total_score + v_score_delta
      where game_id = p_game_id and player_id = v_player.player_id;

    if v_player.seat = 0 then
      v_winner_id := v_player.player_id;
    end if;
  end loop;

  update public.estimation_games
    set status           = 'finished',
        phase            = 'validating',
        current_round    = v_total_rounds,
        ended_at         = now(),
        winner_player_id = v_winner_id
    where id = p_game_id;
end;
$$;

comment on function public.dev_skip_estimation_game_to_end(uuid) is
  'DEV-ONLY: fast-forwards the given estimation game to the finish screen. '
  'Bypasses RLS via SECURITY DEFINER so peer total_score updates land in '
  'a single transaction. Caller must be a participant. Surfaced from the '
  'Flutter app behind a kDebugMode-gated AppBar action.';

-- Authenticated participants only; we re-check participant membership
-- inside the function body.
revoke all on function public.dev_skip_estimation_game_to_end(uuid) from public;
grant execute on function public.dev_skip_estimation_game_to_end(uuid)
  to authenticated;
