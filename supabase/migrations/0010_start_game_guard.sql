-- 0010_start_game_guard.sql
-- Refuse to flip estimation_games.status to 'active' unless every seat is
-- filled. Belt-and-suspenders alongside the lobby's disabled Start button —
-- guards against stale-client races and bad actors hitting the table directly.

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

    if seat_count < NEW.player_count then
      raise exception
        'cannot start game: % seat(s) filled, % required',
        seat_count, NEW.player_count
        using errcode = 'check_violation';
    end if;
  end if;
  return NEW;
end;
$$;

drop trigger if exists estimation_games_enforce_full_room
  on public.estimation_games;

create trigger estimation_games_enforce_full_room
  before update on public.estimation_games
  for each row
  execute function public.estimation_games_enforce_full_room();
