# 03-figures.R ------------------------------------------------------------
# STEP 3: generate the figures, saved as image files into ../figures.
#
# figures/ is the PRODUCER location and the single source of truth for every
# plot. The paper and the thesis do NOT regenerate plots; a sync step copies the
# finished image files into each writing project right before it renders. This
# is why a figure looks identical in the paper and the thesis: there is one file.

library(here)
library(readr)
library(dplyr)
library(ggplot2)

clean <- read_csv(here("shared-resources", "derived", "example-clean.csv"),
                  show_col_types = FALSE)

p <- ggplot(clean, aes(x = group, y = biomarker, fill = group)) +
  geom_boxplot(width = 0.55, show.legend = FALSE, alpha = 0.85) +
  labs(
    x = NULL,
    y = "Biomarker (units)",
    title = "Example figure: biomarker by group",
    caption = "Synthetic data — replace with your analysis in 03-figures.R"
  ) +
  theme_minimal(base_size = 12)

# Save both raster (for docx/HTML) and vector (for PDF). Keep figure file names
# stable: the sync step and the documents refer to them by name.
ggsave(here("shared-resources", "figures", "example-figure.png"),
       p, width = 6, height = 4, dpi = 300)
ggsave(here("shared-resources", "figures", "example-figure.pdf"),
       p, width = 6, height = 4)

message("03-figures.R: wrote figures/example-figure.{png,pdf}")