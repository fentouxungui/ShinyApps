# ShinyApps

[English](README.md) | **简体中文** | [Wiki](https://github.com/fentouxungui/ShinyApps/wiki)

[![平台](https://img.shields.io/badge/platform-Windows%20%7C%20macOS-blue)](#) [![R](https://img.shields.io/badge/R-4.6.1-276DC3?logo=r)](#) [![基于](https://img.shields.io/badge/built%20on-shinyelectron-8A2BE2)](https://github.com/coatless-rpkg/shinyelectron)

> **ShinyApps 是一个面向 R/Shiny 应用的桌面「应用商店」。** 它只装一个轻量 Electron
> 外壳，用户从在线 catalog 按需**安装、运行、更新、卸载**打包好的 Shiny 应用，一次运行
> 一个，共用一套 R 运行时。

它不再把每个应用都做成一个庞大的独立桌面安装包，而是把**薄壳**与**可安装的应用 bundle**
拆开：以后新增任何 Shiny 应用都无需重新构建、重新分发外壳。

目前集成：**SeuratExplorer** 与 **scConvertShiny**。

---

## ✨ 主要功能

- **应用商店模式** —— 卡片式启动页，`Install → Run / Uninstall`，并支持按应用的 `Update`。
- **可加入任何 Shiny 应用** —— 把应用打成 `app/ + rlib/ + manifest.json`，作为 GitHub Release 资产发布，再在 catalog 登记即可，**无需重建外壳**。
- **每次启动自动检测版本** —— 软件启动时会自动比对每个 app 的线上最新版本与本地已装版本，有新版本即显示一键 **Update** 升级。
- **共享 R 库 + 引用计数** —— 被 ≥2 个应用用到的包在共享库里只存一份；单应用或版本冲突的包进私有库。（实测两个应用间 **160 个包中有 133 个共享**。）
- **可复现的 bundle** —— 应用随包发布**预编译的二进制 R 包**，固定 **R 4.6.1**，每个都有 `sha256`；用户机器上**不需要编译器或 R 工具链**。
- **健壮的下载** —— HTTP Range 断点续传、失败重试、空闲超时、大小 + `sha256` 校验、真实进度、零 npm 依赖的内置 ZIP 解包。
- **两条独立更新通道** —— 外壳通过 `electron-updater` 更新；每个应用通过 catalog 更新。
- **干净的进程生命周期** —— 同时只跑一个应用；返回启动页会杀掉整棵 R 进程树（Windows `taskkill /T /F`）。
- **跨平台** —— Windows（`win-x64`）与 macOS（`mac-arm64`）。
- **卡片可跳转 App 主页** —— 鼠标悬停 App 名字显示 “click to learn more”，点击用浏览器打开该 App 的 `homepage`。
- **安装过程可见** —— 卡片显示当前步骤（下载 % → 校验 → 安装），失败时明确显示哪一步出错及原因（如“大小不一致：catalog 12934112 字节，实际 0 字节”）。
- **按 App 的 Help/About** —— App 菜单标签、Help ▸ Documentation、About 弹窗（含 Visit Website / Email / Check for Updates）都跟随当前运行的 App，取用其 catalog 的 `docs` / `homepage` / `email` / `author` / `copyright`。

## 🚀 快速开始（用户）

1. 从 [**Releases**](https://github.com/fentouxungui/ShinyApps/releases) 下载 `shinyapps-Setup-<version>-x64.exe`（Windows）或 `.dmg`（macOS）。
2. 打开 **ShinyApps** —— 启动页为每个可用应用显示一张卡片。
3. 点 **Install**，再 **Run**。返回用 **Apps → Back to Launcher**（或 `Ctrl/Cmd+L`）；有未保存内容会先确认。
4. **每次打开软件，ShinyApps 都会自动检测每个 app 的最新版本**（与线上 catalog 比对）。若有新版，卡片会显示 **Update**，点一下即可一键升级（暂停应用 → 下载 → 校验 → 原子替换）。

> 外壳自动更新只在**已签名**的构建上才真正安装；未签名构建可以下载，但 Windows/macOS 会拒绝应用更新。

## 🧩 开发者：如何加入你的 Shiny 应用

两种接入方式：

**A. 商店 / 按需安装（推荐）。** 在你自己的仓库里加一个 bundle workflow，产出各平台的
`<id>-<version>-<platform>.zip` 并发布到 Release，然后在本仓库的 `catalog/apps.yml` 登记。
用户按需安装，**完全不需要改外壳**。

```
<id>-<version>-<platform>.zip
└─ app/         # 你的 Shiny 入口（app.R）
└─ rlib/        # 预编译的依赖闭包（二进制 R 包）
└─ manifest.json
```

**B. 打进壳（bake-in）。** 把 `app.R` 与依赖 tarball 放进本仓库的 `apps/` 与 `dependency/`，
重建外壳。应用随安装包一起发布（离线、无需下载），但安装包更大，且每次改动都要重发外壳。

应用需满足一个很小的契约：入口返回一个 **`shinyApp` 对象**（不能在内部再调 `runApp()`），
能打成标准 R 源码包，并基于 **R 4.6.1** 构建。

👉 完整指南见 **[使用手册（中文）](https://github.com/fentouxungui/ShinyApps/wiki/ManualZH)** · **[User Manual (EN)](https://github.com/fentouxungui/ShinyApps/wiki/ManualEN)**。

## 🏗️ 实现路径

### 三层结构

```
Tier 0  外壳 + 便携 R 4.6.1 + 最小依赖       随安装包装一次，不卸载
Tier 1  共享 R 库     <userData>/lib            被 >=2 个应用需要的包（引用计数）
Tier 2  私有 R 库     <userData>/private/<id>   单应用或版本冲突的包
```

运行时：`R_LIBS = 私有库 : 共享库`。

### 数据流

```
应用仓库 CI ──发布──▶ GitHub Release  （bundle zip + sha256）
                          │
ShinyApps catalog/apps.yml ─▶ publish-catalog.yml ─▶ gh-pages/catalog.json
                          │
客户端外壳 ──拉取 catalog──▶ 安装 bundle ─▶ 以 R_LIBS(私有:共享) 运行
```

### 相关仓库

| 仓库 | 角色 |
|---|---|
| **`ShinyApps`**（本仓库） | 外壳配置、catalog、schemas、图标、构建脚本、workflows |
| [`shinyelectron@multi-app-store`](https://github.com/fentouxungui/shinyelectron/tree/multi-app-store) | Electron 主进程、启动器、商店引擎、R 后端 |
| [`SeuratExplorer`](https://github.com/fentouxungui/SeuratExplorer)、[`scConvertShiny`](https://github.com/fentouxungui/scConvertShiny) | 应用及其 bundle CI |

### 关键文件

```
_shinyelectron.yml          # 外壳配置（运行时策略、依赖、apps[]、更新）
build-suite.R               # 构建外壳；版本号由 Release tag 推导
catalog/apps.yml            # 唯一手工维护的应用登记表
schemas/*.json              # catalog / manifest / state 三份契约
.github/workflows/
  build-desktop.yml         # 构建外壳安装器 + 发 Release
  publish-catalog.yml       # 生成 catalog.json + 将 icons 发到 gh-pages
```

### 工作流

| Workflow | 触发 | 产物 |
|---|---|---|
| **Build ShinyApps desktop** | tag `v*` / 手动 | 外壳安装器 + `latest*.yml` → Release |
| **Publish catalog** | 每 10 分钟 / 手动 / `bundle-updated` 事件 / 改 `apps.yml` 或 `icons/` | `gh-pages` 上的 `catalog.json` + `icons/` |
| **Build app bundle**（各应用仓库） | 发布 Release / 手动 | `<id>-<version>-<platform>.zip` → 该应用的 Release |

## ⚖️ 优缺点

### ✅ 优点

- **扩展无需重新发布外壳** —— 新应用只是一个新的 catalog 条目 + Release bundle。
- **首次下载更小** —— 用户只下自己选择的应用，外壳是共享的。
- **共享带来真实的空间节省** —— 一套共享库 + 引用计数（实测两个应用共享了 133/160 个包）。
- **用户机器无需编译器** —— 预编译二进制 + 固定 R 运行时；安装快，下载后可离线使用。
- **可复现、可校验** —— 每个产物都带 `sha256`；catalog 是唯一数据源。
- **隔离干净** —— 每个应用的私有库解决版本冲突，不必强制升级共享包。

### ⚠️ 缺点与取舍

- **一次只能跑一个应用** —— 返回启动页会停掉当前应用，**未保存的分析会丢失**（有确认框）。它不是多窗口中枢。
- **安装时下载可能很大** —— 每个 bundle 几十到几百 MB（含编译好的依赖）。共享包能降低后续应用的增量体积，但重型应用的首次安装依旧很大。
- **必须分平台出包** —— Windows 二进制必须在 Windows 上构建；每个平台各出各的 bundle。目前只产 `win-x64` 与 `mac-arm64`。
- **版本强耦合** —— 所有 bundle 必须与外壳使用同一个 R 版本构建（当前 4.6.1）。
- **原生依赖是难点** —— 例如 Windows 上，`scConvert` 转换受 CRAN `hdf5r`/HDF5 1.12 限制。
- **依赖基础设施** —— 依赖 GitHub Actions / Releases / Pages；外壳自动更新还需代码签名。
- **许可义务** —— 外壳基于 **AGPL-3.0** 的 `shinyelectron`；各应用带来各自许可（如 GPL-3.0、MIT）。

## 📦 当前应用

| 应用 | 描述 | 许可 |
|---|---|---|
| [SeuratExplorer](https://github.com/fentouxungui/SeuratExplorer) | 探索经 Seurat 处理的单细胞数据 | GPL-3.0-or-later |
| [scConvertShiny](https://github.com/fentouxungui/scConvertShiny) | 单细胞格式转换（h5ad / h5Seurat / Loom / MuData / Seurat / SCE / Zarr） | MIT |

## 🗺️ 路线图

- [ ] 外壳自动更新的代码签名（Windows / macOS）
- [ ] 减少磁盘冗余（关联后删除 bundle `rlib/`；清理下载缓存）
- [ ] 应用发布时自动刷新 catalog（`repository_dispatch`）
- [ ] 解决 Windows `scConvert` 的 HDF5 限制
- [ ] 接入更多平台与应用

## 📚 文档

完整手册在 **[Wiki](https://github.com/fentouxungui/ShinyApps/wiki)**，提供 **中文** 与 **English**：

- 👉 **[使用手册（中文）](https://github.com/fentouxungui/ShinyApps/wiki/ManualZH)** · **[User Manual (EN)](https://github.com/fentouxungui/ShinyApps/wiki/ManualEN)**
- **用户指南** —— 安装、启动页、运行/更新/卸载、数据位置
- **开发者指南** —— bundle 契约、catalog 登记、图标
- **维护者指南** —— 仓库结构与每个 workflow
- **发布流程** —— 发壳、发 app、更新图标
- **FAQ / 故障排查** —— 已知问题与解决
- **已知限制 / 路线图** —— 未解决问题与计划

## 🙏 致谢与许可

基于 [shinyelectron](https://github.com/coatless-rpkg/shinyelectron)（AGPL-3.0）构建。本仓库还
打包/调用了第三方组件 —— 详见 `shared-library-policy.md` 及各应用仓库。对外分发前请补充顶层
`LICENSE` 与第三方声明。

---

*维护者：Zhang Yongchao。欢迎贡献代码与新的应用 bundle。*
