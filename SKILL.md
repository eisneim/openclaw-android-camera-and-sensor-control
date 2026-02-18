---
name: "Termux Device Control"
description: "通过Termux:API控制Android设备硬件（摄像头/传感器/通知等）"
version: "1.2.0"
tags: ["android", "hardware", "termux"]
author: "特里"
requires: ["termux-api >=0.50"]
priority: 80
---

## 能力概述

本技能包提供对Android设备硬件的直接控制能力，通过Termux:API命令行接口实现。所有操作在设备本地执行，**无需Root权限**。

## 可用子技能

### 📷 摄像头控制 (`camera` 子技能)
- 拍照：`termux-camera-photo -c [0=后置|1=前置] [输出路径]`
- 录像：`termux-camera-record -d [秒数] [输出路径]`
- 查询摄像头：`termux-camera-info`

### 🔋 电池与传感器 (`sensors` 子技能)
- 电池状态：`termux-battery-status` → 返回JSON包含：
  ```json
  {"percentage":85, "status":"CHARGING", "temperature":32.5, "current":1200}

实时传感器：`termux-sensor -s [accelerometer|gyroscope] -d [延迟ms]`

###💡 闪光灯与震动
- 开关闪光灯：`termux-torch on / termux-torch off`
- 震动反馈：`termux-vibrate -d 300 (震动300ms)`

###📱 系统交互
- 剪贴板读取：`termux-clipboard-get`
- 剪贴板写入：`termux-clipboard-set "内容"`
- 系统通知：`termux-notification -t "标题" -c "内容" -i 123`
- Toast提示：`termux-toast "操作成功"`

### 安全须知
- ⚠️ 权限要求：首次使用需在Termux:API App中手动授权（设置 → 权限）
- ⚠️ 隐私保护：摄像头/位置/短信等敏感操作需用户明确授权
- ⚠️ 电量消耗：持续传感器采样会显著增加耗电

### 最佳实践
- ✅ 通知使用唯一ID便于后续移除：termux-notification -i 1001 -c "开始任务" → termux-notification-remove 1001
- ✅ 长时间录音使用后台任务：termux-job -r "termux-microphone-record -d 300 [文件名].mp3"