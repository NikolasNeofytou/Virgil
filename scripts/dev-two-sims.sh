#!/usr/bin/env bash
#
# dev-two-sims.sh — start local Supabase and run Virgil on two iOS
# simulators in parallel. Useful for testing multiplayer flows locally
# (lobby join, sequential bidding, per-trick confirmations, game-over
# narration with multiple players, etc.).
#
# Usage:  scripts/dev-two-sims.sh
#
# Idempotent: safe to re-run. Skips supabase start if already up; skips
# simctl boot for already-booted simulators.
#
# Stop with:
#   q in each Terminal tab → quits flutter run
#   supabase stop          → halts the backend (from repo root)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$REPO_ROOT/app"

# Pick two simulators. Adjust if you don't have these installed
# (run `xcrun simctl list devices available | grep iPhone` to see options).
SIM_A_NAME="iPhone 16 Pro"
SIM_B_NAME="iPhone 16 Plus"

# ── helpers ────────────────────────────────────────────────────────────────

# Resolves a simulator name to its UDID via simctl JSON output. Exits 1
# (caller handles) when the named sim doesn't exist on this Mac.
get_sim_udid() {
  local name="$1"
  xcrun simctl list devices available -j 2>/dev/null \
    | python3 -c "
import json, sys
name = '$name'
data = json.load(sys.stdin)
for devices in data['devices'].values():
    for d in devices:
        if d['name'] == name and d['isAvailable']:
            print(d['udid']); sys.exit(0)
sys.exit(1)
" 2>/dev/null
}

abort_missing_sim() {
  local name="$1"
  echo "✗ Simulator '$name' not found. Available iPhone simulators:" >&2
  xcrun simctl list devices available | grep -E "iPhone .* \(" | sed 's/^/    /' >&2
  echo "  Edit SIM_A_NAME / SIM_B_NAME in $0 to use ones you have." >&2
  exit 1
}

# ── 1. Supabase ────────────────────────────────────────────────────────────

cd "$REPO_ROOT"
if supabase status >/dev/null 2>&1; then
  echo "✓ Supabase already running"
else
  echo "→ Starting Supabase (first start can take ~1 min while Docker pulls images)..."
  supabase start
fi

# Apply any pending migrations. `supabase start` resumes the DB from a
# snapshot and does NOT run migrations newer than that snapshot — pulling
# a branch with new RPCs would otherwise leave the local DB stale and
# callers fail with "function does not exist". Idempotent: prints "up to
# date" when there's nothing to apply.
echo "→ Applying any pending migrations..."
supabase migration up --local

# ── 2. Mailpit (magic-link inbox) ──────────────────────────────────────────
# Opens the local email viewer where Supabase delivers OTP / magic-link
# emails. Same URL re-opened in an existing tab just focuses it.

echo "→ Opening Mailpit (magic-link inbox) in browser"
open "http://127.0.0.1:54324"

# ── 3. Simulators ──────────────────────────────────────────────────────────

ID_A=$(get_sim_udid "$SIM_A_NAME") || abort_missing_sim "$SIM_A_NAME"
ID_B=$(get_sim_udid "$SIM_B_NAME") || abort_missing_sim "$SIM_B_NAME"

echo "→ Booting $SIM_A_NAME ($ID_A)"
xcrun simctl boot "$ID_A" 2>/dev/null || true   # already-booted error: ignore
echo "→ Booting $SIM_B_NAME ($ID_B)"
xcrun simctl boot "$ID_B" 2>/dev/null || true
open -a Simulator

# ── 4. Two flutter run sessions in Terminal tabs ───────────────────────────

echo "→ Launching flutter run in two Terminal tabs..."
osascript <<APPLESCRIPT >/dev/null
tell application "Terminal"
  activate
  do script "cd '$APP_DIR' && flutter run --dart-define-from-file=.env -d $ID_A"
  delay 2
  do script "cd '$APP_DIR' && flutter run --dart-define-from-file=.env -d $ID_B"
end tell
APPLESCRIPT

cat <<EOF

✓ Setup complete.

  Backend (local Supabase):
    Studio:   http://127.0.0.1:54323
    Mailpit:  http://127.0.0.1:54324   (magic-link emails land here)
    API:      http://127.0.0.1:54321

  Simulators:
    A: $SIM_A_NAME
    B: $SIM_B_NAME

  Two flutter sessions are launching in separate Terminal tabs (look at
  Terminal.app — first build per simulator takes ~30s, subsequent hot
  reloads are instant).

  Stop everything:
    q in each Terminal tab        (quits each flutter run)
    supabase stop                  (from $REPO_ROOT)

EOF
