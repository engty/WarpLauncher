#!/bin/bash
# ============================================
# WarpLauncher v1.0
# ============================================

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

API_WORKER_CMD="/opt/homebrew/bin/api-worker"
CONFIG_FILE="$HOME/.warplauncher_config"

# 弹出输入框
prompt_activation_code() {
    local msg="${1:-请输入激活码：}"
    osascript -e "display dialog \"$msg\" default answer \"\" with title \"WarpLauncher\" buttons {\"取消\", \"确定\"} default button \"确定\"" -e 'text returned of result' 2>/dev/null
}

# 登录函数
do_login() {
    local response
    response=$(/usr/bin/curl -s -X POST "http://localhost:9182/api/users/card-login" \
        -H "Content-Type: application/json" \
        -d "{\"card\":\"$1\",\"agent\":\"main\"}" \
        --max-time 3 2>/dev/null)
    echo "$response" | grep -q '"token"'
}

# 启动 Warp
start_warp() {
    /usr/bin/curl -s -X POST "http://localhost:9182/warp/open" \
        -H "Content-Type: application/json" \
        -d '{"warpPath":""}' \
        --max-time 2 > /dev/null 2>&1
}

# 杀旧进程 + 启动新进程
/usr/bin/pkill -f "api-worker" 2>/dev/null
/usr/bin/nohup "$API_WORKER_CMD" > /dev/null 2>&1 &

# 等待服务就绪
for i in 1 2 3 4; do
    sleep 0.5
    /usr/bin/curl -s --max-time 1 "http://localhost:9182/" > /dev/null 2>&1 && break
done

# 读取激活码（无默认值，必须从配置文件读取或用户输入）
if [ -f "$CONFIG_FILE" ]; then
    CODE=$(cat "$CONFIG_FILE")
    # 尝试登录
    if do_login "$CODE"; then
        start_warp
        exit 0
    fi
    # 配置文件中的激活码失效
    PROMPT_MSG="激活码已失效，请输入新的激活码："
else
    # 首次运行，无配置文件
    PROMPT_MSG="首次运行，请输入激活码："
fi

# 激活码输入循环
while true; do
    NEW_CODE=$(prompt_activation_code "$PROMPT_MSG")

    # 用户点击取消
    if [ -z "$NEW_CODE" ]; then
        exit 0
    fi

    # 验证新激活码
    if do_login "$NEW_CODE"; then
        # 保存新激活码
        echo "$NEW_CODE" > "$CONFIG_FILE"
        start_warp
        exit 0
    else
        PROMPT_MSG="❌ 激活码无效，请重新输入："
    fi
done
