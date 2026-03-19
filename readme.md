# U 盘智能增量备份工具 / USB Smart Incremental Backup Tool

[English](#english) | [中文](#chinese)

---

<h2 id="english">English</h2>

> A PowerShell-based automated USB backup solution with smart incremental backup, running silently without interfering with user operations.

## 📋 Table of Contents

- [Introduction](#introduction)
- [Key Features](#key-features)
- [File Overview](#file-overview)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Backup Mechanism](#backup-mechanism)
- [FAQ](#faq)
- [Notes](#notes)

---

## 📖 Introduction

This tool is a **PowerShell-based** automated USB backup solution. When a USB drive is detected, it automatically backs up files to a specified directory, supporting **smart incremental backup** with silent operation.

**Use Cases:**
- Regular backup of important USB files
- Automatic backup upon USB insertion without manual operation
- Historical backup version retention with incremental updates

---

## ✨ Key Features

| Feature | Description |
| :--- | :--- |
| 🔄 **Auto Monitoring** | Background USB insertion event listening, no manual trigger required |
| 📦 **Incremental Backup** | MD5 hash-based comparison, only copies new or modified files |
| 🙈 **Silent Mode** | Hidden console window during operation, no interference |
| 📝 **Detailed Logs** | Independent log file for each backup with copy details and errors |
| 🔧 **High Compatibility** | Compatible with PowerShell 5.1+ and .NET 4.0+ |

---

## 📁 File Overview

| File Name | Description |
| :--- | :--- |
| `USBAutoCopy.ps1` | **Core Script**: Executes monitoring and backup logic |
| `启动脚本.bat` | **Manual Test**: Double-click to run core script in hidden mode |
| `设置开机自启动.ps1` | **Auto-Start Config**: Creates shortcut in Startup folder |
| `关闭开机自启动.ps1` | **Disable Auto-Start**: Removes shortcut from Startup folder |
| `停止脚本.ps1` | **Stop Service**: Forcefully ends running backup process |
| `清理桌面备份.ps1` | **Cleanup Tool**: Removes old backup files left on desktop |

---

## 🚀 Quick Start

### 1️⃣ First-Time Setup

```powershell
# Open PowerShell as Administrator and set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 2️⃣ Manual Run (Testing)

```bash
# Double-click 启动脚本.bat
# Script runs in background, insert USB and check target directory for backups
```

### 3️⃣ Enable Auto-Start on Boot

```powershell
# Right-click 设置开机自启动.ps1, select "Run with PowerShell"
# "Auto-start configured successfully" means completion
# Script will run automatically after system reboot
```

### 4️⃣ Stop the Script

```powershell
# Run 停止脚本.ps1 to end background monitoring
# Or end powershell.exe process in Task Manager
```

### 5️⃣ Disable Auto-Start

```powershell
# Run 关闭开机自启动.ps1 to remove boot startup entry
```

---

## ⚙️ Configuration

To modify the backup save path, edit `USBAutoCopy.ps1`:

```powershell
# Find the following variable (around line 15)
$savePath = "D:\ProgramDate\appcompat\usb"

# Change to your desired absolute path
$savePath = "E:\MyBackups\USB"

# Save the file
```

**Configurable Items:**

| Item | Default Value | Description |
| :--- | :--- | :--- |
| `$savePath` | `D:\ProgramDate\appcompat\usb` | Root directory for backup files |
| `Start-Sleep` | `8 seconds` | Wait time for USB mount after insertion |
| `Check Interval` | `5 seconds` | USB event listening interval |

---

## 🔍 Backup Mechanism

### Unique Identification

Generates unique folder based on **USB Volume Label** and **Serial Number**:

```
U 盘备份_MYUSB_A1B2C3D4/
├── 备份_20260303_143022/
├── 备份_20260303_151508/
└── FileHashCache.json
```

### Incremental Logic

```
┌─────────────────────────────────────────────────────────┐
│  First USB Insertion                                     │
│  → Copy all files                                        │
│  → Generate MD5 hash cache                               │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  Subsequent Insertions                                   │
│  → Calculate file MD5 hash                               │
│  → Compare with cache                                    │
│  → Hash unchanged → Skip                                 │
│  → Hash changed → Copy                                   │
└─────────────────────────────────────────────────────────┘
```

### File Structure

```
D:\ProgramDate\appcompat\usb/
├── 脚本启动日志.txt
├── U 盘备份_MYUSB_A1B2C3D4/
│   ├── 备份_20260303_143022/
│   │   ├── Documents/
│   │   ├── Pictures/
│   │   └── USBCopyLog.txt
│   ├── 备份_20260303_151508/
│   └── FileHashCache.json
└── U 盘备份_OTHER_C4D5E6F7/
    └── ...
```

---

## ❓ FAQ

### Q1: Script runs but no response?

```powershell
# Check execution policy
Get-ExecutionPolicy

# If Restricted, execute:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Q2: How to view backup logs?

```
# Log file location:
D:\ProgramDate\appcompat\usb\U 盘备份_*\备份_*\USBCopyLog.txt
```

### Q3: How to completely stop the script?

```powershell
# Method 1: Run stop script
.\停止脚本.ps1

# Method 2: End process via Task Manager
# Find powershell.exe → Right-click → End Task
```

### Q4: Too many backup files, how to clean up?

```powershell
# Run cleanup script (only cleans desktop leftovers)
.\清理桌面备份.ps1

# Manual cleanup:
# Navigate to D:\ProgramDate\appcompat\usb\U 盘备份_*\
# Delete unwanted 备份_* folders
```

---

## ⚠️ Notes

| Item | Description |
| :--- | :--- |
| 🔐 **Permission** | Script accesses system event logs, recommend running as Administrator |
| 💾 **Disk Space** | Ensure backup target drive has sufficient storage space |
| 📂 **File Format** | Backups retain original file structure, directly browsable |
| 🔄 **Safe Removal** | Safely remove USB after backup completes to avoid data corruption |
| 📝 **Log Retention** | Recommend periodic cleanup of old logs to save space |

---

> **Version:** 2026-03-03 Final Compatible Edition  
> **Requirements:** Windows 7+ / PowerShell 5.1+ / .NET 4.0+

---

<h2 id="chinese">中文</h2>

> 基于 PowerShell 的 U 盘自动备份解决方案，支持智能增量备份，静默运行不干扰用户操作。

## 📋 目录

- [项目简介](#项目简介)
- [核心功能](#核心功能)
- [文件说明](#文件说明)
- [快速开始](#快速开始)
- [配置说明](#配置说明)
- [备份机制详解](#备份机制详解)
- [常见问题](#常见问题)
- [注意事项](#注意事项)

---

## 📖 项目简介

本工具是一套基于 **PowerShell** 的 U 盘自动备份解决方案。当检测到 U 盘插入时，自动将文件备份至指定目录，支持**智能增量备份**，静默运行不干扰用户操作。

**适用场景：**
- 需要定期备份 U 盘重要文件
- 希望插入 U 盘后自动备份，无需手动操作
- 需要保留历史备份版本，支持增量更新

---

## ✨ 核心功能

| 功能 | 说明 |
| :--- | :--- |
| 🔄 **自动监控** | 后台监听 USB 插入事件，无需手动触发 |
| 📦 **增量备份** | 基于 MD5 哈希值比对，仅复制新增或修改的文件 |
| 🙈 **静默运行** | 运行时隐藏控制台窗口，不影响正常使用 |
| 📝 **详细日志** | 每次备份生成独立日志，记录文件复制详情与错误信息 |
| 🔧 **兼容性强** | 兼容 PowerShell 5.1 及 .NET 4.0+ 环境 |

---

## 📁 文件说明

| 文件名 | 功能描述 |
| :--- | :--- |
| `USBAutoCopy.ps1` | **核心脚本**：执行监控与备份逻辑 |
| `启动脚本.bat` | **手动测试**：双击即可隐藏窗口运行核心脚本 |
| `设置开机自启动.ps1` | **自启配置**：创建快捷方式到启动文件夹 |
| `关闭开机自启动.ps1` | **取消自启**：删除启动文件夹中的快捷方式 |
| `停止脚本.ps1` | **停止服务**：强制结束运行中的备份进程 |
| `清理桌面备份.ps1` | **清理工具**：清理桌面上遗留的旧备份文件 |

---

## 🚀 快速开始

### 1️⃣ 首次使用配置

```powershell
# 以管理员身份打开 PowerShell，执行以下命令设置执行策略
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 2️⃣ 手动运行（测试）

```bash
# 双击运行 启动脚本.bat
# 脚本将在后台启动，插入 U 盘后观察目标目录是否有备份生成
```

### 3️⃣ 设置开机自启动

```powershell
# 右键点击 设置开机自启动.ps1，选择"使用 PowerShell 运行"
# 显示"开机自启动已设置成功"即完成
# 重启电脑后脚本将自动运行
```

### 4️⃣ 停止脚本

```powershell
# 运行 停止脚本.ps1 即可结束后台监控进程
# 或在任务管理器中结束 powershell.exe 进程
```

### 5️⃣ 取消自启动

```powershell
# 运行 关闭开机自启动.ps1 即可移除开机启动项
```

---

## ⚙️ 配置说明

如需修改备份保存路径，请编辑 `USBAutoCopy.ps1` 文件：

```powershell
# 找到以下变量（约第 15 行）
$savePath = "D:\ProgramDate\appcompat\usb"

# 修改为期望的绝对路径
$savePath = "E:\MyBackups\USB"

# 保存文件即可
```

**可配置项：**

| 配置项 | 默认值 | 说明 |
| :--- | :--- | :--- |
| `$savePath` | `D:\ProgramDate\appcompat\usb` | 备份文件保存根目录 |
| `Start-Sleep` | `8 秒` | U 盘插入后等待挂载时间 |
| `Check Interval` | `5 秒` | USB 事件监听间隔 |

---

## 🔍 备份机制详解

### 唯一标识

根据 **U 盘卷标** 和 **序列号** 生成唯一文件夹：

```
U 盘备份_MYUSB_A1B2C3D4/
├── 备份_20260303_143022/
├── 备份_20260303_151508/
└── FileHashCache.json
```

### 增量逻辑

```
┌─────────────────────────────────────────────────────────┐
│  首次插入 U 盘                                           │
│  → 复制所有文件                                          │
│  → 生成 MD5 哈希缓存                                     │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  再次插入 U 盘                                           │
│  → 计算文件 MD5 哈希值                                   │
│  → 比对缓存                                              │
│  → 哈希值未变 → 跳过                                     │
│  → 哈希值变化 → 复制                                     │
└─────────────────────────────────────────────────────────┘
```

### 文件结构

```
D:\ProgramDate\appcompat\usb/
├── 脚本启动日志.txt
├── U 盘备份_MYUSB_A1B2C3D4/
│   ├── 备份_20260303_143022/
│   │   ├── 文档/
│   │   ├── 图片/
│   │   └── USBCopyLog.txt
│   ├── 备份_20260303_151508/
│   └── FileHashCache.json
└── U 盘备份_OTHER_C4D5E6F7/
    └── ...
```

---

## ❓ 常见问题

### Q1: 脚本运行后没有反应？

```powershell
# 检查执行策略
Get-ExecutionPolicy

# 如为 Restricted，请执行：
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Q2: 如何查看备份日志？

```
# 日志文件位置：
D:\ProgramDate\appcompat\usb\U 盘备份_*\备份_*\USBCopyLog.txt
```

### Q3: 如何彻底停止脚本？

```powershell
# 方法 1：运行停止脚本
.\停止脚本.ps1

# 方法 2：任务管理器结束进程
# 查找 powershell.exe → 右键结束任务
```

### Q4: 备份文件太多如何清理？

```powershell
# 运行清理脚本（仅清理桌面遗留文件）
.\清理桌面备份.ps1

# 手动清理旧备份：
# 进入 D:\ProgramDate\appcompat\usb\U 盘备份_*\
# 删除不需要的 备份_* 文件夹
```

---

## ⚠️ 注意事项

| 事项 | 说明 |
| :--- | :--- |
| 🔐 **权限要求** | 脚本需要访问系统事件日志，建议以管理员权限运行 |
| 💾 **磁盘空间** | 请确保备份目标磁盘有足够的存储空间 |
| 📂 **文件格式** | 备份保留原始文件结构，可直接浏览查看 |
| 🔄 **U 盘安全移除** | 备份完成后再安全移除 U 盘，避免数据损坏 |
| 📝 **日志保留** | 建议定期清理旧日志文件，避免占用过多空间 |

---

> **版本：** 2026-03-03 最终兼容版  
> **环境要求：** Windows 7+ / PowerShell 5.1+ / .NET 4.0+