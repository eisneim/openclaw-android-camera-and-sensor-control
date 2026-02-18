---
name: "Termux Camera Capture"
description: "专业级拍照/录像控制，支持多摄像头选择与参数配置"
version: "1.1.0"
tags: ["camera", "photo", "video", "android"]
author: "特里"
parent: "termux-core"
priority: 90
---

## 拍照工作流

### 基础拍照（带自动压缩）
```bash
# 使用capture_helper.sh脚本（推荐）
~/.openclaw/skills/termux-core/camera/scripts/capture_helper.sh -c 0 -o ~/.openclaw/workspace/task_folder/test_photo.jpg
```

### 手动拍照流程
```bash
# 1. 拍照
termux-camera-photo -c 0 ~/raw.jpg

# 2. 等待异步完成（关键！）
sleep 1

# 3. 压缩图片（适配飞书文件限制）
magick convert ~/raw.jpg -resize "2048x2048>" ~/test_photo.jpg

# 4. 清理临时文件
rm ~/raw.jpg
```

### 专业参数
参数: -c 0    
说明：后置摄像头（默认）
示例: capture_helper.sh -c 0 -o ~/photo.jpg

参数: -c 1    
说明：前置摄像头
示例: capture_helper.sh -c 1 -o ~/selfie.jpg

参数: -o PATH     
说明：输出路径（必须指定）
示例: -o ~/my_photo.jpg

### 录像工作流
录制10秒视频（无压缩）
termux-camera-record -d 10 ~/clip_$(date +%s).mp4

### 自动化技巧
#### 飞书优化工作流
- 所有拍照操作必须包含以下步骤：
- 拍摄原始高分辨率照片到临时文件（如 ~/raw.jpg）
- 延迟至少1秒 确保异步写入完成
- 使用 ImageMagick 压缩：magick convert ~/raw.jpg -resize "2048x2048>" [输出路径]
- 删除临时原始文件

### 定时连拍（压缩版）
```bash
for i in {1..5}; do
  ~/openclaw/skills/termux-core/camera/scripts/capture_helper.sh -c 0 -o ~/timelapse_$i.jpg
  sleep 3
done
```

### 其他相关指令
录音： termux-microphone-record -d 5 ~/audio.mp3
获取摄像头信息（前后置、支持分辨率）： termux-camera-info
播放媒体文件： termux-media-player play ~/music.mp3
触发系统媒体扫描（使相册可见新文件）：termux-media-scan ~/new_photo.jpg

### 常见问题
- ❓ 照片上传飞书失败 → 确保使用 -resize "2048x2048>" 压缩，避免超过10MB限制
- ❓ 脚本找不到 → 确认脚本路径为 ~/.openclaw/skills/termux-core/camera/scripts/capture_helper.sh
- ❓ magick convert命令未找到 → 在Termux中执行 pkg install imagemagick