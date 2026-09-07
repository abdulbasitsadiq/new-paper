# setup.R — one-time dependency setup for this research programme -----------
#
# Lean, general dependency set shared by the analysis engine and the writing
# projects. Install once, then snapshot with renv (see README). Add project-
# specific packages in the marked zone below, then re-snapshot.
#
# Usage (from this folder, the research-programme root):
#   source("setup.R")          # installs anything missing
#   renv::snapshot()           # pin them into renv.lock

# General, lean set ----------------------------------------------------------
pkgs <- c(
  "here",       # project-root-anchored paths in the analysis scripts
  "rprojroot",  # used by the writing docs to anchor on the .here sentinel
                # (see README: here() alone stops at a writing project's _quarto.yml)
  "tidyverse",  # dplyr/readr/ggplot2/... — data wrangling + figures
  "broom",      # tidy model output for code-driven numbers
  "gt",         # publication-quality tables
  "knitr",      # rendering engine used by Quarto
  "rmarkdown"
)

# Evidence-synthesis set (systematic reviews / meta-analyses) ---------------
# Comment out for primary-data papers that do not pool.
pkgs <- c(pkgs,
  "metafor",     # meta-analysis engine (escalc, rma, forest, funnel, regtest)
  "meta",        # metaprop/metabin cross-check; tidy summaries
  "robvis",      # risk-of-bias traffic-light and summary plots
  "PRISMA2020",  # PRISMA 2020 flow diagram
  "flextable",   # docx-ready tables
  "officer",     # docx assembly
  "janitor",     # cleaning helpers
  "readxl",      # Excel extraction sheets
  "gtsummary"    # descriptive tables for primary studies
)

# --- ADD PER-PROJECT PACKAGES HERE -----------------------------------------
# e.g. survival analysis, mixed models, specific table/figure helpers:
# pkgs <- c(pkgs, "survival", "lme4", "gtsummary")
# ---------------------------------------------------------------------------

to_install <- setdiff(pkgs, rownames(installed.packages()))
if (length(to_install)) {
  install.packages(to_install)
} else {
  message("setup.R: all listed packages already installed.")
}

# After installing, pin the environment:  renv::snapshot()