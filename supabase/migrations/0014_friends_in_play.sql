-- 0014_friends_in_play.sql
-- "Quiet presence" RPC powering the Lobby's `§ 03 · ΠΑΡΕΑ · IN PLAY` strip.
--
-- Why an RPC instead of a plain SELECT: the existing
-- `estimation_players_select_participants` RLS policy (0002) restricts
-- visibility to participants of the same game. That is the right default —
-- strangers must not be able to probe "is X currently in a room?" — but it
-- also means the client cannot ask the same question about its accepted
-- friends.
--
-- This SECURITY DEFINER function bypasses RLS and re-enforces the privacy
-- boundary internally: the result is filtered to friends of `auth.uid()`
-- whose friendship row has status 'accepted'. Strangers and pending
-- requesters get nothing.

create or replace function public.friends_in_play()
returns table (
  friend_id   uuid,
  username    text,
  game_id     uuid,
  room_code   text,
  game_status text
)
language sql
security definer
set search_path = public
stable
as $$
  with my_friends as (
    select case
             when f.requester_id = auth.uid() then f.addressee_id
             else f.requester_id
           end as fid
    from public.friendships f
    where f.status = 'accepted'
      and (f.requester_id = auth.uid() or f.addressee_id = auth.uid())
  )
  select
    ep.player_id  as friend_id,
    p.username    as username,
    eg.id         as game_id,
    eg.room_code  as room_code,
    eg.status     as game_status
  from public.estimation_players ep
  join public.estimation_games eg on eg.id = ep.game_id
  join public.players p           on p.id = ep.player_id
  join my_friends mf              on mf.fid = ep.player_id
  where eg.status in ('waiting', 'active')
  order by ep.joined_at desc;
$$;

comment on function public.friends_in_play() is
  'Returns the caller''s accepted friends who are currently in a waiting '
  'or active estimation game, with their username, game_id, room_code, '
  'and game status. SECURITY DEFINER bypasses the participants-only RLS '
  'on estimation_players / estimation_games; the friendship check is '
  'enforced inside the function so non-friends cannot probe.';

revoke all    on function public.friends_in_play() from public;
grant execute on function public.friends_in_play() to authenticated;
