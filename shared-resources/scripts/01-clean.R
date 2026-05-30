# 01-clean.R --------------------------------------------------------------
# STEP 1 of the analysis pipeline: turn raw inputs into a clean analytic dataset.
#
# Producer side of the architecture. This runs ONCE (and again only when the
# data or cleaning logic changes). The writing projects (paper / thesis) never
# run this — they only consume the outputs it writes into ../derived and, later,
# the figures from 03-figures.R.
#
# Paths use here::here() so they resolve from the research-programme ROOT (the
# folder that contains the `.here` sentinel) no matter your working directory.

library(here)
library(readr)
library(dplyr)

# --- FILL-AND-VERIFY -------------------------------------------------------
# Replace this synthetic example with a read of YOUR real raw data, e.g.
#   raw <- read_csv(here("shared-resources", "data", "my-cohort.csv"))
# Raw data lives in shared-resources/data/ and is GITIGNORED — never commit
# credentialed or patient-level data. See data/ACCESS.md.
# ---------------------------------------------------------------------------

# For a runnable template we synthesise a small "raw" dataset and save it to
# data/ to demonstrate the raw -> derived flow. Delete this block once you have
# real data.
set.seed(42)
n <- 200
raw <- tibble(
  id        = seq_len(n),
  group     = sample(c("control", "treatment"), n, replace = TRUE),
  age       = round(rnorm(n, mean = 61, sd = 11)),
  biomarker = round(rnorm(n, mean = 4.2, sd = 1.3), 2)
)
# inject a little messiness to make "cleaning" meaningful
raw$biomarker[sample(n, 8)] <- NA
raw$age[sample(n, 3)] <- -1  # impossible values

write_csv(raw, here("shared-resources", "data", "example-raw.csv"))

# --- Clean -----------------------------------------------------------------
clean <- raw |>
  filter(age > 0) |>                      # drop impossible ages
  filter(!is.na(biomarker)) |>            # complete cases for the biomarker
  mutate(group = factor(group, levels = c("control", "treatment")))

write_csv(clean, here("shared-resources", "derived", "example-clean.csv"))

message(sprintf("01-clean.R: wrote %d cleaned rows to derived/example-clean.csv",
                nrow(clean)))