# WarpLauncher

一键启动 Warp 的 macOS 菜单栏应用，启动后常驻菜单栏，方便管理。

## 使用场景

当你需要快速启动 Warp 应用并自动完成激活码验证时，只需点击 Dock 中的 WarpLauncher 图标即可。应用启动后会常驻菜单栏，方便随时管理。

## 功能特性

- 🚀 一键启动，无需手动操作
- 🔐 自动管理激活码，首次使用时输入即可
- 💾 激活码本地安全存储
- 🔄 激活码失效时自动提示更新
- ⚡ **菜单栏常驻**，点击图标可快速操作
- 🌐 **一键打开** Warp API 管理页面
- 🛑 **优雅退出**，自动结束 api-worker 进程

## 菜单栏功能（v2.0 新增）

启动应用后，macOS 顶部菜单栏会显示 ⚡ 图标，点击后有以下选项：

| 菜单项 | 快捷键 | 说明 |
|--------|--------|------|
| 打开 Warp API 管理页面 | ⌘O | 在浏览器中打开 http://localhost:9182/api/warp/ |
| 结束 api-worker 并退出 | ⌘Q | 结束所有 api-worker 进程并退出应用 |

## 安装方法

### 方式一：下载 Release

1. 前往 [Releases](https://github.com/engtyleong/WarpLauncher/releases) 页面
2. 下载最新的 `WarpLauncher.app.zip`
3. 解压后将 `WarpLauncher.app` 拖入 `/Applications` 文件夹
4. 将应用拖入 Dock 即可使用

### 方式二：本地构建

```bash
# 克隆仓库
git clone https://github.com/engtyleong/WarpLauncher.git
cd WarpLauncher

# 运行构建脚本
chmod +x scripts/build.sh
./scripts/build.sh

# 安装到 Applications
cp -R build/WarpLauncher.app /Applications/
```

## 使用方法

1. **首次运行**：点击应用后会弹出输入框，输入激活码
2. **日常使用**：点击 Dock 图标，Warp 自动启动，菜单栏显示 ⚡ 图标
3. **打开管理页面**：点击菜单栏 ⚡ 图标 → 「打开 Warp API 管理页面」
4. **退出应用**：点击菜单栏 ⚡ 图标 → 「结束 api-worker 并退出」
5. **激活码更新**：当激活码失效时，会自动弹出输入框让你输入新的激活码

## 配置文件

激活码存储在 `~/.warplauncher_config` 文件中。

## 系统要求

- macOS 11.0+ (Big Sur 或更高版本)
- 已安装 [api-worker](https://github.com/anthropics/api-worker)（路径：`/opt/homebrew/bin/api-worker`）

## 项目结构

```
warp-auto/
├── src/
│   ├── WarpLauncher.swift    # 菜单栏应用主代码
│   └── launcher.sh           # 核心启动逻辑脚本
├── scripts/
│   └── build.sh              # 本地构建脚本
├── build/                    # 构建输出目录
├── icon.icns                 # 应用图标
└── .github/workflows/        # CI/CD 配置
```

## 更新日志

### v2.0
- 🆕 新增 macOS 菜单栏常驻功能
- 🆕 新增一键打开 API 管理页面
- 🆕 新增优雅退出（自动结束 api-worker 进程）
- 🔧 从 AppleScript Applet 升级为原生 Swift 应用
- 🔧 支持 Intel 和 Apple Silicon 双架构

### v1.0
- 🎉 首次发布
- ✅ 一键启动 Warp
- ✅ 激活码自动管理

## 许可证

MIT License
