-- 0011_room_cap.sql
-- Plug two gaps that let estimation_players grow past a room's player_count.
--
-- Gap 1: estimation_players had unique(game_id, seat) and unique(game_id,
--        player_id), plus a static check (seat between 0 and 3), but no
--        per-room cap. A row with seat=2 in a player_count=2 room slipped
--        in (most likely from a stale-client race or a double-join after a
--        flaky leave), giving the lobby a "3 / 2" header and the start-game
--        Dart guard a "Bad state: cannot start game: 2 seat(s) required, 3
--        present" exception with no way to recover from inside the app.
--
-- Gap 2: estimation_games_enforce_full_room (0010) used `seat_count <
--        player_count`, so it only blocks UNDER-full starts. Over-full rooms
--        slipped past the trigger and were caught by the Dart-side check
--        only — useless if a stale client races the host's tap.
--
-- Forward-fix only. Existing phantom rows must be cleaned up manually in
-- Supabase Studio (filter estimation_players by the affected game_id and
-- delete the row whose seat >= player_count or whose player_id is a
-- duplicate).

-- ── 1. Per-row cap on estimation_players inserts ──────────────────────────

create or replace function public.estimation_players_enforce_room_cap()
returns trigger
language plpgsql
as $$
declare
  cap int;
  current_count int;
begin
  select player_count into cap
  from public.estimation_games
  where id = NEW.game_id;

  -- No game found — let the foreign-key constraint produce the real error.
  if cap is null then
    return NEW;
  end if;

  if NEW.seat < 0 or NEW.seat >= cap then
    raise exception
      'invalid seat %: room has % seat(s) (valid range 0..%)',
      NEW.seat, cap, cap - 1
      using errcode = 'check_violation';
  end if;

  select count(*) into current_count
  from public.estimation_players
  where game_id = NEW.game_id;

  if current_count >= cap then
    raise exception
      'room is full: % seat(s) already taken (cap %)',
      current_count, cap
      using errcode = 'check_violation';
  end if;

  return NEW;
end;
$$;

drop trigger if exists estimation_players_enforce_room_cap
  on public.estimation_players;

create trigger estimation_players_enforce_room_cap
  before insert on public.estimation_players
  for each row
  execute function public.estimation_players_enforce_room_cap();

-- ── 2. Tighten 0010's start-game guard from `<` to `<>` ───────────────────

create or replace function public.estimation_games_enforce_full_room()
returns trigger
language plpgsql
as $$
declare
  seat_count int;
begin
  if NEW.status = 'active' and OLD.status is distinct from 'active' then
    select count(*) into seat_count
    from public.estimation_players
    where game_id = NEW.id;

    if seat_count <> NEW.player_count then
      raise exception
        'cannot start game: % seat(s) filled, % required',
        seat_count, NEW.player_count
        using errcode = 'check_violation';
    end if;
  end if;
  return NEW;
end;
$$;
