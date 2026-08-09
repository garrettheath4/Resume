---
name: resume-variant
description: Assess a job posting and create a tailored resume variant. Paste the job description after invoking.
---

# New Resume Variant Workflow

You are helping Garrett assess a job posting and, if it's a good fit, create a tailored one-page LaTeX resume variant.

## Project structure

- `Resume.tex` — base (generic) resume
- `resume_content.tex` — shared content with `\iftoggle` blocks controlling what appears
- `resume_toggle_defaults.tex` — declares all toggles and their defaults
- `resume_preamble.tex` — LaTeX packages and macros
- `<Company>/Resume_<Company>.tex` — one file per application (Airwallex, agap2, Cboe, DataSnipper, Mews)
- `Makefile` — builds everything; each variant has its own target + entry in `all:` + `clean:`
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

Add a new target (after the last company-specific target, before `Resume_private.pdf:`):
```makefile
<Company>/Resume_<Company>.pdf: <Company>/Resume_<Company>.tex $(SHARED_TEX)
	$(MAKE) public
	/Library/TeX/texbin/pdflatex -output-directory=<Company> -jobname=Resume_<Company> <Company>/Resume_<Company>.tex
	$(MAKE) clean-secrets
```

Also update:
- `all:` line — append `<Company>/Resume_<Company>.pdf`
- `clean:` block — append `rm -f <Company>/Resume_<Company>.pdf <Company>/Resume_<Company>.aux <Company>/Resume_<Company>.log <Company>/Resume_<Company>.out`

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

## Step 8 — Offer a cover letter (optional)

Ask Garrett whether he'd like cover letter text for this application. He copies this text manually into a Pages
document in iCloud Drive, so:
- Output plain text only in your reply — no file creation, no LaTeX, no markdown formatting that wouldn't paste
  cleanly into Pages.
- Base it on the same resume content and gap answers used for this variant — don't fabricate anything not already
  established as true in this conversation or on the resume.
- Keep it concise (3–5 short paragraphs), name the company and role, and lead with the strongest match from Step 3's
  fit assessment.
- Do NOT use en dashes `–` OR em dashes `—` in the cover letter copy or if Garrett asks you to answer a question on the
  application for him.
- If Garrett declines, skip this step entirely.
