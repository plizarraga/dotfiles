---
name: dependabot-setup
description: "Use this skill when a user wants a GitHub repo to keep its dependencies and GitHub Actions up to date automatically, and whenever they mention Dependabot or its PRs, in English or Spanish (\"add dependabot\", \"que se actualice solo\", \"actualizaciones automáticas\"). Covers: setting up automatic updates for a repo, pnpm/npm/yarn workspace or monorepo (including Docker and Actions); creating, reviewing or fixing .github/dependabot.yml (grouping, duplicate PRs, directories, cooldown, chore(deps) commit prefixes); documenting in AGENTS.md/CLAUDE.md how to handle Dependabot PRs (merge order, regenerating the lockfile); and fixing bot PRs that conflict or fail CI (lockfile conflicts, ERR_PNPM_MINIMUM_RELEASE_AGE_VIOLATION, OUTDATED_LOCKFILE). Not for Renovate, manually bumping or migrating a specific package, one-off update scripts, or CVE/security-alert triage."
---

# Dependabot Setup

Install or repair Dependabot so its PRs are mergeable one at a time. Verify every claim against the real files before acting; ask only when something is ambiguous.

## Known pitfalls (why each step exists)

1. **Dependabot may not parse the pnpm lockfile.** On pnpm 11 it replied "can't parse pnpm-lock.yaml" and could not rebase or update any PR. Re-check this against current Dependabot docs; do not assume it still holds.
2. **Conflicts are almost always the lockfile only.** Each merge advances `main` and stales the remaining PRs.
3. **`minimumReleaseAge` (pnpm) rejects packages published within the window.** Dependabot's own `cooldown` defaults to 3 days for version updates (never for security updates), so it covers the *direct* dependency it bumps. It does not cover *transitive* packages the regenerated lockfile resolves fresh: that is what produced `ERR_PNPM_MINIMUM_RELEASE_AGE_VIOLATION` on a fastify patch bump. Set an explicit `cooldown` only when `minimumReleaseAge` exceeds 3 days; for transitive hits, re-run CI after the window.
4. **Major bumps can leave the lockfile out of sync** (`ERR_PNPM_OUTDATED_LOCKFILE`) and can produce duplicate PRs.
5. **Multiple `directories` duplicate shared dependency bumps** when the repo is a workspace with one root lockfile. With several directories, add `groups.<name>.group-by: dependency-name` so one dependency bumped in N directories becomes a single PR (official monorepo pattern).
6. **Some red CI is infrastructure**, e.g. `ETIMEDOUT` in a native `postinstall` download. Read the log before touching code; re-run with `gh run rerun <id> --failed`.
7. **Big grouped PRs are the fragile ones.** Single-dependency PRs merge or close cleanly.

## Workflow

### 1. Diagnose (change nothing yet)
- Detect package manager and version, workspaces, and every `package.json` directory.
- pnpm: check `minimumReleaseAge` in `pnpm-workspace.yaml`.
- Check for an existing `.github/dependabot.yml` and the CI workflows.

### 2. Write `.github/dependabot.yml`
Start from `assets/dependabot.template.yml`. Rules:
- One directory per ecosystem when a single root lockfile covers a workspace. List several only if each has its own lockfile, and then add a `group-by: dependency-name` group so shared bumps stay one PR.
- Weekly schedule with an explicit `timezone`.
- `open-pull-requests-limit` of 3-5.
- Conventional Commits prefixes (`chore(deps)`, `chore(ci)`). Never add Co-Authored-By or AI attribution.
- Group minor+patch into a production group and a development group. Majors stay as individual PRs.
- Dependabot already applies a 3-day default cooldown to version updates. If `minimumReleaseAge` exists and is longer than 3 days, add `cooldown.default-days` at least equal to it (days, rounded up; allowed range 1-90). `semver-major-days`/`semver-minor-days`/`semver-patch-days` let majors wait longer.
- To keep majors out of grouped PRs use `update-types: [minor, patch]` in the group; to silence a major entirely use `ignore` with `update-types: ["version-update:semver-major"]`.
- Security updates are separate (Settings > Advanced Security) and ignore cooldown. Mention enabling Dependabot alerts and security updates to the user; do not assume they are on.
- Add `github-actions` always; add `docker` only if Dockerfiles exist.

### 3. CI as the merge gate
- CI runs on `pull_request` and installs with the frozen lockfile (`pnpm install --frozen-lockfile`).
- Build and tests are required checks. Preview deploys (Vercel etc.) count as checks.

### 3b. Optional automation (only if the user wants it)
Official pattern: a `pull_request` workflow guarded by `github.event.pull_request.user.login == 'dependabot[bot]'`, using `dependabot/fetch-metadata` (pin to a commit SHA) to read `update-type`, then `gh pr merge --auto` for patch updates only. Requires branch protection with required status checks, otherwise auto-merge skips CI. Secrets for Dependabot-triggered runs must be Dependabot secrets, not Actions secrets.

### 4. Lockfile strategy
Test whether Dependabot can parse the lockfile (open a test PR or check current docs). If it cannot, document the manual recipe in the project's `AGENTS.md`/`CLAUDE.md` (see below).

### 5. Document in AGENTS.md / CLAUDE.md
Add a short "Dependabot" section containing:
- **Merge order:** small single-dependency patches first, the big group last, one at a time. After each merge the next PR may need a rebase.
- **Manual lockfile recipe** (pnpm), on the PR branch:
  ```bash
  git fetch origin && git merge origin/main        # lockfile will conflict
  git checkout origin/main -- pnpm-lock.yaml
  pnpm install --no-frozen-lockfile
  pnpm install --frozen-lockfile && pnpm build     # plus tests
  git add pnpm-lock.yaml && git commit -m "chore(deps): merge main and regenerate lockfile" && git push
  ```
- **Transient failures to re-run, not investigate:** network timeouts in postinstall, `MINIMUM_RELEASE_AGE_VIOLATION` (wait out the window).

### 6. Deliver
- Branch `chore/dependabot-setup`, Conventional Commits.
- Show the diff before committing. No push or PR until the user confirms.

## Triage of existing PRs

When asked to review open Dependabot PRs:
```bash
gh pr list --state open --json number,title,mergeable,mergeStateStatus,headRefName
gh pr checks <n>
gh run view --job <job-id> --log-failed
```
Classify each: real conflict, stale lockfile, release-age, transient infra, or genuine breakage. Fix lockfile-only cases with the manual recipe, re-run transient ones, and propose a merge order (smallest first). Never merge on the user's behalf unless asked.
