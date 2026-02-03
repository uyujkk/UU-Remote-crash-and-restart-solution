$uuProcesses = @(
    "GameViewerServer",
    "GameViewerService"
)

$waitSeconds = 60

function Is-UURunning {
    foreach ($p in $uuProcesses) {
        if (Get-Process -Name $p -ErrorAction SilentlyContinue) {
            return $true
        }
    }
    return $false
}

function Try-Fix-UU {

    # 尝试重启 UU 服务（如果存在）
    $services = Get-Service | Where-Object {
        $_.Name -like "*GameViewer*" -or $_.DisplayName -like "*UU*"
    }

    foreach ($s in $services) {
        try {
            Restart-Service -Name $s.Name -Force
        } catch {}
    }

    Start-Sleep -Seconds 10


    $possiblePaths = @(
        "C:\Program Files\NetEase\GameViewer\GameViewer.exe",
        "C:\Program Files (x86)\NetEase\GameViewer\GameViewer.exe"
    )

    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            Start-Process $path
            break
        }
    }
}

# ================== 主逻辑 ==================

if (Is-UURunning) {
    exit
}

Try-Fix-UU
Start-Sleep -Seconds $waitSeconds

if (Is-UURunning) {
    exit
}

# 修复失败 → 重启系统
Restart-Computer -Force

