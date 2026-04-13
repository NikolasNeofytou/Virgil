# Supabase

Supabase project for Tichu Cyprus — auth, database, realtime, storage.

## Layout

```
migrations/    Timestamped SQL migrations (source of truth for schema)
seed.sql       Development seed data
functions/     Edge Functions (TypeScript, Deno runtime)
config.toml    Local Supabase CLI config (checked in)
```

## Migrations

Numbered in execution order. Created via `supabase migration new <name>`.

| # | File | What |
|---|------|------|
| 0001 | `0001_players.sql` | Shared `players` table (auth identity + profile) |
| 0002 | `0002_estimation.sql` | Phase A: `estimation_games`, `estimation_players`, `estimation_rounds` |
| 0003 | `0003_tichu.sql` | Phase B: `games`, `game_players`, `rounds`, `tichu_calls`, `round_logs`, `friendships`, `elo_history` |

## Local Development

```bash
supabase start        # spin up local postgres + studio + auth
supabase db reset     # apply all migrations + seed
supabase db diff      # preview schema changes
```

## Production

Linked via `supabase link --project-ref <ref>`. Migrations applied with `supabase db push`.
