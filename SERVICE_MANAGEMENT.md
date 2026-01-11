# Fish Speech 服务管理脚本使用说明

## 概述

本项目提供了便捷的服务启动和停止脚本,支持后台运行 Fish Speech 的 WebUI 和 API 服务。

## 脚本说明

### start.sh - 启动服务

用于启动 Fish Speech 服务,支持后台运行。

**用法:**
```bash
./start.sh [webui|api]
```

**参数:**
- `webui`: 启动 WebUI 服务 (默认)
- `api`: 启动 API 服务

**示例:**
```bash
# 启动 WebUI 服务
./start.sh webui

# 启动 API 服务
./start.sh api
```

**功能特性:**
- 自动激活 conda 环境 (fish-speech)
- 后台运行,不占用控制台
- 自动创建日志文件 (logs/ 目录)
- 保存进程 PID (pids/ 目录)
- 防止重复启动同一服务

**日志查看:**
```bash
# 查看 WebUI 日志
tail -f logs/webui.log

# 查看 API 日志
tail -f logs/api.log
```

### stop.sh - 停止服务

用于停止正在运行的 Fish Speech 服务。

**用法:**
```bash
./stop.sh [webui|api|all]
```

**参数:**
- `webui`: 停止 WebUI 服务
- `api`: 停止 API 服务
- `all`: 停止所有服务 (默认)

**示例:**
```bash
# 停止 WebUI 服务
./stop.sh webui

# 停止 API 服务
./stop.sh api

# 停止所有服务
./stop.sh all
```

## 服务配置

### API 服务
- 默认监听地址: `0.0.0.0:8080`
- API 文档地址: `http://0.0.0.0:8080/docs`
- 启动命令: `python tools/api_server.py --listen 0.0.0.0:8080`

### WebUI 服务
- 启动命令: `python tools/run_webui.py`
- 访问地址会在日志中显示

## 目录结构

```
.
├── start.sh          # 启动脚本
├── stop.sh           # 停止脚本
├── logs/             # 日志目录 (自动创建)
│   ├── webui.log    # WebUI 日志
│   └── api.log      # API 日志
└── pids/             # PID 文件目录 (自动创建)
    ├── webui.pid    # WebUI 进程 PID
    └── api.pid      # API 进程 PID
```

## 常见问题

### 1. 服务无法启动
- 检查 conda 环境是否正确安装: `conda env list`
- 检查日志文件查看错误信息: `tail -f logs/webui.log` 或 `tail -f logs/api.log`

### 2. 端口被占用
- API 服务默认使用 8080 端口,如需修改请编辑 `start.sh` 中的 `--listen` 参数

### 3. 服务已在运行
- 如需重启服务,先运行 `./stop.sh [service]` 停止服务,再运行 `./start.sh [service]` 启动

### 4. 查看服务状态
```bash
# 查看进程是否运行
ps aux | grep "api_server\|run_webui"

# 查看 PID 文件
cat pids/webui.pid
cat pids/api.pid
```

## 注意事项

1. 确保已安装并配置好 conda 环境 `fish-speech`
2. 首次运行前需要给脚本添加执行权限: `chmod +x start.sh stop.sh`
3. 日志文件会持续增长,建议定期清理
4. 服务运行在后台,关闭终端不会影响服务运行
