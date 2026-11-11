# ShinyApps 三个仓库的定位与关系

> 面向维护者的速览：`fentouxungui/ShinyApps`、`fentouxungui/shinyapps-onboarding`、`fentouxungui/shinyelectron`（`multi-app-store` 分支）。
> 用途：重装 Open-Science 前留存上下文，避免重新推导架构。
> 更新时间：2026-11-11。基于三仓库当前代码（`ShinyApps@main`、`shinyelectron@multi-app-store`、`shinyapps-onboarding@main`）与线上 `catalog.json` 核对。

## 0. 一句话版本

| 仓库 | 一句话定位 | 类比 |
|---|---|---|
| `shinyelectron`（`multi-app-store` 分支） | 把 Shiny 应用变成桌面程序的**引擎/框架**（R 包 + Electron 模板） | 操作系统内核 |
| `ShinyApps` | 用 shinyelectron 构建的**桌面应用商店产品**：外壳配置、catalog、图标、发布流水线 | 发行版 + 应用商店 |
| `shinyapps-onboarding` | 把任意 Shiny 仓库**批量上架**到商店的维护者工具链（Skill 形态） | 上架流水线 / 施工手册 |

---

## 1. `shinyelectron`（`multi-app-store` 分支）——引擎

**是什么**：一个 R 包（`DESCRIPTION`: `Package: shinyelectron`, `Version: 0.2.1`, `License: AGPL (>= 3)`），把 R/Python 的 Shiny 应用导出为 Electron 桌面应用。上游为 `coatless-rpkg/shinyelectron`，本仓库是**多应用商店分支**。

**核心内容**

- `inst/electron/shared/`
  - `main.js`：Electron 主进程（模板，构建时用 Whisker 渲染变量）。负责窗口/菜单/托盘、设置、更新检查、catalog 源、应用数据目录（可迁移）、下载镜像、日志与崩溃上报。
  - `launcher.html`：商店启动器：`Installed / All / Updates / Running` 四个 tab、搜索、标签筛选、收藏/最近使用/排序、Quick Run、Install/Run/Update/Uninstall、Storage、Settings、Refresh Catalog。
  - `lifecycle.html`：启动/关闭阶段的 splash 与错误页。
  - `preload.js`：`contextBridge` 暴露的 IPC 白名单。
- `inst/electron/backends/`
  - `appstore.js`：**商店引擎**。catalog 拉取与磁盘缓存（`catalog-cache.json`）、图标缓存（`icons/index.json` + PNG）、下载/镜像/校验/解压、`state.json`、共享库 `lib/` 与私有库 `private/<id>` 的引用计数、使用量/清理/重置、磁盘空间查询。
  - `native-r.js` / `native-py.js` / `container.js` / `shinylive.js`：运行时后端（`.libPaths` 组装、启动探测、停止进程树）。
  - `runtime-downloader.js`、`unzip-worker.js`、`dependency-checker.js`、`utils.js`。
- `R/`：构建期工具（`export()`、`export_multi_app()`、`_shinyelectron.yml` 解析/校验、构建目标、图标与打包、NSIS/签名、自动更新、模板变量、`wizard()`）。
- 测试：`tests/testthat/`（R 侧单元测试）、`tests/js/`（`node:test`，含 `appstore-icon-cache.test.js`）、`e2e-tests/`（Playwright）。

**`multi-app-store` 分支额外提供**：多应用启动器、catalog 安装、共享/私有 R 库、Bundle 安装（zip / URL / 下载镜像）、Storage / Clean up / Reset、应用级更新通道、按应用 Help/About、数据根迁移、图标缓存。

**图标缓存（2026-11 变化）**

- 图标按 **URL 键控**缓存在 `<dataRoot>/icons/`。
- URL 不变但内容变化时，客户端最多每 **10 分钟**用 `If-None-Match` / `If-Modified-Since` 条件请求重验证：`304` 保留缓存，`200` 替换；URL 变化则立即重新下载。
- 因此发布侧把本地图标 URL 加上内容哈希（见 `ShinyApps` 的 `publish-catalog.yml`）就能让所有客户端立即失效旧缓存，无需清理本地文件。

**谁应该改它**：启动器 UI、商店逻辑、安装/卸载/清理语义、图标/catalog 缓存、数据目录迁移、后端启动参数、`.libPaths` 策略、Electron 主进程行为。

---

## 2. `ShinyApps`——产品与商店端

**是什么**：面向用户的 **ShinyApps Store** 桌面应用商店。仓库本身**不实现** Electron 主进程，而是提供：外壳构建配置 + 应用目录 + 图标 + CI + 发布产物（安装包）与 gh-pages 上的 `catalog.json`。

**核心内容**

| 路径 | 作用 |
|---|---|
| `_shinyelectron.yml` | 外壳配置：`app.name: ShinyApps Store`、`app.slug: shinyapps`、`runtime_strategy: bundled`、`dependencies.r.version: 4.6.1`、`extra_packages: [shiny, zip]`、`updates:`（GitHub provider）、`installer:`（`com.shinyapps.desktop`、旧快捷方式清理）、`tray`/`menu`、内嵌 `welcome`/`about` |
| `build-suite.R` | 调用 shinyelectron 的多应用导出，生成 shell；`APP_VERSION`（release tag）会写回 `_shinyelectron.yml` 的 `app.version`，不要手工改版本 |
| `catalog/apps.yml` | **唯一手工维护的应用注册表**（`schema: 1`、`shell_min_version: 0.1.0`）。每项含 id/name/repo/author/license/icon/r_version/tags 等；当前 **128 个 app** |
| `schemas/` | 数据契约：`catalog.schema.json`、`manifest.schema.json`、`state.schema.json`；另有 `catalog.json` 示例（示例中的 icon 是未加哈希的原始 URL） |
| `icons/` | 每个 app 的图标 PNG（规范要求 512×512；当前 129 个 PNG）+ `ico/`、`mac/`（shell 安装包图标）；发布时映射到 `https://fentouxungui.github.io/ShinyApps/icons/<id>.png` |
| `.github/workflows/build-desktop.yml` | 推送 `v*` tag 或手动指定 tag 时，在 `windows-latest` + `macos-latest` 上构建；Node 24；用 `pak` 安装 `fentouxungui/shinyelectron@multi-app-store`；生成 NSIS/DMG 安装包并发布 Release |
| `.github/workflows/publish-catalog.yml` | 每 10 分钟 / 手动 / `bundle-updated` / `main` 上 `apps.yml`、`render_readme.py`、`icons/**` 变更时运行：读取各 app 最新 Release 资产 → 生成 `catalog.json`（version + 各平台 url/size/sha256）→ 渲染 README → 发布 `catalog.json`、`README.md`、`icons/` 到 `gh-pages` |
| `catalog/render_readme.py` | 从 `catalog.json` 确定性渲染 `catalog/README.md`（只使用 catalog 的 `updated_at`，无额外时间戳） |
| `apps/` | 内嵌的 `welcome` / `about` 小应用（保证多应用构建成立） |
| `userguide.html` | 内置用户手册 |
| `shared-library-policy.md` / `SomeConcerns.md` / `THIRD-PARTY-NOTICES.md` | 共享库策略、已知问题、第三方声明 |

**图标 URL 哈希（2026-11 新增）**

`publish-catalog.yml` 生成 `catalog.json` 时，会对 `https://fentouxungui.github.io/ShinyApps/icons/` 下的图标追加内容哈希：

```
https://fentouxungui.github.io/ShinyApps/icons/seurat-explorer.png?v=a46e55ac979b
```

哈希取 `icons/<file>` 的 SHA-256 前 12 位。`catalog/apps.yml` 里仍写不带哈希的原始 URL；哈希只存在于生成的 `catalog.json`。这样替换 PNG 后 URL 会变化，客户端的 URL 键控缓存立即失效；同时 `catalog.json` 因内容变化会被重新发布（工作流比较时忽略 `updated_at`，但图标 URL 已变）。

**产物**

- Release：Windows NSIS 安装包 + macOS DMG（文件名由 slug/arch 决定）。
- gh-pages：`catalog.json`（带 `?v=<hash>` 图标 URL）、`icons/`、`README.md`、`_config.yml`。

**定位**：品牌与分发层。新增 app 只需改 `catalog/apps.yml` + 放图标，**不必重建 shell**；替换图标也只需替换 `icons/<id>.png` 并等发布流水线更新 `catalog.json`。

---

## 3. `shinyapps-onboarding`——上架工具链

**是什么**：MIT 许可的维护者工具箱（同时以 Open-Science Skill `shinyapps-onboarding` 的形式存在），把「任意 Shiny 仓库」变成「商店里可安装的 app」，端到端自动化：

```
可行性评估 → fork → 生成 bundle workflow → tag/Release → catalog 条目 + 图标 → (可选) 上游 PR
```

**路线 A（本生态唯一在用的路线）**：不重建 shell。每个 app 仓库自带一个 GitHub Actions workflow，产出预编译 bundle 并挂到自己的 Release；商店目录登记后即可按需安装。当前 `apps/` 有 **132 条记录**（127 active / 3 pending / 2 withdrawn），由 `apps/INDEX.md` 汇总。

**核心内容**

| 路径 | 作用 |
|---|---|
| `assets/build-app-bundle.yml` | 加固过的多模式 bundle 模板（`flat` / `package-fn` / `package-deploy`），覆盖 5 种 app shape；含 smoke test、依赖闭包、固定 R 4.6.1 |
| `assets/catalog-entry.yml` | `ShinyApps/catalog/apps.yml` 的条目模板 |
| `scripts/onboard-shiny-app.ps1` | 步骤 2–6 的驱动脚本（fork/push/tag/release/PR） |
| `scripts/record-app.ps1` | 记录 app 快照（tag 处 workflow、资产大小、SHA）并生成 `meta.yml` + `NOTES.md` |
| `scripts/validate-apps.ps1` / `build-app-index.ps1` / `new-app-record.ps1` | 记录校验、生成 `apps/INDEX.md`、从 `_template` 新建记录 |
| `scripts/backfill-from-catalog.ps1` | 为 `ShinyApps/catalog/apps.yml` 中已有 app 批量补记录 |
| `scripts/next-pkg-version.ps1` | 为 Cairo 等被补丁的包分配唯一版本后缀 |
| `scripts/check-upstream.ps1` / `build-dashboard.ps1` | 上游漂移检查 / 维护看板渲染 |
| `references/` | `app-shapes`、`failure-modes`、`store-contract`、`startup-data`、`release-hardening`、`heavy-apps`、`macos-portability`、`runtime-downloads`、`special-packages`、`pr-template`、`icon-sourcing`、`batch-onboarding` |
| `apps/<id>/` | 每个已上架/失败/撤回 app 的 workflow 快照 + `meta.yml` + NOTES |
| `examples/` | 真实可用的 workflow 实例 |

**定位**：不改产品代码，只负责「怎么把 app 打出来、登记进去、验证通过」。已覆盖 iSEE、UCSCXenaShiny、spatialLIBD、beeRapp、CSBB-Shiny、SeuratExplorer、scConvertShiny、shinyCircos-V2.0、UpSetR-shiny、bestDEG、GraphBio、splitKbCompare、ShinyStan、shiny-genome-stats 等；维护看板见 <https://fentouxungui.github.io/shinyapps-onboarding/>。

---

## 4. 三者关系

```
上游第三方 app 仓库 (SeuratExplorer / scConvertShiny / ...)
        │  用 shinyapps-onboarding 生成的 workflow（Route A）
        ▼
GitHub Release: <id>-<version>-<platform>.zip
   app/ + rlib/<pkg>/ + manifest.json      ← 契约见 onboarding/references/store-contract.md
        │
        │ 登记到 catalog/apps.yml + icons/<id>.png
        ▼
ShinyApps repo ── publish-catalog.yml ──▶ gh-pages/
        │                                   catalog.json（本地图标 URL 带 ?v=<sha256[:12]>）
        │                                   icons/ + README.md
        │ build-desktop.yml（shinyelectron@multi-app-store）
        ▼
shell 安装包（ShinyApps Store） ──▶ 用户机器
                                        │ 拉取 catalog.json（?t= 防缓存）
                                        │ 安装 bundle → apps/<id>/<version> + lib/ + private/<id>/
                                        │ 图标缓存 → <dataRoot>/icons/
                                        ▼
                          shinyelectron 运行时启动 R + shiny::runApp()
```

**依赖方向**：`ShinyApps`（产品）依赖 `shinyelectron@multi-app-store`（引擎）；`shinyapps-onboarding` 不依赖二者代码，只依赖二者的**契约**（bundle 结构、manifest 字段、catalog 字段、图标规范）。

**版本耦合**

- 外壳与所有 bundle 必须使用同一 R 版本（当前 **4.6.1**）；`r_version` 用于安装前的兼容性门控。
- 外壳自身通过 `electron-updater` 从 GitHub Release 更新；每个 app 通过 catalog 版本比对更新（**必须 bump tag**，否则不会出现 Update）。
- 外壳版本由 release tag 决定（`APP_VERSION` 写回 `_shinyelectron.yml` 的 `app.version`）；不要手工维护版本号。
- 数据契约：`manifest.json` schema 1；`catalog.json` schema 1；`state.json` schema 1；`root.json` 记录创建数据根时的 shell/R 版本。
- 图标契约：`icons/<id>.png` 规范要求 512×512 PNG；本地图标在发布时生成的 `catalog.json` 会加内容哈希，`apps.yml` 中保持原始 URL。

**分工速查**

| 想做的事 | 改哪个仓库 |
|---|---|
| 改启动器/商店/安装卸载/标题栏/资源占用显示 | `shinyelectron`（`inst/electron/shared/*`、`backends/*`） |
| 改图标/catalog 缓存、条件请求、数据目录迁移 | `shinyelectron`（`backends/appstore.js`、`shared/main.js`） |
| 改后端启动参数、`.libPaths`、进程管理 | `shinyelectron`（`backends/native-*.js`） |
| 新增/下架 app、改图标、改 shell 文案与内嵌应用 | `ShinyApps`（`catalog/apps.yml`、`icons/`、`_shinyelectron.yml`） |
| 给某个 app 打 bundle、修依赖闭包、加启动数据预取 | 该 app 仓库（workflow 由 `shinyapps-onboarding` 提供） |
| 批量上架、巡检上游漂移、看维护看板 | `shinyapps-onboarding` |
| 换图标后客户端仍显示旧图 | 确认线上 `catalog.json` 的 icon 是否带 `?v=`；必要时清 `<dataRoot>/icons/<id>.png` 或等条件请求 TTL |

---

## 5. 本地数据与常见路径

**数据根解析顺序**（`main.js` 的 `resolveDataRoot()`）：

1. `settings.json` 中的 `dataRoot`（Settings → App Data Location 可迁移）；
2. 若 Electron `userData` 已有 `state.json` 或非空 `apps/`，沿用旧版 userData（通常 `%APPDATA%\<slug>`）；
3. 否则默认 `%LOCALAPPDATA%\ShinyApps`（Windows；非漫游目录，避免 OneDrive 同步大文件）。

**数据根内容**：

- `state.json`：已安装 app 与共享库引用计数；每个安装记录保存绝对目录。
- `apps/<id>/<version>/`：已安装 bundle。
- `lib/`：共享 R 包；`private/<id>/`：版本冲突时该 app 的私有包。
- `store-cache/`：下载/解压临时缓存。
- `icons/index.json` + `<id>.png`：图标缓存（URL、ETag、Last-Modified、checkedAt）。
- `catalog-cache.json`：最后一次成功拉取的 catalog（离线时回退）。
- `root.json`：创建该数据根时的 shell/R 版本标记；R 版本变化时启动会告警。

**设置与日志**：`settings.json`、`logs/`、`crashes/`、`window-state.json` 位于 Electron `userData`；`settings.json` 在数据根迁移后仍保留。

**图标缓存行为**：

- 客户端按 URL 缓存图标；同名替换且 URL 不变时，最多 10 分钟后由条件请求发现新内容；catalog 的 `?v=` 哈希变化则立即重新下载。
- 下载是后台异步的：Refresh Catalog 后若仍看到旧图，等几秒再刷新一次。
- 旧客户端或需要强制清理时：完全退出软件后删除 `<dataRoot>/icons/<id>.png`（或整个 `icons/`），下次 catalog 刷新会重建。

**卸载与清理**：卸载 shell 不会删除用户数据；「Uninstall and remove all apps & data」会清理 `userData` 与数据根中的 `apps/lib/private/store-cache/icons/catalog-cache/state/root`，以及 `settings/logs/crashes/window-state`（详见 `wipeAllLocalData()`）。

**数据根迁移**：迁移时会重写 `state.json` 中记录的绝对目录，避免旧路径失效；`root.json` 用于提示 R ABI 变化。

---

## 6. 相关仓库

- 应用侧示例：`fentouxungui/SeuratExplorer`、`fentouxungui/scConvertShiny`、`fentouxungui/UCSCXenaShiny`、`fentouxungui/iSEE`、`fentouxungui/spatialLIBD` 等（各自带 `*-build-app-bundle.yml`）。
- 上游引擎：`coatless-rpkg/shinyelectron`（AGPL-3.0）。
- 在线目录：<https://fentouxungui.github.io/ShinyApps/catalog.json>；商店页面：<https://fentouxungui.github.io/ShinyApps/>；维护看板：<https://fentouxungui.github.io/shinyapps-onboarding/>。

---

*生成时间：2026-10-27；2026-11-11 更新。基于三仓库 README、`_shinyelectron.yml`、`DESCRIPTION`、workflow、`catalog/apps.yml`、`appstore.js`、`main.js` 与本会话的图标缓存调试记录整理。*
