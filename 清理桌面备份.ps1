# 清理桌面上的旧备份文件
$desktopPath = [Environment]::GetFolderPath('Desktop')
$oldBackups = Get-ChildItem -Path $desktopPath -Filter 'U盘备份_*' -Directory -ErrorAction SilentlyContinue
$oldLogs = Get-ChildItem -Path $desktopPath -Filter 'USBCopyLog.txt' -File -ErrorAction SilentlyContinue

Write-Host '桌面清理结果:' -ForegroundColor Yellow

if ($oldBackups) {
    foreach ($backup in $oldBackups) {
        Remove-Item -Path $backup.FullName -Recurse -Force
        Write-Host ("✓ 已删除: {0}" -f $backup.Name) -ForegroundColor Green
    }
} else {
    Write-Host '✗ 未找到备份文件夹' -ForegroundColor Gray
}

if ($oldLogs) {
    Remove-Item -Path $oldLogs.FullName -Force
    Write-Host ("✓ 已删除: {0}" -f $oldLogs.Name) -ForegroundColor Green
} else {
    Write-Host '✗ 未找到日志文件' -ForegroundColor Gray
}

Write-Host '' -ForegroundColor White
Write-Host '桌面已清理完成！现在只会保存到: D:\ProgramDate\appcompat\usb' -ForegroundColor Cyan
