# Resume for Garrett Heath Koller

[Click here](https://github.com/garrettheath4/Resume/releases/download/latest/Resume.pdf) to view the Resume as a PDF file.

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

| Command | Output | Contact info shown |
|---|---|---|
| `make` | all PDFs below | — |
| `make Resume.pdf` | one-page resume | public email only |
| `make Resume_phone.pdf` | one-page resume | real phone + public email |
| `make Resume_private.pdf` | one-page resume | real phone + private email |
| `make CV/CV.pdf` | multi-page CV (all sections) | public email only |
| `make CV/CV_phone.pdf` | multi-page CV | real phone + public email |
| `make CV/CV_private.pdf` | multi-page CV | real phone + private email |
| `make clean` | _(removes all generated files)_ | — |

Company-specific resumes live in their own subdirectories (`Mews/`, `Airwallex/`, etc.) alongside their generated output files. The full CV lives in `CV/`.

> **Note:** Builds that include real contact info (`_private`, `_phone`, and Mews variants) require the secret files above and should only be compiled locally — they are not produced by GitHub Actions.
