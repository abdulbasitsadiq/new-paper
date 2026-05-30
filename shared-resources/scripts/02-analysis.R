# 02-analysis.R -----------------------------------------------------------
# STEP 2: run the statistics on the clean dataset and save the numeric results.
#
# The writing projects read these saved results to print code-driven numbers in
# prose (so no figure or statistic is ever typed by hand). This script does NOT
# render anything and is never run by a paper/thesis render.

library(here)
library(readr)
library(dplyr)
library(broom)

clean <- read_csv(here("shared-resources", "derived", "example-clean.csv"),
                  show_col_types = FALSE)

# --- FILL-AND-VERIFY: replace with your real model / estimand ---------------
# Example: difference in biomarker between groups via a linear model.
fit <- lm(biomarker ~ group, data = clean)
tidy_fit <- broom::tidy(fit, conf.int = TRUE)

# A small, tidy results table the documents can read for inline numbers.
results <- tidy_fit |>
  filter(term == "grouptreatment") |>
  transmute(
    n             = nrow(clean),
    estimate      = estimate,
    conf_low      = conf.low,
    conf_high     = conf.high,
    p_value       = p.value
  )

write_csv(results, here("shared-resources", "derived", "example-stats.csv"))
# Save the full fit too, for documents that want more than the headline numbers.
saveRDS(fit, here("shared-resources", "derived", "example-model.rds"))

message(sprintf("02-analysis.R: estimate = %.2f (95%% CI %.2f to %.2f), p = %.3f",
                results$estimate, results$conf_low, results$conf_high, results$p_value))