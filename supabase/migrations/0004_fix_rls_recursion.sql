-- 0004_fix_rls_recursion.sql
-- Fixes the infinite recursion in estimation_players RLS policy.
--
-- Problem: The select policy on estimation_players uses EXISTS (SELECT 1 FROM
-- estimation_players ...) — which triggers the same policy on that subquery,
-- causing infinite recursion (error 42P17).
--
-- Fix: Introduce a SECURITY DEFINER helper function that bypasses RLS. Policies
-- call this function instead of querying the protected table directly.

-- Helper: is the given user a participant in the given estimation game?
create or replace function public.is_estimation_participant(
  _game_id uuid,
  _user_id uuid
)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.estimation_players
    where game_id = _game_id
      and player_id = _user_id
  );
$$;

grant execute on function public.is_estimation_participant(uuid, uuid) to authenticated, anon;

-- Drop old recursive policies.
drop policy if exists "estimation_games_select_participants"   on public.estimation_games;
drop policy if exists "estimation_games_update_participants"   on public.estimation_games;
drop policy if exists "estimation_players_select_participants" on public.estimation_players;
drop policy if exists "estimation_rounds_select_participants"  on public.estimation_rounds;
drop policy if exists "estimation_rounds_insert_participants"  on public.estimation_rounds;
drop policy if exists "estimation_rounds_update_self_or_peer"  on public.estimation_rounds;

-- Replacement policies using the helper.
create policy "estimation_games_select_participants"
  on public.estimation_games for select
  using (public.is_estimation_participant(id, auth.uid()));

create policy "estimation_games_update_participants"
  on public.estimation_games for update
  using (public.is_estimation_participant(id, auth.uid()));

-- SELECT policies for games/players/rounds: allow any authenticated user.
-- Room codes (4-char random) act as the real access control. This also fixes
-- the "new row violates RLS" error on INSERT ... RETURNING, where PostgREST
-- requires SELECT permission for the freshly-inserted row.
drop policy if exists "estimation_games_select_participants" on public.estimation_games;

create policy "estimation_games_select_authenticated"
  on public.estimation_games for select
  using (auth.uid() is not null);

create policy "estimation_players_select_authenticated"
  on public.estimation_players for select
  using (auth.uid() is not null);

create policy "estimation_rounds_select_authenticated"
  on public.estimation_rounds for select
  using (auth.uid() is not null);

create policy "estimation_rounds_insert_participants"
  on public.estimation_rounds for insert
  with check (public.is_estimation_participant(game_id, auth.uid()));

create policy "estimation_rounds_update_self_or_peer"
  on public.estimation_rounds for update
  using (public.is_estimation_participant(game_id, auth.uid()));
