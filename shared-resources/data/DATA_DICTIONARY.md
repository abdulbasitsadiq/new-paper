# Data dictionary

Document every variable in your raw dataset(s) here so the analysis is interpretable
years from now. One row per variable.

> The example below describes the synthetic dataset that `01-clean.R` generates.
> Replace it with your real variables.

| Variable    | Type      | Units / levels                | Description                          |
|-------------|-----------|-------------------------------|--------------------------------------|
| `id`        | integer   | —                             | Participant identifier               |
| `group`     | factor    | `control`, `treatment`        | Allocation group                     |
| `age`       | integer   | years                         | Age at baseline                      |
| `biomarker` | numeric   | units (FILL-AND-VERIFY)       | Primary biomarker measurement        |

<!-- FILL-AND-VERIFY: add provenance, collection dates, coding conventions,
     missingness conventions, and any derived-variable definitions. -->