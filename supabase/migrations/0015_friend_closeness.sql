-- 0015_friend_closeness.sql
-- "Sort by closeness — games shared, last 30 days" from deck §05 SCREEN 03.
-- Returns one row per accepted friend (left join, so 0-shared friends are
-- still included) with the count of distinct estimation games that BOTH
-- the caller and the friend sat in over the last 30 days.
--
-- Same SECURITY DEFINER trick as 0014: the participants-only RLS on
-- estimation_players blocks asking "did X sit at table Y?" from the
-- client. The function bypasses RLS but enforces the friendship boundary
-- internally, so strangers cannot probe co-game history.
--
-- The 30-day window is by `estimation_games.created_at`. Games whose
-- status is still `waiting` count too — joining a room together is a
-- shared moment, even if the round never starts.

create or replace function public.friend_closeness()
returns table (
  friend_id     uuid,
  shared_games  int
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
  ),
  my_recent_games as (
    select ep.game_id
    from public.estimation_players ep
    join public.estimation_games eg on eg.id = ep.game_id
    where ep.player_id = auth.uid()
      and eg.created_at >= now() - interval '30 days'
  )
  select
    mf.fid as friend_id,
    coalesce(count(distinct ep2.game_id), 0)::int as shared_games
  from my_friends mf
  left join public.estimation_players ep2
         on ep2.player_id = mf.fid
        and ep2.game_id in (select game_id from my_recent_games)
  group by mf.fid;
$$;

comment on function public.friend_closeness() is
  'Per-friend count of estimation games shared with the caller in the '
  'last 30 days. Returns one row per accepted friend (zero-share friends '
  'included via left join). SECURITY DEFINER bypasses estimation_players '
  'RLS; the friendship check is enforced inside the function.';

revoke all    on function public.friend_closeness() from public;
grant execute on function public.friend_closeness() to authenticated;
