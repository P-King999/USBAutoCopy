# 关闭开机自启动脚本
$startupFolder = [Environment]::GetFolderPath("Startup")
$shortcutPath = "$startupFolder\U盘自动复制.lnk"

if (Test-Path $shortcutPath) {
    Remove-Item $shortcutPath -Force
    Write-Host "✓ 开机自启动已关闭！" -ForegroundColor Green
} else {
    Write-Host "✗ 未找到开机自启动项" -ForegroundColor Yellow
}
