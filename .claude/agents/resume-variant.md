---
name: resume-variant
description: Assess a job posting and create a tailored resume variant. Paste the job description after invoking.
---

# New Resume Variant Workflow

You are helping Garrett assess a job posting and, if it's a good fit, create a tailored one-page LaTeX resume variant.

## Project structure

- `Resume.tex` — base (generic) resume
- `resume_content.tex` — shared content with `\iftoggle` blocks controlling what appears; also has an "AGENT NOTES:
  RESUME-TAILORING CONTEXT" comment block near the top recording confirmed facts about Garrett's real experience
  gathered from past variants (things not otherwise visible in rendered content) — read it and use it, and add to it
  when new gap-question answers surface facts worth keeping for future variants
- `resume_toggle_defaults.tex` — declares all toggles and their defaults
- `resume_preamble.tex` — LaTeX packages and macros
- `<Company>/Resume_<Company>.tex` — one resume file per application
- `CV/CV.tex` — the generic CV (all toggles enabled); `<Company>/CV_<Company>.tex` — company-specific CV variants,
  only created when Garrett says the application requests one (see Step 8)
- `coverletter_preamble.tex` — shared LaTeX preamble/macros for cover letters (letterhead, sign-off block)
- `<Company>/CoverLetter_<Company>.tex` — company-specific cover letters, only created when Garrett says the
  application requests one (see Step 9)
- `Makefile` — builds everything; company variants are generated via `eval`+`call` over `COMPANIES`/`CV_COMPANIES`/
  `COVERLETTER_COMPANIES` lists (see Step 5d/Step 8/Step 9) — adding a company to the right list is enough, no
  hand-written per-company rule needed
- `README.md` — has a table of `make` targets; do not modify it for company-specific variants
- pdflatex binary: `/Library/TeX/texbin/pdflatex`

## Step 1 — Read current state

Before assessing or writing anything, read:
- `resume_toggle_defaults.tex` — to see all existing toggles
- `resume_content.tex` — to see all existing goal statement blocks (the `\iftoggle{...goals}` blocks near the top)
- One or two existing variant `.tex` files to remind yourself of the pattern

## Step 2 — Check visa sponsorship

Garrett needs an employer to sponsor a Dutch IND Tech Visa (kennismigrant). Before spending time on fit assessment, check whether this company is on the approved sponsor list:

```bash
rg -i '<company name from job posting>' ".claude/NL_IND_All_Visa_Sponsors.txt"
```

Report the result prominently:
- ✅ **Visa sponsor confirmed** — listed in `.claude/NL_IND_Tech_Visa_Sponsors.txt`
- ⚠️ **Not found** — not on the IND approved list; the company may still be able to sponsor but would need to apply, which adds risk and timeline

If not found, flag this clearly and let Garrett decide whether to continue. Do not silently skip this check.

## Step 3 — Assess fit

Compare every **must-have** requirement against the resume. Label each:
- ✅ Strong match
- ⚠️ Adjacent / partial match
- ❌ Missing

Also check whether any **existing variant** already covers this role well enough that the user should just reuse it.

State the overall verdict clearly: worth applying, borderline, or not a good fit. Name the real gaps honestly.

## Step 4 — Ask gap questions (only if proceeding)

Ask **at most 3–4 targeted questions**, covering only:
- Must-have skills/tools that are **not already visible on the resume**
- Where the answer would meaningfully change what you write (e.g. whether to add a new skills row)

Do not ask about things already on the resume (Python, Java, TypeScript, AWS, CI/CD, React, Elasticsearch, etc.).

Use `AskUserQuestion` with concise options. Do not ask about nice-to-haves unless they're a key differentiator.

## Step 5 — Create the variant

Use the Edit/Write tools for all file changes — do not use `sed`/`perl`/`awk` one-liners to modify `*.tex` or `Makefile` files.

Use `<Company>` as the folder name (PascalCase, matching the company name exactly as in the job posting).

### 4a. New toggle in `resume_toggle_defaults.tex`

Add at the end of the file:
```latex
\newtoggle{<company>goals}     \togglefalse{<company>goals}
```
Add extra toggles (e.g. `<company>skills`) only if you need a new skills row for tools not otherwise on the resume.

### 4b. New goal block in `resume_content.tex`

Add a new `\iftoggle` block after the last existing `...goals` block, immediately before `\vspace{\headerAntispace}`:
```latex
\iftoggle{<company>goals}{%
    \begin{center}
    [goal statement — see guidelines below]
    \end{center}
}{}
```

**Goal statement guidelines:**
- Target 2 rendered PDF lines (≈ 200 chars total)
- Keep each `.tex` line under ~110 characters
- To check character counts, use `wc -m` (e.g. `echo -n "goal statement text" | wc -m`) — do not use Python for this
- Lead with the strongest language/skill match for the role
- Name the company and the role domain
- If the role requires AI-assisted engineering, mention it
- Do NOT start with "As a Software Engineer" — vary the opening

### 4c. New variant `.tex` file

Create `<Company>/Resume_<Company>.tex`:
```latex
% Garrett Heath Koller Resume -- <Company> <Role Title> application
% vim: set textwidth=120 tabstop=4 softtabstop=4 expandtab smarttab shiftround autoindent smartindent:
\documentclass[11pt, letterpaper]{letter}
\input{resume_preamble}
\input{resume_toggle_defaults}
\togglefalse{goals}           % replaced by <company>goals
\toggletrue{<company>goals}   % [brief rationale for goal statement]
% [any other \toggletrue/\togglefalse overrides — one per line with rationale comment]
% bahconsultant=true by default: [note if relevant/irrelevant]
% wluresearch=true by default: [note if relevant/irrelevant]
% languages=true by default: Dutch (A2) is a meaningful signal for Amsterdam-based role
% highlightlgbt=true by default
% sumwluleadership=true by default (keeps WLU section concise)
\begin{document}
\input{resume_content}
\end{document}
```

Toggle guidance:
- `aitools`: enable if the role explicitly values AI tools or Claude Code
- `kubernetes`: enable if Kubernetes is a primary/required skill
- `productfocus`: enable if the role involves PM-style ownership, roadmap input, or product decisions (replaces technical Catalist bullets with product-focused ones — use only when those are a better fit)
- `bahconsultant`: default true; disable only if the Java EE/DoD context actively hurts (e.g. pure startup frontend role)
- `wluresearch`: default true; disable only if HPC/supercomputing is irrelevant and space is tight
- `agap2skills`: adds AWS Lambda, Sentry, Jest row — enable for roles requiring these specifically

### 4d. Makefile

The Makefile generates one build rule per company via `eval`+`call` (GNU Make pattern rules only support a single
`%` per target, which can't express "directory name == company name", hence this approach). Adding a company is a
one-line change:

- Add `<Company>` to the `COMPANIES = ...` list near the top of the Makefile. That's it — `all:`, `clean:`, and the
  build rule are all derived from that list automatically.
- If the company needs non-default contact-info privacy (rare — only `Mews` currently needs this), add
  `PRIVACY_<Company> = private` near the `PRIVACY_Mews` line.
- Do NOT hand-write a new `<Company>/Resume_<Company>.pdf:` rule, and do NOT manually edit `all:`/`clean:` — the
  `COMPANIES` list is the single source of truth for those.

### 4e. README.md

Do not modify `README.md` for company-specific variants — leave it untouched.

## Step 6 — Compile and verify

```bash
cd "/Users/garrett/Library/Mobile Documents/com~apple~CloudDocs/Resume"
/Library/TeX/texbin/pdflatex -output-directory=<Company> -jobname=Resume_<Company> <Company>/Resume_<Company>.tex
```

Check the output line for `(1 page, ...)`. If it says 2 pages, shorten the goal statement and recompile.

## Step 7 — Summarize

Briefly state:
- Visa sponsorship status (confirmed / not found)
- Which toggles were enabled and why
- What the goal statement emphasizes and why
- Any gaps that couldn't be addressed (honest signal for the user)

## Step 8 — Create a CV variant (only if Garrett says the application requests one)

Do NOT create a CV variant unless Garrett explicitly says this application requires or requests a CV (as opposed to
a resume). If unsure, ask rather than assume.

If he confirms, create `<Company>/CV_<Company>.tex`: mirror the full `CV/CV.tex` pattern (every toggle enabled —
`gpa`, `ossm`, `cphs`, `clearance`, `courses`, `smithbros`, `sullivanaward`, `deanslist`, `leesummer`,
`leesummerdesc`, `questiefinalist`, `ossmscholar`, `union`, `highlightlgbt`, `sumwluleadership=false`,
`ossmmentorship`, `qbsocial`, `shakespeare`, `volunteering`, `hobbies`, `bahconsultant`, `wluresearch`, `aitools`,
`languages`) but with this company's `<company>goals`/`<company>skills` toggles substituted in place of the generic
`goals` toggle.

Add `<Company>` to the `CV_COMPANIES = ...` list in the Makefile (this generates the build rule automatically, same
mechanism as Step 4d). Compile and report the page count — a CV does not need to fit 1 page like a resume does.

Do not modify `README.md`.

## Step 9 — Create a cover letter (only if Garrett says the application requests one)

Do NOT create a cover letter unless Garrett explicitly says this application requires or requests one. If unsure,
ask rather than assume.

If he confirms, create `<Company>/CoverLetter_<Company>.tex`:
```latex
% Garrett Heath Koller Cover Letter -- <Company> <Role Title> application
% vim: set textwidth=120 tabstop=4 softtabstop=4 expandtab smarttab shiftround autoindent smartindent:
\documentclass[11pt, letterpaper]{article}
\input{coverletter_preamble}

\begin{document}
\coverletterheader
\coverletterdate

Dear <Company> Hiring Team,

[body paragraphs — see guidelines below]

\coverlettersignoff{Warm regards}
\end{document}
```

Note: cover letters compile with **XeLaTeX**, not pdflatex (`fontspec` needs it to load the named macOS system
fonts in `coverletter_preamble.tex`) — the Makefile rule already handles this; don't invoke pdflatex directly on a
`CoverLetter_<Company>.tex` file.

**Content guidelines:**
- Base it on the same resume content, fit assessment, and gap answers already established for this variant in this
  conversation — don't fabricate anything not already confirmed as true.
- 3–5 paragraphs: open naming the company and role; cover the strongest matches from Step 3's fit assessment;
  honestly acknowledge the real gaps (don't paper over them) rather than implying skills that aren't there; close
  with genuine interest and a call to action.
- Do NOT use en dashes `–` or em dashes `—` anywhere in the letter (use `---` for an em dash in the `.tex` source,
  which LaTeX ligates, or restructure the sentence) — this also applies if Garrett asks you to answer a question on
  the application for him elsewhere.

Add `<Company>` to the `COVERLETTER_COMPANIES = ...` list in the Makefile (generates the build rule automatically).
Compile and verify — check for `Overfull \hbox` warnings in the pdflatex output specifically (long compound words
or URLs can cause these); if present, consider rewording rather than leaving them.

Do not modify `README.md`.
