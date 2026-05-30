# provenance.R -------------------------------------------------------------
# Render-time provenance stamp: ties a rendered output (PDF/docx) back to the
# exact code state that produced it. A rendered file is decoupled from the code
# once made, so each output should carry the git commit hash + render date that
# generated it (traceability recommended by the reproducibility literature).
#
# This is a helper, not a pipeline step. The writing projects source it and print
# the stamp near their title. It uses only a git system call + base R (no extra
# dependency) and DEGRADES GRACEFULLY: before the first commit (or with no git),
# it returns a clear placeholder instead of failing the render.

# Short git commit hash for `repo`, or NA if unavailable / not a repo yet.
git_short_hash <- function(repo = ".") {
  out <- suppressWarnings(tryCatch(
    system2("git", c("-C", repo, "rev-parse", "--short", "HEAD"),
            stdout = TRUE, stderr = FALSE),
    error = function(e) NULL
  ))
  status <- attr(out, "status")
  if (is.null(out) || length(out) == 0 ||
      (!is.null(status) && status != 0) || !nzchar(out[[1]])) {
    return(NA_character_)
  }
  out[[1]]
}

# One-line stamp for the document, e.g.
#   "Generated from commit a8bb0d4 on 2026-05-29"
# Falls back to a clear message before the project is a committed git repo.
provenance_stamp <- function(repo = ".") {
  h <- git_short_hash(repo)
  commit <- if (is.na(h)) "uncommitted (not a git repo yet)" else h
  sprintf("Generated from commit %s on %s", commit, format(Sys.Date(), "%Y-%m-%d"))
}