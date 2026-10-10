# Third-Party Notices

This file lists third-party software that **ShinyApps** builds on, bundles, or
otherwise delivers, together with the license each component is distributed
under. It is provided for attribution and redistribution compliance.

- **Project:** ShinyApps — a desktop app store for R/Shiny apps
- **Maintainer / copyright holder of this repository:** Zhang Yongchao
  (<zhangyongchao@nibs.ac.cn>), Copyright (c) 2026 Zhang Yongchao
- **Repository license:** GNU Affero General Public License v3.0 (AGPL-3.0) —
  see `LICENSE`

> The ShinyApps repository's own top-level license is AGPL-3.0. The built
> shell installers are an **aggregate/combined work** that includes the
> AGPL-3.0-licensed `shinyelectron` shell engine (see §1), so those installers
> as distributed are governed by AGPL-3.0. Components listed below retain their
> own licenses.

---

## 1. Shell / runtime engine

| Component | Role | License | Source |
|---|---|---|---|
| **shinyelectron** | Electron shell that packages and runs the Shiny app; provides `export()` used by `build-suite.R` | **AGPL-3.0** | <https://github.com/coatless-rpkg/shinyelectron> · fork: <https://github.com/fentouxungui/shinyelectron> (`multi-app-store` branch) |
| **Electron** | Chromium/Node desktop runtime bundled by shinyelectron | MIT | <https://github.com/electron/electron> |
| **R** (runtime 4.6.1) | Embedded R interpreter shipped by the shell | GPL-2.0-or-later | <https://www.r-project.org/> |
| **shiny** (R package) | Web/UI framework for the apps | GPL-3.0 | <https://cran.r-project.org/package=shiny> |

> Because the installers bundle the AGPL-3.0 `shinyelectron` engine, distributing
> those installers requires offering the corresponding source under AGPL-3.0
> (see §5).

---

## 2. App dependency tarballs committed under `dependency/`

These tarballs are committed to this repository and/or installed into the
bundled R library at build time.

| Bundle file | Package | License | Source |
|---|---|---|---|
| `SeuratExplorer_0.1.9.tar.gz` | SeuratExplorer | **GPL-3.0-or-later** (`GPL (>= 3)`) | <https://github.com/fentouxungui/SeuratExplorer> |
| `presto-1.1.0.tar.gz` | presto | **GPL-3.0** (`GPL-3`) | <https://github.com/immunogenomics/presto> |
| `scConvertShiny_0.1.1.tar.gz` | scConvertShiny | **MIT** (`MIT + file LICENSE`) | <https://github.com/fentouxungui/scConvertShiny> |
| `scConvert-0.2.1.tar.gz` | scConvert | **GPL-3.0** (`GPL-3 | file LICENSE`) | <https://github.com/mianaz/scConvert> |

---

## 3. Catalog apps (installable bundles, published from their own repos)

These apps are registered in `catalog/apps.yml` and delivered as on-demand
bundles from their own GitHub Releases. Each app retains its own license; the
ShinyApps shell does not relicense them.

| App | License | Source |
|---|---|---|
| SeuratExplorer | GPL-3.0-or-later | <https://github.com/fentouxungui/SeuratExplorer> |
| scConvertShiny | MIT | <https://github.com/fentouxungui/scConvertShiny> |
| iSEE | MIT | <https://github.com/fentouxungui/iSEE> · upstream <https://github.com/iSEE/iSEE> |
| UCSCXenaShiny | GPL-3.0-or-later | <https://github.com/fentouxungui/UCSCXenaShiny> |

---

## 4. CRAN / Bioconductor dependency closure

The shell and app bundles ship **prebuilt binary R packages** for their full
dependency closure (configured via `_shinyelectron.yml`; e.g. `Seurat`,
`SeuratObject`, `ggplot2`, `DT`, `hdf5r`, `shinydashboard`, `callr`, `zip`,
and their transitive dependencies). Each R package carries its own license as
recorded in its `DESCRIPTION` (commonly GPL-2, GPL-3, MIT, or BSD). The
authoritative license text for each package is its own `DESCRIPTION` / `LICENSE`
file on CRAN or Bioconductor, and its copyright remains with its authors.

Representative examples (verify per version against the package `DESCRIPTION`):

| Package | License (typical) | Source |
|---|---|---|
| Seurat / SeuratObject | GPL-3.0 | <https://satijalab.org/seurat/> |
| ggplot2 | MIT | <https://ggplot2.tidyverse.org/> |
| DT | GPL-3.0 | <https://rstudio.github.io/DT/> |
| shinydashboard | GPL-3.0 | <https://rstudio.github.io/shinydashboard/> |
| hdf5r | GPL-3.0 | <https://hhoeflin.github.io/hdf5r/> |
| presto | GPL-3.0 | <https://github.com/immunogenomics/presto> |

---

## 5. Redistribution obligations

- **AGPL-3.0 (shell).** The shell installers are object-code distributions of
  a work containing `shinyelectron` (AGPL-3.0). Under AGPL-3.0 §6 you must
  provide the **Corresponding Source** of the covered work to recipients.
  Practically: keep the source of this repository and of the `shinyelectron`
  fork publicly available, and point recipients to it (e.g. from the release
  notes or the app's About dialog). AGPL-3.0 §13 also applies if a modified
  version is ever offered over a network.
- **GPL-3.0-or-later apps (SeuratExplorer, UCSCXenaShiny) and GPL-3.0
  libraries (presto, scConvert).** When you redistribute these (as bundled
  tarballs or inside installers), you must make their corresponding source
  available and preserve their copyright/license notices. Combining them with
  the AGPL-3.0 shell is expressly permitted by AGPL-3.0 §13; the combined work
  is conveyed under AGPL-3.0 while those parts remain under their own licenses.
- **MIT components (scConvertShiny, iSEE).** Redistribution must preserve the
  copyright notice and the MIT permission notice for each.
- **Public-domain / permissive R packages.** Follow each package's own terms;
  most require only preserving notices, but include their license text where
  the package's `DESCRIPTION` requires it.

---

## 6. Notes

- License names above follow SPDX identifiers where possible.
- This notice covers the repository contents and the built artifacts at the
  time of writing. Re-verify dependency licenses whenever the packed closure,
  the `shinyelectron` version, or the app set changes.
- This document is a compliance aid, not legal advice.

For questions about licensing of this project, contact:
Zhang Yongchao <zhangyongchao@nibs.ac.cn>.
