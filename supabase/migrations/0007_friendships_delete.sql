-- 0007_friendships_delete.sql
-- Migration 0003 created the friendships table with SELECT / INSERT / UPDATE
-- policies but no DELETE policy. We need DELETE so that:
--
--   * An addressee can decline a pending request (removes the row).
--   * A requester can cancel an outbound pending request.
--   * Either party can unfriend an accepted friendship.
--
-- The `blocked` status stays as an explicit UPDATE, not a delete.

drop policy if exists "friendships_delete_own" on public.friendships;

create policy "friendships_delete_own"
  on public.friendships for delete
  using (auth.uid() in (requester_id, addressee_id));

-- Friendships were not originally wired to Supabase Realtime. Add them so
-- the UI on each client updates live when the other party accepts, declines,
-- or cancels.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'friendships'
  ) then
    alter publication supabase_realtime add table public.friendships;
  end if;
end $$;
