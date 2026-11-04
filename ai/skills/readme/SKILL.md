---
name: readme
description: "Create, update, or audit a project's README.md. Use when a repo needs a README, an existing one is outdated or thin, or the user wants it reviewed. Chooses sections from evidence in the repo and verifies every command, setting, path, and link it states."
---

# README

A README is the project's **map**: what it is, how to get it working, how the parts connect, and where the rest lives. It links to the territory (docs, workflow files, `CONTRIBUTING.md`) instead of copying it, so it stays true as the repo changes.

Two bars define a finished README:

- **Sourced**: every command, setting, path, version, and link it states comes from a file in the repo or, for a third-party tool, from that tool's official docs.
- **Ten-minute test**: a stranger goes from `git clone` to the working end state (a running app, a passing command, the documented result) in under ten minutes using only the README.

Three modes share the steps below:

- **Create**: no README yet. Run all five steps.
- **Update**: a README exists. Run all five. In step 1, also check every claim the existing README makes (paths, trees, values, flows, commands) against the code: stale claims are the main job. Keep the README's language, the author's conventions (section order, nav line, bullet style), and sections outside the catalog that answer a reader's question; change them only when they fail a check.
- **Audit**: review only. Run steps 1, 2, and 4 with the existing README as the draft, and check it against the format rules in `references/sections.md`. Write nothing; report gaps, failed checks, and sections present without a trigger.

## 1. Inventory

Read the repo and record each fact the README could state, with the path it came from. Write nothing yet.

- **Project type**: app/service, library, CLI, template/starter, monorepo, config or content collection (dotfiles, skills, docs). Often more than one.
- **Purpose**: from the existing README, the manifest's `description`, `docs/`, a PRD.
- **Readers**: strangers (a public repo), the team, agents (an `AGENTS.md` or `CLAUDE.md` exists). When `docs/` or `AGENTS.md` already carry the detail, the README stays a map: one line per topic and a link.
- **Stack and versions**: manifests (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, …) and version pins (`engines`, `packageManager`, `.nvmrc`, `.tool-versions`, CI setup steps), plus the `engines` floors of key dependencies (the package manager, the test runner).
- **Entry points**: `package.json` scripts, `Makefile`, `justfile`, `Taskfile.yml`, `scripts/`, `bin/`.
- **Settings**: every file that defines what the reader provides or may change: `.env.example`, `.dev.vars.example`, platform config vars, a typed env schema.
- **Setup assumptions**: what the code expects of the reader's machine and first run: hardcoded paths (where the repo must live), directories or tools that must exist, migrations, a first user, what the first screen or command demands (login, seeded data). Read the setup scripts and the first route or command a newcomer hits.
- **Setup errors**: error messages the code emits on setup paths, runbooks, issues.
- **CI and deploy**: `.github/workflows/*`, deploy scripts, platform configs (`wrangler.jsonc`, `vercel.json`, `Dockerfile`, `fly.toml`).
- **Companion files**: `LICENSE`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `CHANGELOG.md`, `SECURITY.md`. GitHub finds these in the root, `docs/`, or `.github/`; check all three. Nested READMEs (`admin/README.md`) too.
- **Visuals**: logo, screenshots, demo GIFs tracked in the repo.
- **Visibility**: public or private (`gh repo view --json visibility`). It decides whether a stranger can clone it and whether badges render outside GitHub.
- **Language**: the existing README's language; for a new README, the language of the repo's docs (ask when they disagree). Translation twins (`README.es.md`) are part of the README.

Done when every fact you plan to state has a source, and every setup assumption is either covered by a Quick Start step or recorded as a gap.

## 2. Choose sections

Read [`references/sections.md`](references/sections.md). Take every core section, then each conditional section whose trigger the inventory meets.

Done when every core section is present, every other section names the inventory fact that earned it, and every triggered section you leave out has its reason for the report.

## 3. Draft

Start from [`assets/README.template.md`](assets/README.template.md): it fixes the order of the catalog sections. Delete the sections you did not choose, replace placeholder steps that do not fit this project, and fill the rest following the format rules in `references/sections.md`.

## 4. Verify

Check the draft claim by claim against the inventory:

- [ ] Every repo command matches an entry point by name; every standard tool command (`git`, `cp`, the package manager, a platform CLI) matches its docs; every path inside a command matches where the Quick Start puts things.
- [ ] Every setting the README names exists in a settings file, and every setting needed to reach the end state is named in the Quick Start.
- [ ] Ports, URLs, and versions agree across the Quick Start, the config, and every table.
- [ ] Every relative link and image resolves to a tracked file or directory (`git ls-files`), and every anchor matches a heading.
- [ ] Every badge reflects real state (a workflow, a published version, a license).
- [ ] Example values are placeholders; no token, key, ID, or real credential appears.
- [ ] Translation twins carry the same commands, links, and sections.
- [ ] Ten-minute test. Execute the Quick Start in a scratch checkout (the repo's own worktree command when it has one) only when install is cheap, needs no paid keys, and leaves no lasting state outside the checkout (user config, global installs, real services); redirect tool caches and logs into the checkout when the tool allows it. Skip a step that would overwrite state the checkout already has (copied secrets) and say so. Otherwise walk it on paper: each step's inputs come from a prerequisite or an earlier step, and every setup assumption is met before the end state.

Done when every box is checked or marked n/a (its subject does not exist in this repo). Fix a failing check in the draft. A claim you could not confirm stays as `<!-- TODO: <what to confirm> -->` at that spot.

## 5. Deliver

Create and update modes: write `README.md` at the repo root and its translation twins. Then report:

- Each section chosen and the fact that earned it, one line each.
- Update mode: each change to the existing README and its reason; each removed section and why.
- Each TODO left and what would resolve it.
- How the ten-minute test ran: executed or on paper, and any risk it could not rule out.
- A public repo without a `LICENSE`: say so. Choosing one is the owner's call.
