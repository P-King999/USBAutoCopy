# 停止U盘自动复制脚本
$process = Get-Process powershell -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -eq "" -and $_.Path -like "*USBAutoCopy*" }

if ($process) {
    Stop-Process -Id $process.Id -Force
    Write-Host "脚本已停止！" -ForegroundColor Green
} else {
    Write-Host "未找到运行中的脚本！" -ForegroundColor Yellow
}

# 清理WMI事件订阅
Unregister-Event -SourceIdentifier "USBInsert" -ErrorAction SilentlyContinue

Write-Host "清理完成！" -ForegroundColor Green
