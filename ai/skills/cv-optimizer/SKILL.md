---
name: cv-optimizer
description: "Use this skill to tailor a CV to a job description and make it pass Applicant Tracking Systems, in English or Spanish (\"optimiza mi CV\", \"ATS\", \"match con esta vacante\", \"keywords\", \"no me llaman a entrevistas\", \"check my resume against this JD\"). Covers: extracting JD keywords, scoring the match, listing gaps, writing or rewriting a CV from a source CV, and checking that the final DOCX/PDF parses. Not for cover letters, LinkedIn profiles, or interview prep."
---

# CV Optimizer

Tailor one source CV to one job description (JD). The source CV is the only fact base: every claim in the output traces to it. A JD requirement the source does not support is a **gap**: record it in the report and leave it out of the CV.

## Workflow

Needs two inputs: the source CV (master) and the JD. Ask for whichever is missing, one at a time.

### 1. Extract keywords
List the JD's keywords in three groups: hard skills (languages, tools, platforms, certifications, methodologies), soft skills, and industry terms. Mark each **critical** (stated as required, or mentioned 2+ times) or **important** (everything else). Keep the JD's exact wording; it is what the ATS matches.

### 2. Match against the source
Give every keyword exactly one verdict:
- **Matched**: the exact term is in the source.
- **Reword**: the source has a synonym or the same skill under another name (e.g. "risk mitigation" vs "risk management"). Adopt the JD's term only when the source's meaning is identical.
- **Gap**: nothing in the source supports it.

Score = critical keywords Matched or Reworded ÷ total critical × 100. Target 80%+; reach it by rewording, never by adding unsupported terms. A low score on an honest CV is a finding to report.

### 3. Write the CV
Select and reorder from the source; follow [references/cv-rules.md](references/cv-rules.md) for layout and writing. Place keywords by priority: summary (5-8 most important), skills section (JD's exact phrasing), then experience bullets. Critical keywords appear 2-4 times, important ones 1-2, each phrased naturally.

### 4. Verify
- Every bullet, skill, date, and certification in the CV exists in the source.
- Re-score; report the before and after scores.
- Export to DOCX or PDF, then extract the text (`pdftotext file.pdf -` or `pandoc file.docx -t plain`). All sections, dates, and contact data must come out in order.

Done when each keyword has a verdict, each CV claim has a source line, and the extracted text reads cleanly.

### 5. Report
Fill [assets/COMPATIBILITY.template.md](assets/COMPATIBILITY.template.md). Put gaps in their own section with what the user would need to confirm (a real project, a date, a metric) before they could be added.
