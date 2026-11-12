---
name: new-job-application
description: "Use when a job description (JD) is pasted in the career workspace and the user wants the whole application folder: JD, compatibility report, tailored CV (DOCX and PDF), introduction, and mock interview. Triggers: \"crea la carpeta para este JD\", \"nueva vacante\", \"new application\", \"prepara todo para esta vacante\". Not for editing one file of an existing application."
---

# New job application

Turn one pasted JD into a complete application folder. The steps live in the career repo's `CLAUDE.md` ("Hard rules" and "Workflow per JD"): that file is the single source, this skill only sequences it.

## Steps

1. Confirm the workspace: `master/CV_MASTER.md` and `scripts/check-applications.sh` exist in the cwd. If not, stop and say this skill needs the career repo.
2. Collect the inputs: the JD text, the company, the channel, and the recruiter (name, title, connection degree). Ask for each missing one, one question at a time. An undisclosed client is `confidential`.
3. Read `CLAUDE.md` and run "Workflow per JD" steps 1 to 7 in order. Every step runs inside the hard rules: the master is the only source of facts, and an unsupported JD requirement is a gap.
4. Done when `scripts/check-applications.sh applications/<folder>` prints "all folders complete".
5. Report in 4 lines at most: folder name, match score before and after, the gaps, and the `[brackets]` left in `INTRODUCTION.md` for the user to complete.

Job-specific folders stay out of git: commit nothing.
