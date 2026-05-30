# Data access & provenance

Explain where the raw data came from and how an authorised collaborator can obtain it.
**Do not put credentials, tokens, or patient-level data in this file** — it is tracked
in git. The `data/` directory itself is gitignored so the raw files never get committed.

<!-- FILL-AND-VERIFY -->

- **Source:** (registry / repository / institution, with a URL or contact)
- **Version / extract date:** (e.g. extract pulled YYYY-MM-DD)
- **Access procedure:** (data-use agreement, credentialing, IRB/ethics approval number)
- **Licence / use restrictions:** (what may and may not be shared or published)
- **Local layout:** which files go in `data/`, and what each contains

> Reproducibility note: record exactly enough that someone with legitimate access can
> reconstruct the inputs. Never commit the data itself.