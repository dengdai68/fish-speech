#!/bin/bash

# Fish Speech 服务停止脚本
# 用法: ./stop.sh [webui|api|all]

set -e

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# PID 文件目录
PID_DIR="$SCRIPT_DIR/pids"

# 服务类型
SERVICE_TYPE="${1:-all}"

# 停止指定服务
stop_service() {
    local service=$1
    local pid_file="$PID_DIR/${service}.pid"

    if [[ ! -f "$pid_file" ]]; then
        echo "$service 服务未运行 (未找到 PID 文件)"
        return
    fi

    local pid=$(cat "$pid_file")

    if ps -p "$pid" > /dev/null 2>&1; then
        echo "停止 $service 服务 (PID: $pid)..."
        kill "$pid"

        # 等待进程结束
        local count=0
        while ps -p "$pid" > /dev/null 2>&1 && [ $count -lt 10 ]; do
            sleep 1
            count=$((count + 1))
        done

        # 如果进程还在运行,强制杀死
        if ps -p "$pid" > /dev/null 2>&1; then
            echo "强制停止 $service 服务..."
            kill -9 "$pid"
        fi

        echo "$service 服务已停止"
    else
        echo "$service 服务未运行 (进程不存在)"
    fi

    rm -f "$pid_file"
}

# 根据参数停止服务
case "$SERVICE_TYPE" in
    webui)
        stop_service "webui"
        ;;
    api)
        stop_service "api"
        ;;
    all)
        stop_service "webui"
        stop_service "api"
        ;;
    *)
        echo "错误: 无效的服务类型 '$SERVICE_TYPE'"
        echo "用法: $0 [webui|api|all]"
        exit 1
        ;;
esac
