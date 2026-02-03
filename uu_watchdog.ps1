# ================== UU Remote Watchdog (Precise) ==================
# 核心判定：GameViewerServer.exe 是否存在
# 修复手段：重启 Windows 服务 GameViewerService（你已确认存在）
# 防误判：连续多次检测不到才进入修复/重启

$targetProcess = "GameViewerServer"     # 不带 .exe
$serviceName   = "GameViewerService"    # 你提供的服务名

$checks = 3                 # 连续失败次数阈值
$intervalSeconds = 20       # 每次检查间隔
$postFixWaitSeconds = 30    # 修复后等待时间

function Is-ServerRunning {
    return $null -ne (Get-Process -Name $targetProcess -ErrorAction SilentlyContinue)
}

function Try-Fix {
    # 1) 重启服务（最可靠）
    try {
        Restart-Service -Name $serviceName -Force -ErrorAction Stop
    } catch {
        # 如果重启失败，尝试启动
        try { Start-Service -Name $serviceName -ErrorAction SilentlyContinue } catch {}
    }
}

# ================== 主流程 ==================

# 连续检查：避免瞬间抖动误判
for ($i = 1; $i -le $checks; $i++) {
    if (Is-ServerRunning) { exit }
    Start-Sleep -Seconds $intervalSeconds
}

# 连续失败 -> 修复
Try-Fix
Start-Sleep -Seconds $postFixWaitSeconds

# 修复成功就退出
if (Is-ServerRunning) { exit }

# 修复失败 -> 重启系统
Restart-Computer -Force