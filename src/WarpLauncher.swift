// ============================================
// WarpLauncher - macOS 菜单栏应用
// ============================================

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private var launcherProcess: Process?

    // 获取 launcher.sh 的路径
    private var launcherScriptPath: String {
        let bundle = Bundle.main
        // 优先从 Resources 目录查找
        if let resourcePath = bundle.path(forResource: "launcher", ofType: "sh") {
            return resourcePath
        }
        // 备用：从应用包同级目录查找
        let appPath = bundle.bundlePath
        let parentDir = (appPath as NSString).deletingLastPathComponent
        return (parentDir as NSString).appendingPathComponent("launcher.sh")
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 创建菜单栏图标
        setupStatusItem()

        // 启动 launcher.sh（后台执行原有逻辑）
        runLauncherScript()
    }

    // MARK: - 菜单栏设置

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            // 使用 SF Symbol 或文字作为图标
            if #available(macOS 11.0, *) {
                button.image = NSImage(systemSymbolName: "bolt.fill", accessibilityDescription: "WarpLauncher")
            } else {
                button.title = "⚡"
            }
            button.toolTip = "WarpLauncher"
        }

        // 创建菜单
        let menu = NSMenu()

        // 菜单项 1: 打开 API 网页
        let openWebItem = NSMenuItem(
            title: "打开 Warp API 管理页面",
            action: #selector(openWebPage),
            keyEquivalent: "o"
        )
        openWebItem.target = self
        menu.addItem(openWebItem)

        // 分隔线
        menu.addItem(NSMenuItem.separator())

        // 菜单项 2: 退出应用
        let quitItem = NSMenuItem(
            title: "结束 api-worker 并退出",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    // MARK: - 菜单动作

    @objc private func openWebPage() {
        if let url = URL(string: "http://localhost:9182/api/warp/") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func quitApp() {
        // 结束所有 api-worker 进程
        killApiWorkerProcesses()

        // 退出应用
        NSApplication.shared.terminate(self)
    }

    // MARK: - 进程管理

    private func runLauncherScript() {
        let scriptPath = launcherScriptPath

        // 检查脚本是否存在
        guard FileManager.default.fileExists(atPath: scriptPath) else {
            showAlert(
                title: "错误",
                message: "找不到启动脚本：\(scriptPath)"
            )
            return
        }

        // 使用 Process 执行脚本
        DispatchQueue.global(qos: .background).async { [weak self] in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/bash")
            process.arguments = [scriptPath]
            process.environment = ProcessInfo.processInfo.environment

            // 设置 PATH 环境变量
            var env = process.environment ?? [:]
            let existingPath = env["PATH"] ?? ""
            env["PATH"] = "/opt/homebrew/bin:/opt/homebrew/sbin:\(existingPath)"
            process.environment = env

            do {
                try process.run()
                self?.launcherProcess = process
            } catch {
                DispatchQueue.main.async {
                    self?.showAlert(
                        title: "启动失败",
                        message: "无法执行启动脚本：\(error.localizedDescription)"
                    )
                }
            }
        }
    }

    private func killApiWorkerProcesses() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pkill")
        process.arguments = ["-f", "api-worker"]

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            // 忽略错误（可能没有进程在运行）
            print("pkill error: \(error)")
        }
    }

    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "确定")
            alert.runModal()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // 应用退出时也结束 api-worker
        killApiWorkerProcesses()
    }
}

// MARK: - 应用入口

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// 设置为 accessory 应用（不显示在 Dock，只显示菜单栏图标）
app.setActivationPolicy(.accessory)

app.run()
