# Resume for Garrett Heath Koller

[Click here to view the Resume as a PDF file](https://github.com/garrettheath4/Resume/releases/download/latest/Resume.pdf).

This PDF was generated from the LaTeX code in the [`Resume.tex`](./Resume.tex) file.

The LaTeX code was originally based on a LaTeX resume template by [Dr. Joshua Stough](https://github.com/joshuastough).

## Setup

Before running any `make` command, create `public_email.txt` with your public-facing email address:

```shell
echo 'public.email@icloud.com' > public_email.txt
```

This file is listed in `.gitignore` and will not be committed.

For builds that include your real phone number or private email, also create the relevant secret files:

```shell
echo '+1 (555) 555-5555' > secret_phone.txt   # real phone number
echo 'private@gmail.com' > secret_email.txt   # private email (Gmail, etc.)
```

These are also listed in `.gitignore`.

## Building

<!-- Agent note: do not add a per-company row to this table (e.g. for a new Resume/CV/CoverLetter variant). The
     <Company>/... pattern rows below already cover every company generically and stay accurate automatically.
     Adding per-company rows here creates upkeep that will go stale. See .claude/agents/resume-variant.md. -->

| Command                                    | Output                          | Contact info shown                    |
| ------------------------------------------ | ------------------------------- | ------------------------------------- |
| `make`                                     | all PDFs below                  | —                                     |
| `make Resume.pdf`                          | one-page resume                 | public email only                     |
| `make Resume_phone.pdf`                    | one-page resume                 | real phone + public email             |
| `make Resume_private.pdf`                  | one-page resume                 | real phone + private email            |
| `make CV/CV.pdf`                           | multi-page CV (all sections)    | public email only                     |
| `make CV/CV_phone.pdf`                     | multi-page CV                   | real phone + public email             |
| `make CV/CV_private.pdf`                   | multi-page CV                   | real phone + private email            |
| `make <Company>/Resume_<Company>.pdf`      | tailored resume for `<Company>` | public email only (unless overridden) |
| `make <Company>/CV_<Company>.pdf`          | tailored CV for `<Company>` *   | public email only                     |
| `make <Company>/CoverLetter_<Company>.pdf` | cover letter for `<Company>` *  | public email only                     |
| `make clean`                               | _(removes all generated files)_ | —                                     |

> _Note_: `*` in the Output column above means "only exists for some companies"

To see which companies currently have a tailored resume, CV, and/or cover letter, check the `COMPANIES`,
`CV_COMPANIES`, and `COVERLETTER_COMPANIES` lists near the top of the `Makefile` (or run `ls */Resume_*.tex`).

Company-specific resumes, CVs, and cover letters live together in their own subdirectory (e.g. `Picnic/`, `Syntho/`) alongside their generated output files. The generic CV and contact-info variants live in `CV/`.

> **Note:** Builds that include real contact info (`_private`, `_phone`, and any company overridden via `PRIVACY_<Company>` in the Makefile, e.g. Mews) require the secret files above and should only be compiled locally — they are not produced by GitHub Actions.
