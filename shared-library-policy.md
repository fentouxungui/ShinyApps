# ShinyApps shared-library and compatibility policy

Scope: how Phase 2 (catalog-driven app store) places R packages, shares them across
installed apps, and reference-counts them. This is the contract the per-app bundle
CI, `appstore` (Electron), and `build-suite.R` must agree on.

## 1. Two-layer model

- **Runtime (base) layer** — shipped with the shell, installed once, never uninstalled:
  Electron + portable **R 4.6.1** + the minimal packages the launcher/shell needs
  (e.g. `shiny`). This is the only hand-authored package set.
- **App layer** — per-app, installable/uninstallable units. A bundle zip contains:
  `app/` (Shiny resources), `rlib/` (prebuilt R package directories), `manifest.json`.

## 2. Compatibility baseline (authored, in one place)

- **R version: `4.6.1`** — the shell runtime and every published app bundle must be
  built against this exact R (binary ABI must match).
- **Must-share packages** — a short list that all apps must agree on one version of:
  `Seurat`, `SeuratObject`, `ggplot2`, `DT`, `hdf5r`. App bundles are built against the
  baseline versions.
- Everything else is **not** curated; it is resolved per app at **build time** (lockfile),
  never on the user machine.

## 3. Package placement (computed, not authored)

Each bundle ships its resolved dependency closure in `manifest.json` `packages[]`
(name + version + path + source + sha256). The client decides placement:

- **Shared library** (`<userData>/lib`): a package name lives here iff **>= 2 installed
  apps** need the same version.
- **App-private library** (`<userData>/private/<app-id>`): a package needed by exactly one
  app, **or** when an app needs a different version than the shared one.
- **Runtime R_LIBS order at run time: `<app private lib> : <shared lib>`** (private wins).

## 4. Reference counting

- **install**: for each package in the bundle closure — absent from shared -> copy in,
  `refs = [app]`; present with same version -> `refs += app`; present with a different
  version -> place in the app's private lib (do not disturb shared).
- **uninstall**: remove the app dir; for each shared package remove the app from `refs`;
  delete the shared package when `refs` becomes empty.
- **update**: unpack the new version dir; add new refs; release refs for packages the new
  version dropped; delete the old version dir **last** (rollback-safe).

## 5. Runtime

The shell spawns the bundled R with `R_LIBS` = private lib then shared lib. Package
identity comes from the `DESCRIPTION` inside each package directory; tarball filenames
are cosmetic.

## 6. Known constraints

- Cross-app version conflicts are handled by **private libs** (costs disk), not by forcing
  a shared upgrade.
- Windows: the CRAN `hdf5r` binary bundles HDF5 1.12.1, which makes scConvert conversion
  unreliable (uncatchable `H5Fclose` finalizer error). Tracked separately; not a store bug.
- Shell auto-update needs code signing to actually install (unsigned builds download but
  fail verification).
