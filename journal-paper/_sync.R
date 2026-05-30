# _sync.R — pre-render sync for the journal paper -------------------------
#
# Copies the Quarto RESOURCES this document embeds — figures and the
# bibliography — FROM the shared analysis engine INTO this project, so Quarto
# only ever sees files inside its own directory. (Quarto cannot embed an image
# or read a `bibliography:` that lives outside the project root.)
#
# Quarto runs this automatically before every render because it is declared as
# `project: pre-render:` in _quarto.yml. The working directory when it runs is
# this project's directory, so the relative paths below resolve correctly.
# You can also run it by hand:  Rscript _sync.R
#
# It does NOT run the analysis. It only copies finished outputs. If a figure is
# missing, run shared-resources/scripts/ first.

SHARED <- ".."                                   # research-programme root, one level up
fig_src <- file.path(SHARED, "shared-resources", "figures")
bib_src <- file.path(SHARED, "shared-resources", "references.bib")

dir.create("figures", showWarnings = FALSE)

# --- Figures this document needs (list only what you embed) ----------------
needed_figures <- c(
  "example-figure.png"
  # add more filenames here as your paper embeds them, e.g. "fig-flow.png"
)

for (f in needed_figures) {
  src <- file.path(fig_src, f)
  if (file.exists(src)) {
    file.copy(src, file.path("figures", f), overwrite = TRUE)
    message("synced figure: ", f)
  } else {
    warning("MISSING figure: ", src,
            " — run shared-resources/scripts/03-figures.R first", call. = FALSE)
  }
}

# --- Bibliography (synced in, never referenced with ../) -------------------
if (file.exists(bib_src)) {
  file.copy(bib_src, "references.bib", overwrite = TRUE)
  message("synced bibliography: references.bib")
} else {
  warning("MISSING bibliography: ", bib_src, call. = FALSE)
}