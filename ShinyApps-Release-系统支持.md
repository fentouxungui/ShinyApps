Run Shiny apps locally — no R installation, no data upload.  
在本地运行 Shiny 应用——无需安装 R，数据无需上传。

## Download / 下载

| Platform | Installer | Requirements |
|---|---|---|
| Windows | `shinyapps-Setup-<version>-x64.exe` | Windows 10 / 11 (64-bit) |
| macOS | `shinyapps-<version>-arm64.dmg` | Apple Silicon (M1 or newer), macOS 14 Sonoma or later |

## Requirements / 系统要求

- **Windows:** Windows 10 or Windows 11, 64-bit (x64). Windows 7/8/8.1 and 32-bit Windows are not supported.  
  Windows 10 / 11 64 位；不支持 Windows 7/8/8.1 和 32 位系统。
- **macOS:** Apple Silicon only (M1/M2/M3/M4 or newer), macOS 14 Sonoma or later. Intel Macs are not supported.  
  仅支持 Apple Silicon（M1 及更新），macOS 14 Sonoma 及以上；Intel Mac 不支持。
- No Linux build. / 不提供 Linux 版本。
- Windows on ARM runs the x64 installer under emulation; not officially tested.  
  Windows 11 ARM 可通过 x64 模拟运行，未做官方测试。

## First launch / 首次运行

The builds are unsigned. / 安装包未签名。

- **macOS:** right-click ShinyApps → Open. If macOS reports the app is damaged, run:  
  右键点击 ShinyApps → 打开；若提示“已损坏”，执行：
  ```bash
  xattr -dr com.apple.quarantine /Applications/ShinyApps.app
  ```
- **Windows:** SmartScreen → More info → Run anyway.  
  SmartScreen 提示时选择“更多信息”→“仍要运行”。

## Notes / 说明

- Store apps are platform-specific (`win-x64` / `mac-arm64`).  
  商店中的 app 按平台分发（`win-x64` / `mac-arm64`）。
- Windows 10 support ended on 2025-10-14; Windows 11 is recommended.  
  Windows 10 已结束微软支持，建议使用 Windows 11。
