# 设置开机自启动脚本
$vbsPath = "D:\code\upan\静默启动.vbs"
$startupFolder = [Environment]::GetFolderPath("Startup")
$shortcutPath = "$startupFolder\U盘自动复制.lnk"

$wsh = New-Object -ComObject WScript.Shell
$shortcut = $wsh.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $vbsPath
$shortcut.Description = "U盘自动复制文件"
$shortcut.Save()

Write-Host "开机自启动已设置成功！" -ForegroundColor Green
Write-Host "快捷方式位置: $shortcutPath"
