# README sections

The catalog for step 2 (which sections) and the format rules for step 3 (how to write them). The order of catalog sections lives in [`../assets/README.template.md`](../assets/README.template.md).

## Core sections

Every README has these.

| Section | Content |
| --- | --- |
| Title and pitch | Project name, then one or two sentences: what it does, for whom, and the problem it solves. The project's logo above the name when one is tracked (an app icon is not a logo). |
| Quick Start | **Prerequisites** (runtime and package manager with versions, accounts, API keys, repo access when private), then numbered steps that fit this project: clone, install, configure, every setup assumption from the inventory (migrations, a first user, the required clone location), run. End with the URL or output that proves it works. |
| Usage | The smallest real example of the main job: a command and its output, a code snippet and its result, or the first screen. Output comes from running a read-only command; nondeterministic output (model replies) is labeled as an example. For a template, the main job is starting a new project from it. |

## Conditional sections

Include a section when the inventory meets its trigger.

| Section | Trigger |
| --- | --- |
| Badges | A CI workflow, a published package, or a license exists |
| Screenshot or demo | The project has a UI or terminal output worth seeing. Without a tracked image, leave a TODO naming what to capture. |
| Navigation | More than six `##` sections: one line of anchor links under the pitch |
| Features | Three or more distinct capabilities |
| Tech stack | Three or more tools a contributor must know to work on it |
| Repository structure | A layout the reader must learn: monorepo, template, content collection, or more than a handful of top-level directories |
| Architecture | More than one moving part the reader must understand: runtime components (frontend, backend, worker, database, queue) or a mechanism (symlink layout, generated files) |
| API | Exposes an HTTP API, or is a library with a public API |
| Configuration | Settings the reader provides or may change: environment variables, config files, or paths the code assumes |
| Testing | A test script exists |
| CI | A CI workflow exists |
| Deployment | Deploy scripts or platform configs exist |
| Troubleshooting | Setup errors are known: messages the code emits on setup paths, runbooks, issues |
| Documentation | A `docs/` folder, ADRs, or nested READMEs exist |
| Contributing | Anyone besides the owner changes the repo, or it has a branch and PR flow to follow |
| License | A `LICENSE` file exists |

**Project-specific sections** (creating a skill, customizing a niche) are outside the catalog. Add one, or keep one in update mode, when it answers a question this repo's reader has; place it right after Usage.

**Companion files** appear as one-line links: `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `CHANGELOG.md`, and `SECURITY.md` from Contributing; `LICENSE` from License. When `CONTRIBUTING.md` is missing, write Contributing inline in three to five lines (branch naming, commit style, the check to run before a PR). When `CHANGELOG.md` is missing, add one line there on the versioning scheme and where releases are listed.

## Section content

- **Features**: three to seven bullets, each a bold label and its benefit.
- **Tech stack**: group by role (runtime, framework, database, auth, hosting) in a table or a short list.
- **Repository structure**: a `text` block with a tree as deep as the layout the reader must learn (usually two levels), `<name>/` for a repeated entry, a `#` comment beside each entry, and only the entries the reader needs.
- **Architecture**: one paragraph per component on what it owns, plus one row per data store (database, bucket, queue) with its purpose and a link to its schema. Add a Mermaid diagram when there are four or more components and the repo has no diagram yet.
- **API**: a table per area with `Method`, `Path`, and `Description`, then one request followed by its response, so the reader sees the output before trying it. With many endpoints, group them by prefix, list the ones a newcomer calls first, and link the routes for the rest. For a library, the main exports with signatures and a link to the full reference.
- **Configuration**: one table per settings file (secrets and plain vars apart when the platform splits them) with `Variable`, `Required`, and `Description`. Add `Default` only for real defaults, never example values; when a requirement depends on the environment, say which.
- **Testing**: the command for each suite and what it needs (a database, a running server, real API keys).
- **CI**: the badge plus one line on what runs and when, linking the workflow file.
- **Deployment**: a table with `Component`, `Platform`, and `Notes` (secrets to set, the deploy command), plus a link to the runbook when one exists.
- **Troubleshooting**: the symptom or exact error message as the bullet, the fix underneath.
- **Documentation**: the main docs as a list, each with one line on when to read it.

## Format rules

- Use GitHub Flavored Markdown with exactly one `#` heading (the title); every section is `##`.
- Name headings after the catalog sections, in the README's language; in update mode, keep the author's names.
- Give every code block a language. Shell commands are copy-pasteable: no `$` prompt, one command per line, a `#` comment on any non-obvious one.
- Use tables for anything with three or more items that share fields.
- Link repo files with relative paths so they resolve on forks and branches.
- Give every image alt text; store images in the repo (for example `docs/images/`).
- Take badges from shields.io or GitHub's workflow badge (`https://github.com/<owner>/<repo>/actions/workflows/<file>/badge.svg`), at most four, in one line under the title. In a template repo, a badge with a fixed `<owner>/<repo>` points every copy at the template: leave it out or tell the user.
- Reserve GitHub alerts (`> [!NOTE]`, `> [!TIP]`, `> [!IMPORTANT]`, `> [!WARNING]`, `> [!CAUTION]`) for the two or three facts that bite a newcomer.
- Keep a single source: when a fact lives in a doc, ADR, workflow file, or code constant, state the one line the reader needs and link the rest.
