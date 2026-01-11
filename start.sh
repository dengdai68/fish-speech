#!/bin/bash

# Fish Speech 服务启动脚本
# 用法: ./start.sh [webui|api]

set -e

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 日志目录
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"

# PID 文件目录
PID_DIR="$SCRIPT_DIR/pids"
mkdir -p "$PID_DIR"

# 服务类型
SERVICE_TYPE="${1:-webui}"

# 验证服务类型
if [[ "$SERVICE_TYPE" != "webui" && "$SERVICE_TYPE" != "api" ]]; then
    echo "错误: 无效的服务类型 '$SERVICE_TYPE'"
    echo "用法: $0 [webui|api]"
    exit 1
fi

# 检查 conda 环境
if ! command -v conda &> /dev/null; then
    echo "错误: 未找到 conda 命令"
    exit 1
fi

# 检查服务是否已经在运行
PID_FILE="$PID_DIR/${SERVICE_TYPE}.pid"
if [[ -f "$PID_FILE" ]]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "警告: $SERVICE_TYPE 服务已经在运行 (PID: $OLD_PID)"
        echo "如需重启,请先运行: ./stop.sh $SERVICE_TYPE"
        exit 1
    else
        echo "清理旧的 PID 文件..."
        rm -f "$PID_FILE"
    fi
fi

# 激活 conda 环境
echo "激活 conda 环境: fish-speech"
eval "$(conda shell.bash hook)"
conda activate fish-speech

# 根据服务类型启动
LOG_FILE="$LOG_DIR/${SERVICE_TYPE}.log"
echo "启动 $SERVICE_TYPE 服务..."
echo "日志文件: $LOG_FILE"

if [[ "$SERVICE_TYPE" == "api" ]]; then
    # 启动 API 服务
    nohup python tools/api_server.py --listen 0.0.0.0:8080 > "$LOG_FILE" 2>&1 &
    PID=$!
    echo $PID > "$PID_FILE"
    echo "API 服务已启动 (PID: $PID)"
    echo "访问地址: http://0.0.0.0:8080"
    echo "API 文档: http://0.0.0.0:8080/docs"
elif [[ "$SERVICE_TYPE" == "webui" ]]; then
    # 启动 WebUI 服务
    nohup python tools/run_webui.py > "$LOG_FILE" 2>&1 &
    PID=$!
    echo $PID > "$PID_FILE"
    echo "WebUI 服务已启动 (PID: $PID)"
    echo "访问地址将在日志中显示"
fi

echo ""
echo "查看日志: tail -f $LOG_FILE"
echo "停止服务: ./stop.sh $SERVICE_TYPE"
