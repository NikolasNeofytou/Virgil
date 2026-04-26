# Team Git Workflow — Learning Note

> Written 2026-04-25 after merging the Virgil rebrand + Day 3 work into `main`. The session surfaced two big gaps in how the repo was being used. This doc is for future-me (and any teammate) so we don't repeat them.

## What actually happened today

A fast tour of the morning's confusion, because diagnosing it teaches more than the rules do.

1. I (Claude) opened a session and read `CHECKLIST.md`. It described an "A2 milestone done, Day 3 to start" world. Plausible. I started building Day 3 features.
2. Several hours and ~12 features later, the user said "the brand should be Virgil" — and I had no idea what they meant. Everything in front of me said "Tichu Cyprus".
3. `git branch -a` revealed:
   - `main` was at the old A2 commit
   - A *different* branch `claude/stupefied-bohr-fc1f72` was 7 commits ahead — Virgil rebrand, sequential bidding, friends, rematch, motion overhaul
   - The user had been working on that other branch for a week, and I hadn't checked
4. My day's work was built on the wrong base. I had to:
   - Snapshot it as a tag (`day3-snapshot`)
   - Hard-reset to the Virgil HEAD
   - Replay each feature, dropping the ones Virgil already did better
5. At end of day, even after the replay landed, **none of it was on `main`** — main had been frozen at the old A2 state since before any of this began. Neither the Virgil rebrand nor any of today's work was visible to anyone outside the worktrees.

The root cause was the same in both halves: **branches existed that nobody had merged, and the canonical-source-of-truth files (`CHECKLIST.md`, the directory the user opened in their IDE) reflected `main`, not the branches where work actually lived.**

## The two-line summary

> A branch is just a label on a commit. **A commit isn't shipped until it's on the branch your team treats as "the source of truth"** — usually `main`. Code can sit on a branch for weeks, look perfect, even pass tests, and still be invisible to everyone else until you merge.

If that's not obvious yet, the rest of this doc will not be obvious either. Re-read until it is.

## Vocabulary

| Term | What it actually is | Mental model |
|---|---|---|
| **commit** | A snapshot of every file in the repo at a moment, plus a message and a parent pointer | A polaroid of the codebase |
| **branch** | A movable label that points to one commit | A bookmark on a particular polaroid |
| **`main`** | The branch by convention treated as "released / shipped" | The current published edition |
| **`HEAD`** | A pointer to which branch you're currently on | "You are here" sticker |
| **`origin`** | The default name for the remote (GitHub) copy of the repo | The cloud backup |
| **`origin/main`** | What the remote thinks `main` looks like | What teammates would see if they looked right now |
| **worktree** | A separate folder on disk that has a different branch checked out | A second desk where you can work on a different bookmark without disturbing the first desk |
| **fast-forward merge** | Moving the `main` label forward to a commit that's a direct descendant — no merge commit needed | "Just slide the bookmark forward" |
| **merge commit** | A new commit that joins two diverging branches | "Both paths existed; here's where they reunite" |
| **rebase** | Replaying your commits on top of a different parent | "Pretend I started from over here instead" |
| **PR (pull request)** | A GitHub UI wrapper around "please merge my branch into your branch" with reviews + checks | The review request slip |

If only one term sticks: **branches are bookmarks, commits are pages**. Pages don't disappear when you change bookmarks.

## The two confusions today, in plain English

### Confusion 1 — multiple parallel branches, none merged

The repo had three branches with diverging work, and `main` was way behind both:

```
A2-milestone (87d6203) ← main was here
   │
   ├─ Virgil rebrand (1fa11f7)   ┐
   │                              │
   ├─ sequential bidding          │  Lived only on
   │                              │  claude/stupefied-bohr-fc1f72
   ├─ friends                     │
   ├─ rematch                     │
   └─ motion overhaul (99ae631)  ┘

   ├─ my Day 3 work, built on the wrong base ← claude/priceless-ritchie-ccf144
   (orphaned at 14d0b77 / day3-snapshot)
```

Nothing wrong with parallel branches — that's normal team work. **The problem was the lack of any rhythm to fold them back into `main`.** A week's worth of Virgil identity work sat there unmerged. When I came in cold, I had no signal that it existed. The README and CHECKLIST said "A2 done, Day 3 next" because that's what `main` said.

**Team rule that would have prevented this:** when a feature branch is merge-ready, merge it. Don't leave rebrand-scale work pending for a week. Either it's good enough to land, or it's not — the middle state ("done but not merged") is where confusion lives.

### Confusion 2 — code in the worktree was not on `main`

Even after I figured out the right base today, all my day's work landed on `claude/priceless-ritchie-ccf144` and *only* on that branch. The user opened the IDE at `/Users/nikolasneofytou/dev/Virgil/` — which was checked out on `main` — and saw the **old pre-Virgil placeholder leaderboard**, because main literally didn't have any of the new code.

That's confusing only if you don't realize:

> The same repo can show different files in different folders, depending on which branch each folder is checked out on. Worktrees are independent on-disk views.

**Team rule:** when work is done and reviewed, merge it to main. Don't let "main reflects branch X" drift. The remote `origin/main` is the social contract — that's what teammates clone, what CI builds, what production deploys.

## How a team should handle it (workflow recipes)

These are the patterns that work in practice. Pick one, write it down, follow it.

### Recipe A — Trunk-based (small teams, daily merges)

Every change is a short-lived branch, merged to `main` within hours or a day.

```bash
# Start a feature
git checkout main
git pull --ff-only           # always start from current main
git checkout -b feat/awards

# Work, commit
git add .
git commit -m "feat: awards calculator"

# Push for visibility (optional but common)
git push -u origin feat/awards

# When done — open a PR
gh pr create --base main --title "Awards calculator" --body "…"

# After review (or self-review for solo dev), merge through GitHub UI
# OR locally if you're solo:
git checkout main
git pull --ff-only
git merge --ff-only feat/awards   # fails loudly if not fast-forwardable
git push origin main

# Clean up
git branch -d feat/awards
git push origin --delete feat/awards
```

**Why this works:** branches are short, conflicts stay tiny, `main` always represents reality.

**Why it failed today:** branches lived for a week. Conflicts didn't appear because no one tried to merge. By the time anyone did, they'd diverged so far the merge was a manual replay job.

### Recipe B — GitFlow / long-lived branches (avoid for small teams)

`develop` accumulates work, `main` is for releases only. More ceremony than most teams need. Skip unless you have shippable releases on a calendar (App Store cadence might justify it; a solo project doesn't).

### Recipe C — Stacked PRs (advanced)

Each branch builds on the previous. Useful when you have a dependency chain — `feat/migration` → `feat/api` → `feat/ui`. Each merges in order. Tools like [Graphite](https://graphite.dev) help. Don't reach for this until trunk-based hurts.

## Hard rules that prevent today's mistakes

1. **At session start: `git fetch && git branch -a -v && git worktree list`.** Three commands, ten seconds. Tells you every branch + worktree on the machine. If anything is ahead of `main`, ask why before you write a single line of code.
2. **Never trust `CHECKLIST.md` as the only source of truth.** It's a doc; docs lag behind code. Cross-reference with `git log --all --oneline -20`.
3. **Branches that have shipped get merged within ~24 hours.** "Shipped" = tested + the author would defend it. The cost of letting it sit isn't visible — it's the *next* person not knowing it exists.
4. **`main` is the social contract.** What's on `main` is what the team agrees is real. If something feels real but isn't on `main`, that's a process bug, not a code bug. Fix it now.
5. **Merge with `--ff-only` when the branch descends from main.** The command **fails** if a merge commit would be needed — that failure means you forgot to rebase, and the failure is what saves you. Don't reach for `--no-ff` unless you've decided you want a merge bubble for traceability.
6. **For team work: branch protection on `main`.** GitHub Settings → Branches → Add rule on `main`: require PR review, require status checks, no direct pushes. That removes the foot-gun entirely — you *can't* land work without a PR, even by accident.

## Branch protection — the team-grade upgrade

If a teammate joins, do this immediately:

1. **Settings → Branches → Branch protection rules → Add `main`**
2. Tick:
   - ✅ Require a pull request before merging
   - ✅ Require approvals (1 minimum)
   - ✅ Require status checks to pass (add: `flutter analyze`, tests, build)
   - ✅ Require linear history (keeps log clean — forces rebase or squash)
   - ✅ Do not allow bypassing the above settings
3. Optionally:
   - Add CODEOWNERS so the right person gets auto-requested for review
   - Require signed commits (keeps "who did what" honest)

After that, the failure mode of today is impossible — you literally can't `git push main` from your laptop. You must open a PR, get a review, and merge through the UI.

## The one habit that prevents 80% of team git pain

**Pull main before starting anything. Push your branch when you stop for the day.**

```bash
# morning
git checkout main && git pull --ff-only
git checkout -b feat/whatever-im-doing-today

# evening, before you go home
git push -u origin feat/whatever-im-doing-today
```

That's it. Two-line discipline.

- **Pulling main first** means you're working from the team's current truth, not yesterday's.
- **Pushing every evening** means a teammate (or future-you, or Claude) can see your branch exists and reason about it. No more "I didn't know there was a branch".

When you do those two things, every other recipe in this doc becomes optional polish.

## What I'm changing on my end (the AI's process update)

I've added two memory notes that fire on every Virgil session:

- **[Always audit branches and worktrees](../../.claude/projects/-Users-nikolasneofytou-dev-Virgil/memory/feedback_check_branches.md)** — at session start, run `git branch -a` + `git worktree list` and surface anything ahead of `main` *before* writing code.
- **[Virgil branding](../../.claude/projects/-Users-nikolasneofytou-dev-Virgil/memory/project_branding.md)** — the product is Virgil; "Tichu Cyprus" is legacy.

If you bring on a teammate, point them at this doc on day one, set up branch protection, and pick Recipe A. Re-read the "two-line summary" until it's a reflex.
