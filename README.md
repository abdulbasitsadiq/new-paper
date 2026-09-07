# new-paper — a journal paper, and optionally a thesis, from one shared analysis

A reusable template for a **journal article**, with an **optional thesis module**. The slow
work (cleaning data, running statistics, drawing figures) happens **once** in a plain folder
called `shared-resources/`; the paper — and the thesis, if you keep it — are thin layers
that **embed the finished outputs**.

> **One template.** `journal-paper/` is always present. `thesis-book/` (a multi-chapter
> Quarto book) is an **optional module**: keep it when the work will also become a thesis or
> dissertation; delete the folder for a standalone article (see §7). Both embed the same
> `shared-resources/` outputs, so a figure or number is identical in paper and thesis.
> (`new-full-research` was this template plus the book; it is archived — use this one.)

---

## 1. The core idea (plain language)

The analysis runs **once** in `shared-resources/` and writes out figures and statistics.
The paper does **not** redo any of it; it **embeds the finished outputs**. You get a
**single source of truth** for every figure and number, a **clean writing folder** with
no analysis clutter, and **fast renders** that never re-run the slow scripts.

---

## 2. Directory layout

```
new-paper/
├── README.md              ← you are here
├── .gitignore             ← tracks sources; ignores data, outputs, synced copies, renv library
├── .here                  ← sentinel so here() resolves to THIS folder (TRACKED)
├── renv.lock              ← the ONE pinned environment for this project (TRACKED)
├── renv/                  ← renv library + activate script (library/ is gitignored)
├── setup.R                ← installs the lean dependency set
│
├── shared-resources/      ← THE ANALYSIS ENGINE — a plain folder, NOT a Quarto project
│   ├── README.md
│   ├── references.bib     ← MASTER bibliography, single source of truth (TRACKED)
│   ├── data/              ← raw inputs you bring (GITIGNORED) + DATA_DICTIONARY.md + ACCESS.md
│   ├── derived/           ← cleaned data written by scripts (GITIGNORED)
│   ├── scripts/           ← 01-clean.R → 02-analysis.R → 03-figures.R (TRACKED)
│   └── figures/           ← generated plots, the producer/source location (GITIGNORED, regenerated)
│
├── journal-paper/         ← PAPER — a single article (renders to docx + PDF)
│   ├── _quarto.yml        ← type: default; pre-render: _sync.R; docx primary
│   ├── _sync.R            ← copies every figure + references.bib in from shared-resources
│   ├── index.qmd          ← IMRaD manuscript in one file
│   ├── figures/           ← SYNCED-IN copies Quarto embeds (GITIGNORED, regenerated)
│   ├── references.bib     ← SYNCED-IN copy Quarto reads (GITIGNORED — edit the master, not this)
│   └── csl/               ← drop your journal's CSL here (FILL-AND-VERIFY)
│
└── thesis-book/           ← THESIS — OPTIONAL MODULE: a multi-file Quarto BOOK (PDF + docx); delete if no thesis
    ├── _quarto.yml        ← type: book; pre-render: _sync.R; PDF primary
    ├── _sync.R            ← same sync as the paper's (every figure + references.bib)
    ├── index.qmd          ← preface / title page
    ├── frontmatter/       ← declaration, acknowledgements, abstract (unnumbered)
    ├── chapters/          ← 01-introduction … 06-conclusion (cross-chapter @sec- refs work)
    ├── appendices/        ← A-supplementary
    ├── figures/  references.bib  ← SYNCED-IN copies (GITIGNORED, regenerated)
    └── csl/               ← drop your citation style here (FILL-AND-VERIFY)
```

---

## 3. The one rule you must not break

Analysis **writes** outputs into `shared-resources/{figures,derived}` and the master
`shared-resources/references.bib`. A **sync** step copies the **figures** and the
**`.bib`** *into* each writing project right before it renders. The writing projects
**never reach across the folder** for images or the bibliography.

```
                shared-resources/                         journal-paper/
  data/  ──code reads──►  scripts/  ──►  derived/  ──code reads──►  (inline numbers)
                              │
                              ├──►  figures/  ──_sync.R copies──►  ./figures/  ──Quarto embeds──►  PDF/docx
                              │
                          references.bib  ──_sync.R copies──►  ./references.bib  ──Quarto cites──►  reference list
```

**Why:** Quarto can only embed/read resources **inside** its own project directory. An
image or a `bibliography:` referenced with `../` fails on render/deploy. So images and
the `.bib` are **synced in**.

**The asymmetry:** *code* may read **data** across the boundary (R/Python read files
from anywhere). Analysis chunks resolve the programme root from the `.here` sentinel —
`root <- rprojroot::find_root(rprojroot::has_file(".here"))` — and read
`file.path(root,"shared-resources","derived","x.csv")`. (We anchor on `.here` rather
than `here::here()` because Quarto's `_quarto.yml` makes a writing project look like a
`here` root, so `here()` would stop there instead of reaching the shared folder.)
But *Quarto resources* (images, `.bib`) are **synced in, never referenced out**.

---

## 4. One-time setup

```bash
git init                                  # only if this folder is a standalone repo
                                          # (inside a programme repo such as project100, skip — the parent is the repo)
quarto install tinytex                    # LaTeX engine for PDF (once per machine)

# Restore the pinned R environment (open R at THIS folder):
R -q -e 'renv::restore()'                 # on a clone that already has renv.lock
# ...or on a brand-new project with no lockfile yet:
R -q -e 'source("setup.R"); renv::init()'

quarto --version                          # confirm the toolchain
```

> The single `renv` here covers `shared-resources/`, `journal-paper/` and `thesis-book/`. **Refresh it
> per project — never inherit a stale lockfile.** Concretely: on a fresh copy of this
> template run `R -q -e 'renv::restore(); source("setup.R"); renv::snapshot()'`
> (restore what is pinned, install what `setup.R` lists, re-pin). For a clean slate,
> delete `renv.lock` first and run
> `R -q -e 'renv::init(bare = TRUE); source("setup.R"); renv::snapshot()'`.
> Do not rely on `renv::init()` alone: on a project that already has a lockfile it only
> activates the project and leaves the lockfile untouched (verified 2026-09-07, R 4.5.1,
> renv 1.2.3). The shipped `renv.lock` is a starting point, not a pin. `renv::snapshot()`
> records only packages the code uses (`library()`, `pkg::`); packages `setup.R` installs
> but nothing calls yet are pinned when first used. After adding packages (in `setup.R`),
> run `renv::snapshot()` to re-pin.

---

## 5. The everyday workflow

```bash
# (a) put raw data in shared-resources/data/   (gitignored; document it in DATA_DICTIONARY.md)

# (b) run the analysis ONCE (open R at this folder, renv active):
R -q -e 'source("shared-resources/scripts/01-clean.R");
         source("shared-resources/scripts/02-analysis.R");
         source("shared-resources/scripts/03-figures.R")'

# (c) references: the MASTER bib is shared-resources/references.bib. If you use Zotero +
#     Better BibTeX, point a keep-updated auto-export of the paper's collection at this
#     exact path and never edit the file by hand (fix metadata in Zotero instead).

# (d) write the manuscript:  journal-paper/index.qmd   (and, if kept, thesis-book/chapters/*.qmd)

# (e) render — each project's pre-render sync pulls figures + bib in automatically:
quarto render journal-paper      # → journal-paper/index.docx + index.pdf
quarto render thesis-book        # → thesis-book/_book/ (PDF + docx) — only if you kept the module
```

You only repeat step (b) when the data or analysis changes. Rendering (step e) is fast
and never re-runs the scripts.

---

## 6. Setting your target journal

Everything below is a **FILL-AND-VERIFY placeholder** — replace it and verify against
the real source:

- **Author block / ORCID / abstract / keywords** → `journal-paper/index.qmd` front
  matter. Reconcile against your **target journal's author guidelines**; some journals
  offer a Quarto extension (see <https://quarto.org/docs/journals/>).
- **Citation style (CSL)** → drop the journal's `.csl` into `journal-paper/csl/` and
  uncomment the `csl:` line in `journal-paper/_quarto.yml`. Styles:
  <https://www.zotero.org/styles>.
- **Word manuscript template** → set `reference-doc:` in `journal-paper/_quarto.yml`.
- **THESIS layout** (if kept) → `thesis-book/_quarto.yml`, `index.qmd`, `frontmatter/`. The
  **title page, declaration wording, margins, line spacing, page numbering and word count are
  institution-specific — reconcile every one against your official thesis handbook BEFORE
  submission**; the defaults are generic, not compliant. Drop the thesis CSL into `thesis-book/csl/`.

---

## 7. The thesis module: keep it or delete it

`thesis-book/` ships in every copy of this template so that a paper and a thesis can be
built from **one** `shared-resources/` engine with **zero path changes** — the book's
`_sync.R` already expects `../shared-resources/`, and the Results chapter shows the working
cross-chapter reference (`@sec-aims`) that is the reason it is a *book* rather than a single
document.

- **Paper only:** delete the `thesis-book/` folder (the `.gitignore` lines for it are harmless).
- **Thesis later:** copy `thesis-book/` back from this template; nothing else changes.
- **Both:** write `journal-paper/index.qmd` and `thesis-book/chapters/*.qmd` against the same
  `derived/` and `figures/`; every figure is one file, identical in both documents.

---

## 8. Exporting a submission supplement

When a journal asks for a reproducibility supplement, ship a clean standalone repo with:

- `journal-paper/` including its **synced-in `figures/`** and **synced-in `references.bib`**,
- the **`renv.lock`**,
- the **`shared-resources/scripts/`** (and a data-access note) the paper depends on.

If your master `.bib` ever holds more entries than this paper cites, **trim
`references.bib` to only the keys the paper cites** before shipping the supplement (an
export-time step — at render, Quarto already outputs only cited references).

**Mint a DOI for the frozen snapshot.** Once the clean supplement repo is on GitHub,
draft a GitHub **release** and link the repository to **Zenodo**, which mints a permanent
**DOI** for that exact frozen snapshot. Sharing code is not the same as preserving it —
reproducibility studies repeatedly find open repositories that no longer reproduce later,
so a DOI'd, archived release is what makes the supplement durable and citable.

---

## 9. Reproducibility notes

**Provenance stamp.** Every rendered output (the paper's docx and pdf, the thesis PDF) prints, near its
title, the git commit hash and date of the code that produced it — e.g. *Generated from
commit a8bb0d4 on 2026-05-29*. Before you run `git init` and make the first commit it
reads *uncommitted (not a git repo yet)* and resolves to a real hash automatically once
the project is a committed repo. The helper (`shared-resources/scripts/provenance.R`)
uses a plain git call and never fails the render. Reason: a rendered file is decoupled
from the code once produced, so a reader must be able to trace any PDF back to the exact
commit that generated it.

**Blinded data for pre-results code.** When you must write analysis code *before* you
should be looking at the real associations (e.g. a pre-registered secondary analysis),
work against a *blinded* copy of the data made by independently shuffling the rows of
each variable. That preserves every variable's distribution and measurement level while
destroying the between-variable associations, so you can build and test the analysis
code without contaminating it with the real results. Use it when relevant — it is a
technique to apply, not machinery shipped in the template.

**What `renv` does and does not pin.** `renv.lock` pins your R *package* versions, but
NOT the R version itself, the operating system, or system libraries. That is strong,
lightweight reproducibility — enough for most clinical analyses — but not bit-for-bit
guarantees across machines or over many years. If a project ever needs full-environment
reproducibility (a methods paper, a regulated trial, long-horizon archiving), add a
`Dockerfile` capturing the whole environment on top of renv. This is an optional upgrade
path; Docker is deliberately **not** part of these templates.

## 10. Troubleshooting

| Symptom | Cause & fix |
|---|---|
| **PDF won't build** | LaTeX missing. Run `quarto install tinytex`. |
| **"resource not found" / figure missing** | The sync didn't run or the figure isn't generated. Run `shared-resources/scripts/03-figures.R`, then re-render (pre-render `_sync.R` runs automatically; or run `Rscript _sync.R` in `journal-paper/`). |
| **Citations show as `[@key?]` / not resolving** | The `.bib` didn't sync, or the key is wrong/missing. Check the key exists in `shared-resources/references.bib`, then re-render. |
| **Render is slow / re-runs the analysis** | An analysis code chunk is living in `index.qmd` instead of in `shared-resources/scripts/`. Move heavy computation to the scripts; the manuscript should only *read* finished `derived/` outputs. |
| **`here()` points to the wrong place** | The `.here` sentinel at this folder defines the root. Don't delete it; don't add stray `.here`/`.Rproj`/`.git` markers inside the writing projects. |