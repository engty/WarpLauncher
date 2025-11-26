# WarpLauncher

一键启动 Warp 的 macOS 应用，放入 Dock 即可使用。

## 使用场景

当你需要快速启动 Warp 应用并自动完成激活码验证时，只需点击 Dock 中的 WarpLauncher 图标即可。

## 功能特性

- 🚀 一键启动，无需手动操作
- 🔐 自动管理激活码，首次使用时输入即可
- 💾 激活码本地安全存储
- 🔄 激活码失效时自动提示更新

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

# 构建应用
cd build
chmod +x launcher.sh
osacompile -o WarpLauncher.app -e 'do shell script "'$(pwd)'/launcher.sh"'

# 安装到 Applications
cp -R WarpLauncher.app /Applications/
```

## 使用方法

1. **首次运行**：点击应用后会弹出输入框，输入激活码
2. **日常使用**：点击 Dock 图标，Warp 自动启动
3. **激活码更新**：当激活码失效时，会自动弹出输入框让你输入新的激活码

## 配置文件

激活码存储在 `~/.warplauncher_config` 文件中。

## 系统要求

- macOS 10.15+
- 已安装 [api-worker](https://github.com/anthropics/api-worker)（路径：`/opt/homebrew/bin/api-worker`）

## 许可证

MIT License
