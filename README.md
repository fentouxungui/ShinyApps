# ShinyApps

**English** | [简体中文](README.zh-CN.md) | [Wiki](https://github.com/fentouxungui/ShinyApps/wiki)

[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS-blue)](#) [![R](https://img.shields.io/badge/R-4.6.1-276DC3?logo=r)](#) [![Built on](https://img.shields.io/badge/built%20on-shinyelectron-8A2BE2)](https://github.com/coatless-rpkg/shinyelectron)

> **ShinyApps is a desktop app store for R/Shiny apps.** It ships one lightweight
> Electron shell, lets users **install, run, update, and uninstall** bundled Shiny
> apps on demand from an online catalog, and runs them one at a time inside a
> shared R runtime.

Instead of packaging every app into its own heavyweight desktop installer, ShinyApps
separates a **thin shell** from **installable app bundles**: any Shiny app can be
added later without rebuilding or redistributing the shell.

Currently integrated: **SeuratExplorer** and **scConvertShiny**.

---

## ✨ Features

- **App-store model** — a card launcher with `Install → Run / Uninstall`, plus per-app `Update`.
- **Bring any Shiny app** — bundle it as `app/ + rlib/ + manifest.json`, publish it as a GitHub Release asset, and register it in the catalog. No shell rebuild needed.
- **Auto version check on every launch** — at startup ShinyApps compares each app's catalog version with what is installed, so new app versions show a one-click **Update**.
- **Shared R library with reference counting** — packages used by ≥ 2 apps live once in a shared library; app-private/conflicting versions go to a private library. (In a real run, **133 of 160 packages** were shared between two apps.)
- **Reproducible bundles** — apps ship **prebuilt binary R packages** pinned to **R 4.6.1**, each with a `sha256`. No compiler or R toolchain on the user's machine.
- **Robust downloads** — HTTP Range resume, retries, idle timeout, size + `sha256` verification, real progress, zero-npm-dependency ZIP extractor.
- **Two independent update channels** — the shell updates via `electron-updater`; each app updates via the catalog.
- **Clean process lifecycle** — only one app runs at a time; returning to the launcher kills the whole R process tree (Windows `taskkill /T /F`).
- **Cross-platform** — Windows (`win-x64`) and macOS (`mac-arm64`).
- **Card links to each app's homepage** — hover an app name for “click to learn more”; click it to open the app's `homepage` in your browser.
- **Visible install pipeline** — the card shows the current step (download % → verify → install) and, on failure, exactly which step failed and why (e.g. “size mismatch: catalog 12934112 bytes, downloaded 0 bytes”).
- **Per-app Help / About** — the App menu label, Help > Documentation, and the About dialog (including Visit Website / Email / Check for Updates) follow the running app, using its catalog `docs` / `homepage` / `email` / `author` / `copyright`.

## 🚀 Quick start (users)

1. Download `shinyapps-Setup-<version>-x64.exe` (Windows) or `.dmg` (macOS) from [**Releases**](https://github.com/fentouxungui/ShinyApps/releases).
2. Launch **ShinyApps** — the launcher shows a card per available app.
3. Click **Install**, then **Run**. Use **Apps → Back to Launcher** (or `Ctrl/Cmd+L`) to return; unsaved work is confirmed first.
4. **Every time ShinyApps starts, it automatically checks each app's latest version** against the online catalog. If a newer version is available, the card shows **Update** — click it for a one-click upgrade (the app is stopped, fetched, verified, and swapped in place).

> Shell auto-update only installs on signed builds; unsigned builds can download but Windows/macOS will refuse to apply the update.

## 🧩 For app developers: add your Shiny app

Two ways to integrate:

**A. Store / on-demand (recommended).** In your own repo, add a bundle workflow that produces
`<id>-<version>-<platform>.zip` (per platform) and publishes it to a Release, then register the app
in this repo's `catalog/apps.yml`. Users install it on demand. **No change to the shell.**

```
<id>-<version>-<platform>.zip
└─ app/         # your Shiny entry (app.R)
└─ rlib/        # prebuilt dependency closure (binary R packages)
└─ manifest.json
```

**B. Bake-in.** Put your `app.R` and dependency tarballs under `apps/` and `dependency/` in this
repo and rebuild the shell. The app ships inside the installer (offline, no download) but a larger
installer and a shell re-release per change.

The app must satisfy a small contract: its entry returns a **`shinyApp` object** (it must not call
`runApp()` itself), build as a standard R source package, and target **R 4.6.1**.

👉 Full guide: **[User Manual (EN)](https://github.com/fentouxungui/ShinyApps/wiki/ManualEN)** · **[使用手册（中文）](https://github.com/fentouxungui/ShinyApps/wiki/ManualZH)**.

## 🏗️ How it works

### Three layers

```
Tier 0  Shell + portable R 4.6.1 + minimal deps      shipped once, never uninstalled
Tier 1  Shared R library   <userData>/lib             packages needed by >= 2 apps (ref-counted)
Tier 2  Private R library  <userData>/private/<id>    single-app or version-conflicting packages
```

At runtime: `R_LIBS = private lib : shared lib`.

### Data flow

```
App repo CI ──publishes──▶ GitHub Release  (bundle zips + sha256)
                                │
ShinyApps catalog/apps.yml ─▶ publish-catalog.yml ─▶ gh-pages/catalog.json
                                │
Client shell ──fetch catalog──▶ install bundle ─▶ run with R_LIBS(private:shared)
```

### Repositories

| Repo | Role |
|---|---|
| **`ShinyApps`** (this repo) | Shell config, catalog, schemas, icons, build script, workflows |
| [`shinyelectron@multi-app-store`](https://github.com/fentouxungui/shinyelectron/tree/multi-app-store) | Electron main process, launcher, store engine, R backend |
| [`SeuratExplorer`](https://github.com/fentouxungui/SeuratExplorer), [`scConvertShiny`](https://github.com/fentouxungui/scConvertShiny) | Apps + their bundle CI |

### Key files

```
_shinyelectron.yml          # shell config (runtime strategy, deps, apps[], updates)
build-suite.R               # build the shell; version derived from the release tag
catalog/apps.yml            # the single hand-maintained app registry
schemas/*.json              # catalog / manifest / state contracts
.github/workflows/
  build-desktop.yml         # build shell installers + release
  publish-catalog.yml       # generate catalog.json + publish icons to gh-pages
```

### Workflows

| Workflow | Trigger | Output |
|---|---|---|
| **Build ShinyApps desktop** | tag `v*` / manual | Shell installers + `latest*.yml` → Release |
| **Publish catalog** | every 10 min / manual / `bundle-updated` dispatch / edits to `apps.yml` or `icons/` | `catalog.json` + `icons/` on `gh-pages` |
| **Build app bundle** (each app repo) | Release published / manual | `<id>-<version>-<platform>.zip` → that app's Release |

## ⚖️ Pros and cons

### ✅ Pros

- **Extensible without redeploying the shell** — new apps are just new catalog entries + Release bundles.
- **Small first download** — users only fetch the apps they choose; the shell is shared.
- **Real disk savings through sharing** — one shared library, reference-counted (two apps shared 133/160 packages in testing).
- **No compiler on the user machine** — prebuilt binaries + pinned R runtime; installs are fast and offline-capable after download.
- **Reproducible & verifiable** — every artifact carries a `sha256`; the catalog is the single source of truth.
- **Clean isolation** — per-app private libraries resolve version conflicts without forcing upgrades.

### ⚠️ Cons and trade-offs

- **One app at a time** — returning to the launcher stops the current app; **unsaved analysis is lost** (a confirmation dialog guards this). It is not a multi-window hub.
- **Install-time downloads can be large** — each app bundle is tens to hundreds of MB (it contains compiled dependencies). Shared packages reduce the incremental cost for later apps, but the first install of a heavy app is still large.
- **Per-platform builds required** — Windows binaries must be built on Windows; each platform needs its own bundle. Only `win-x64` and `mac-arm64` are produced today.
- **Tight version coupling** — every bundle must be built against the same R version as the shell (currently 4.6.1).
- **Native dependencies are the hard part** — e.g. on Windows, `scConvert` conversion is limited by the CRAN `hdf5r`/HDF5 1.12 stack.
- **Infrastructure-bound** — relies on GitHub Actions, Releases, and Pages, and requires code signing for shell auto-update.
- **License obligations** — the shell builds on **AGPL-3.0** `shinyelectron`; bundled apps bring their own licenses (e.g. GPL-3.0, MIT).

## 📦 Current apps

| App | Description | License |
|---|---|---|
| [SeuratExplorer](https://github.com/fentouxungui/SeuratExplorer) | Explore scRNA-seq data processed in Seurat | GPL-3.0-or-later |
| [scConvertShiny](https://github.com/fentouxungui/scConvertShiny) | Convert single-cell formats (h5ad / h5Seurat / Loom / MuData / Seurat / SCE / Zarr) | MIT |

## 🗺️ Roadmap

- [ ] Code signing for shell auto-update (Windows / macOS)
- [ ] Trim disk duplication (remove bundle `rlib/` after linking; prune download cache)
- [ ] Auto-refresh the catalog on app release (`repository_dispatch`)
- [ ] Resolve the Windows `scConvert` HDF5 limitation
- [ ] Additional platforms and apps

## 📚 Documentation

Full manual on the **[Wiki](https://github.com/fentouxungui/ShinyApps/wiki)** — available in **English** and **中文**:

- 👉 **[User Manual (EN)](https://github.com/fentouxungui/ShinyApps/wiki/ManualEN)** · **[使用手册（中文）](https://github.com/fentouxungui/ShinyApps/wiki/ManualZH)**
- **User Guide** — install, launcher, run/update/uninstall, data locations
- **Developer Guide** — bundling contract, catalog registration, icons
- **Maintainer Guide** — repository layout and each workflow
- **Release process** — ship a shell, ship an app, update icons
- **FAQ / Troubleshooting** — known issues and fixes
- **Known limits / roadmap** — open issues and planned work

## 🙏 Credits & license

Built on [shinyelectron](https://github.com/coatless-rpkg/shinyelectron) (AGPL-3.0). The ShinyApps
repository also bundles/calls third-party components — see `shared-library-policy.md` and each app
repository for details. Add a top-level `LICENSE` and third-party notices before distributing.

---

*Maintained by Zhang Yongchao. Contributions and new app bundles are welcome.*
