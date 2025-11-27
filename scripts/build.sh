#!/bin/bash
# ============================================
# WarpLauncher 构建脚本
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
APP_NAME="WarpLauncher"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

echo "🔨 开始构建 $APP_NAME..."

# 清理旧构建
rm -rf "$APP_BUNDLE"
mkdir -p "$BUILD_DIR"

# 创建应用包结构
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# 编译 Swift 代码
echo "📦 编译 Swift 代码..."
swiftc -O \
    -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" \
    "$PROJECT_ROOT/src/WarpLauncher.swift" \
    -framework Cocoa \
    -target arm64-apple-macos11.0

# 如果需要支持 Intel Mac，可以使用以下命令编译通用二进制：
# swiftc -O \
#     -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" \
#     "$PROJECT_ROOT/src/WarpLauncher.swift" \
#     -framework Cocoa \
#     -target arm64-apple-macos11.0 \
#     -target x86_64-apple-macos11.0

# 复制启动脚本到 Resources
echo "📋 复制资源文件..."
cp "$PROJECT_ROOT/src/launcher.sh" "$APP_BUNDLE/Contents/Resources/"
chmod +x "$APP_BUNDLE/Contents/Resources/launcher.sh"

# 复制图标
if [ -f "$PROJECT_ROOT/icon.icns" ]; then
    cp "$PROJECT_ROOT/icon.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
fi

# 创建 Info.plist
echo "📝 生成 Info.plist..."
cat > "$APP_BUNDLE/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh_CN</string>
    <key>CFBundleExecutable</key>
    <string>WarpLauncher</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.warp.launcher</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>WarpLauncher</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>2.0</string>
    <key>CFBundleVersion</key>
    <string>2</string>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

# 创建 PkgInfo
echo -n "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"

echo "✅ 构建完成: $APP_BUNDLE"

# 打包为 zip
echo "📦 打包为 zip..."
cd "$BUILD_DIR"
rm -f "$APP_NAME.app.zip"
zip -r "$APP_NAME.app.zip" "$APP_NAME.app"

echo "✅ 打包完成: $BUILD_DIR/$APP_NAME.app.zip"
