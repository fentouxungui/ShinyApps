# ShinyApps R Runtime Compatibility Plan

Status: foundation implemented; runtime packs are the intended long-term model.

This document is the reference for adding a new R version without breaking
installed apps. It covers the shell, app bundles, catalog, local state, and CI.

## 1. The problem

The shell currently ships one portable R (4.6.1). Every app bundle contains
binary R packages compiled against that runtime. Two assumptions are baked in:

- the shell has exactly one R runtime;
- the shared/private package libraries are global and keyed only by package name.

R patch releases (`4.6.1` -> `4.6.2`) are normally ABI-compatible, but a new
minor (`4.6` -> `4.7`) is a different runtime. CRAN binaries are built per R
version, and packages compiled for 4.6 must not be loaded into 4.7. Replacing
the shell runtime in place would therefore break every installed app.

A second collision is subtler: a global shared library keyed by `<package>` or
`<package>@<version>` can mix packages compiled for different R minors. The
library must be scoped by runtime ABI.

## 2. Compatibility levels

| Change | Runtime treatment | App action |
|---|---|---|
| `4.6.1` -> `4.6.2` | Update the `r-4.6` runtime pack in place | No rebuild; run smoke tests |
| `4.6` -> `4.7` | Add a new `r-4.7` runtime pack; keep `r-4.6` | Rebuild app bundles on 4.7 |
| `4.x` -> `5.x` | Add a new major runtime; update shell ABI checks | Rebuild all apps; migration plan |
| macOS/Windows OS change | New runtime pack release | Re-test and re-sign |

The stable selection key is the **major.minor ABI** (`4.6`), not the patch
version. The exact version (`4.6.1`) is recorded for diagnostics and
reproducibility.

## 3. Target architecture

### 3.1 Runtime packs

Each runtime is an independent, versioned component:

```text
runtimes/r-4.6/
  <R installation>          # portable R
  library/                  # base/recommended + shell packages for this ABI
  runtime.json              # id, abi, version, platform, sha256, signature
```

The shell installer ships one baseline runtime. Additional runtime packs can be
downloaded on demand, verified, and installed under the writable data root.
Runtime packs are immutable for a given id/version.

Runtime pack metadata is published under `catalog.json` `runtimes[]` with:
`id`, `abi`, `version`, `platform`, `arch`, `url`, `size`, `sha256`,
`min_shell_version`, and `min_os`. The publisher currently forwards an optional
top-level `runtimes: []` from `catalog/apps.yml`; the shell-side downloader is
Phase 1.

### 3.2 Runtime fields

`runtime_id` is `r-<major.minor>` (for example `r-4.6`). `r_abi` is
`<major.minor>`. `r_version` is the exact R version used for the build.

App bundle `manifest.json`:

```json
{
  "schema": 1,
  "r_version": "4.6.1",
  "r_abi": "4.6",
  "runtime": "r-shiny"
}
```

`runtime` keeps its existing meaning (`r-shiny` or `py-shiny`); the R runtime id
is derived from `r_abi`. Old bundles without `r_abi` derive it from
`r_version`.

Catalog entry:

```json
{
  "id": "seurat-explorer",
  "r_version": "4.6.1",
  "r_abi": "4.6"
}
```

`r_abi` is optional; the client derives it from `r_version` when absent.

### 3.3 Library layout

All compiled packages are scoped by runtime:

```text
<dataRoot>/runtimes/r-4.6/R
<dataRoot>/runtimes/r-4.6/library
<dataRoot>/lib/r-4.6/<package>                 # shared, ref-counted
<dataRoot>/private/r-4.6/<appId>/<package>      # per-app conflicts
<dataRoot>/apps/<appId>/<version>               # bundle/app code (runtime-neutral)
```

The app runs with:

```text
R_LIBS = private/r-4.6/<appId> : lib/r-4.6
R_HOME = runtimes/r-4.6 (or the shell's baseline runtime)
```

The current shell moves the baseline runtime to the same model internally.
Existing schema-1 installs are migrated to `r-4.6` on first launch.

### 3.4 Local state

`state.json` records the runtime for each app and keeps shared packages scoped
by runtime:

```json
{
  "schema": 2,
  "apps": {
    "seurat-explorer": {
      "version": "0.1.11",
      "platform": "mac-arm64",
      "dir": "/.../apps/seurat-explorer/0.1.11",
      "packages": ["Seurat", "data.table"],
      "runtime": "r-4.6",
      "r_abi": "4.6"
    }
  },
  "shared": {
    "r-4.6/data.table": {
      "version": "1.17.0",
      "refs": ["seurat-explorer"],
      "runtime": "r-4.6",
      "r_abi": "4.6"
    }
  },
  "runtimes": {
    "r-4.6": {
      "abi": "4.6",
      "version": "4.6.1",
      "source": "shell"
    }
  }
}
```

An installed runtime pack records `path`, `rscript`, `library`, and
`source: "downloaded"` in `runtimes`.

### 3.5 Shell responsibilities

1. Read the app/catalog `r_abi`.
2. Resolve an installed runtime with that ABI.
3. If absent, offer to download the runtime pack (or tell the user to update
   ShinyApps).
4. Launch the backend with that runtime's `Rscript`, `R_HOME`, and library.
5. Never remove a runtime while an installed app references it.
6. Keep the baseline runtime until all supported apps have migrated.

The shell must not silently substitute one R minor for another.

### 3.6 Catalog responsibilities

- Publish `r_abi` for new bundles (optional for old ones; derived from `r_version`).
- Keep app versions aligned with the runtime they were built for.
- New bundles are named:

  ```text
  <id>-<version>-<platform>-r<abi>.zip    # e.g. seurat-explorer-0.2.0-mac-arm64-r4.6.zip
  ```

  Legacy unsuffixed `<id>-<version>-<platform>.zip` assets remain supported.
- `catalog.json` carries both a legacy flat map and a runtime-aware map:

  ```json
  "artifacts": {
    "mac-arm64": { "url": "...", "sha256": "...", "r_abi": "4.6" }
  },
  "artifacts_by_runtime": {
    "mac-arm64": {
      "r-4.6": { "url": "...", "sha256": "...", "r_abi": "4.6" },
      "r-4.7": { "url": "...", "sha256": "...", "r_abi": "4.7" }
    }
  }
  ```

  The new shell prefers `artifacts_by_runtime`; older shells read the flat
  `artifacts` map, which points at the app's declared/default ABI. If an app has
  only a 4.7 artifact and declares 4.6, the flat map has no entry, so an old
  shell marks it unavailable instead of downloading a bundle it cannot run.
- `publish-catalog` parses both filename forms and builds both maps.

## 4. Build pipeline

Every app bundle must declare its runtime. The onboarding workflow template does
this with:

```r
r_version <- Sys.getenv("R_VERSION")
r_abi <- paste(head(strsplit(r_version, ".", fixed = TRUE)[[1]], 2), collapse = ".")
```

Before release, verify this against the runtime that actually compiled the
packages:

```r
actual <- paste(R.version$major, R.version$minor, sep = ".")
stopifnot(identical(actual, r_version))
```

Better still, derive `r_abi` from `R.version` and inspect each
`rlib/<pkg>/DESCRIPTION` `Built` field. A manifest must never claim an ABI that
the shipped `.so`/`.dll` files were not built for.

The build matrix should eventually contain one row per supported runtime:

```yaml
matrix:
  include:
    - { os: windows-latest, platform: "win-x64", r_version: "4.6.1", r_abi: "4.6" }
    - { os: macos-15,       platform: "mac-arm64", r_version: "4.6.1", r_abi: "4.6" }
```

For each runtime:

- pin R and the CRAN/Bioconductor snapshot;
- build the app closure with that runtime's portable R;
- exclude base/recommended packages;
- re-sign macOS Mach-O files after portable-R `.portable` patching;
- run the clean-library smoke test;
- write `r_version` and `r_abi` into `manifest.json`.

Runtime packs themselves must be checksummed and, on macOS, signed after any
Mach-O edits. A runtime pack is not just a copied R directory; it is a release
artifact.

## 5. Decisions

- **Runtime delivery:** Plan B — runtime packs downloaded on demand; the shell
  keeps its baseline runtime (currently `r-4.6`) and adds `r-4.7` as a pack.
- **Catalog artifacts:** full runtime dimension via `artifacts_by_runtime`, with
  the legacy flat `artifacts` map retained for older shells.
- **Downgrade:** not supported after the state-schema-2 migration. Update and
  rollback paths must say so explicitly; users who force an older shell must
  reset/reinstall.
- **Support diagnostics:** report payloads and app logs include the runtime id,
  ABI, runtime version, and installed runtimes.

## 6. Migration plan

### Phase 0 — foundation (now)

- Define `r_abi` / `runtime_id` in schemas.
- Scope shared/private libraries by runtime.
- Record `runtime` and `r_abi` in local state.
- Migrate schema-1 state and package directories to `r-4.6` once; keep a one-time
  `state.json.v1.bak` backup before changing anything.
- Pass the selected runtime path/Rscript/library to the R backend.
- Publish and select runtime-aware catalog artifacts, while retaining the legacy
  flat artifact map for old shells.
- Keep 4.6.1 as the baseline; no user-visible change.

### Phase 1 — runtime pack manager

- Add a runtime registry and install/download/remove UI.
- Ship baseline 4.6 in the shell; allow an additional 4.7 pack.
- Add checksum, size, platform, and code-signature verification.
- Add a canary app built on 4.7; test both runtimes on Windows and macOS.

### Phase 2 — app migration

- Rebuild supported apps on 4.7 and publish new app versions with `r_abi: "4.7"`.
- The catalog may keep the previous app version available for old shells.
- Users with the new shell download/install the 4.7 runtime on demand.
- Old apps continue on 4.6; do not remove 4.6.

### Phase 3 — retirement

- Announce a support window (for example 24 months, or two R minors).
- Warn users when an app still uses a runtime near end of support.
- Stop offering new installs that require the retired runtime.
- Remove the runtime pack only after no installed app references it, or after a
  clearly documented major-version cleanup.

## 7. Deprecation and support policy

- **Baseline runtime**: the runtime shipped in the shell; supported until the
  next planned major migration.
- **Patch updates**: update the baseline runtime in place (`4.6.1` -> `4.6.2`)
  after smoke tests; app bundles keep `r_abi: "4.6"`.
- **Minor transition**: add a new runtime; do not replace the old one.
- **End of support**: stop updates/security fixes for the old runtime; existing
  installs remain runnable if the pack is retained. State the policy in the
  release notes and catalog UI.
- **Security**: if an R CVE affects an old runtime, either ship a patched patch
  release for that ABI or accelerate app migration; do not silently upgrade the
  ABI.

## 8. Operations runbook: adding R 4.7

1. Build a portable R 4.7 pack for each platform/arch; record sha256; sign
   macOS binaries.
2. Add `r-4.7` to the shell's runtime registry and supported-runtime list; keep
   `r-4.6`.
3. Update the app bundle workflow matrix to `R_VERSION=4.7.x` and rebuild the
   canary app; publish a test bundle with `r_abi: "4.7"`.
4. Install the test bundle on clean Windows/macOS machines; verify:
   - runtime selection;
   - package loading from `lib/r-4.7`;
   - app data still opens;
   - uninstall/update refcounts;
   - signature verification.
5. Rebuild production apps on 4.7 and publish new versions; keep 4.6 app
   versions for existing installs.
6. Update the catalog and documentation; announce the migration window.
7. After the support window, retire 4.6 according to the policy above.

## 9. Failure modes and diagnostics

- **`app needs the R x.y runtime, but it is not installed`**: the bundle/catalog
  declares an ABI with no installed runtime. Install the runtime pack or update
  the shell.
- **`bundle was built for R 4.6; the r-4.7 runtime is R 4.7`**: an app bundle was
  launched against the wrong runtime; the library layout or manifest is wrong.
- **Package load failure after a shell update**: check that the app's `runtime`
  in `state.json` matches an installed runtime; check `lib/<runtime>/<pkg>`.
- **Shared package disappears after switching runtimes**: refcounts must be
  released per runtime; run the cleanup pass and inspect `state.shared` keys.
- **macOS `Code Signature Invalid`**: re-sign the runtime/app Mach-O files; see
  the onboarding skill's `references/macos-portability.md`.
- **`STATE_SCHEMA_TOO_NEW`**: the data was written by a newer shell. Downgrading
  is not supported; install the newer ShinyApps build, or back up and reset local
  data. The new shell refuses to read a future state rather than corrupting it.

## 10. Rules

Do:

- keep old runtimes installed until no app uses them;
- scope every compiled package by runtime;
- record exact R version and ABI in every manifest;
- test a clean install on Windows and macOS for each runtime;
- verify checksums and signatures.

Do not:

- replace the shell's R runtime in place while old apps exist;
- assume a 4.6 binary loads in 4.7;
- share one package library across R minors;
- rely on `renv` alone (it locks packages, not the R runtime);
- use the user's system R as the compatibility mechanism;
- remove a runtime while an installed app references it.

## 11. Validation checklist

Before shipping a shell or app bundle:

- `node --check` on `appstore.js` and `native-r.js`.
- Parse `build-runtime.R` with the pinned R.
- Validate `catalog.schema.json`, `manifest.schema.json`, `state.schema.json` as JSON.
- Build the shell; start it against a copy of an existing data root; verify
  `state.json` migrates to schema 2, `state.json.v1.bak` exists, and packages
  moved under `lib/r-4.6`.
- Install, run, update, and uninstall an app; inspect `state.shared` keys and
  `private/r-4.6/<appId>`.
- Build a new app bundle and confirm `manifest.json` has the expected
  `r_version` and `r_abi`; confirm `manifest.packages` names resolve in the
  selected runtime.
- On macOS, run `codesign --verify` on the bundle/runtime after the re-signing
  step.

## 12. Open decisions / future work

These are intentionally not part of the Phase 0 foundation and must be resolved
before a second runtime is offered broadly.

### Runtime pack distribution

- Define where runtime packs live (GitHub Releases vs a separate runtime
  catalog) and their release workflow.
- Add `pack_schema`, `min_shell_version`, `min_os`, `platform`, `arch`,
  `sha256`, and a signature to every pack.
- Build packs per platform/arch; macOS packs must be signed/notarized after all
  Mach-O edits.
- Add download/resume/progress/cancel/offline/manual-import behavior.
- Add disk-space checks and an atomic install/update path; never replace files
  while an R process is using them.
- Add pack update and removal, blocked by app refcounts.
- Add a runtime registry in `catalog.json` or a dedicated `runtimes.json`.

### Data root, reset and storage

- `wipeAllLocalData`, `resetLocal`, and `change-data-root` must include
  `runtimes/`.
- Rewrite `state.runtimes[].path`, `rscript`, and `library` when the data root
  moves.
- Include runtime packs in `usage`, `cleanup`, and the Storage panel.
- Decide whether uninstall/reset keeps downloaded runtimes for other apps.

### State and migration hardening

- Write `state.json` atomically (`.tmp` + rename).
- Add a migration journal and a recovery path for interrupted moves.
- Test migration with locked files (Windows), external/network data roots, and
  missing package directories.
- Make schema-2 downgrade behavior explicit in the UI and update/rollback code;
  an older shell must not silently see a state it cannot use.
- Add a guard for future `state.schema` values newer than the current shell.

### Platform/architecture

- Scope package libraries by platform/arch in addition to runtime, or detect a
  platform change in a moved/synced data root and refuse to load foreign
  binaries.
- Record and enforce runtime-pack `min_os`; keep 4.6 available for older macOS
  and Windows.
- Test x64 and arm64 on Windows/macOS, including Rosetta and Apple Silicon.

### Validation and supply chain

- Derive `r_version`/`r_abi` from the actual R that built the packages, not only
  the `R_VERSION` environment variable.
- Inspect `rlib/<pkg>/DESCRIPTION` `Built` fields and reject mismatched
  compiled packages.
- Add CI tests for ABI labels, package metadata, and clean-library loading.
- Add signing/checksum verification for runtime packs and app bundles.

### Product/UX

- Add a runtime selection/download prompt with size, progress, cancel, offline,
  and failure messaging.
- Show "requires R x.y runtime" on app cards and Settings; explain why an app is
  unavailable.
- Runtime info (id, ABI, version, source) is now included in crash report
  payloads and app logs; keep it in sync when adding runtime packs.
- Add support diagnostics and a runtime support matrix in the user guide.
- Add a canary app and a Windows/macOS test matrix.
- Decide whether old catalog app versions are retained for old shells, or
  require a shell update before installing new-runtime apps.
- Decide how an installed app behaves when the catalog drops its runtime
  artifact but the old runtime is still installed: Run should remain available,
  while Update is unavailable until a compatible artifact/runtime exists.
- Define the R support window, security policy, and communication for EOL.
- Test app data (RDS/qs2/Seurat objects) across runtime upgrades and document
  backup/restore.
- Keep app-specific vendored binaries (e.g. Cairo) uniquely versioned within a
  runtime; runtime scoping does not solve same-ABI package collisions.

## 13. Related code

- `shinyelectron/inst/electron/backends/appstore.js` — runtime selection,
  ABI-scoped libraries, state migration, refcounts.
- `shinyelectron/inst/electron/backends/native-r.js` — selected runtime
  `Rscript`/library launch.
- `shinyelectron/inst/electron/shared/main.js` — passes the shell runtime root
  and backend runtime fields; catalog compatibility display.
- `ShinyApps/schemas/*.schema.json` — catalog, manifest, state contracts.
- `ShinyApps/.github/workflows/publish-catalog.yml` — runtime-aware artifact map
  and runtime pack metadata.
- `ShinyApps/catalog/apps.yml` — app runtime declarations and optional runtime
  pack list.
- `shinyapps-onboarding/assets/build-app-bundle.yml` — app bundle metadata and
  macOS re-signing.
