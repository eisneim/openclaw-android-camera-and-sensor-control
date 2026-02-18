---
name: "Termux UI Interaction"
description: "与Android系统UI交互：通知、Toast提示、剪贴板和文件分享"
version: "1.0.0"
tags: ["ui", "notification", "clipboard", "android", "interaction"]
author: "OpenClaw Community"
parent: "termux-core"
priority: 65
---

## 系统通知

### 发送通知
```bash
# 基础通知
termux-notification -t "标题" -c "内容"

# 带ID的通知（便于后续管理）
termux-notification -i 1001 -t "任务开始" -c "视频处理中..."

# 带图标的通知
termux-notification -t "完成" -c "照片已保存" -s "camera"
```

### 管理通知
```bash
# 移除特定ID的通知
termux-notification-remove 1001

# 移除所有通知
termux-notification-remove-all
```
### 实用示例
```bash
# 任务进度通知
termux-notification -i 2001 -t "处理中" -c "步骤 1/3 完成" --ongoing
# ... 执行任务 ...
termux-notification -i 2001 -t "完成" -c "所有步骤完成！"
termux-notification-remove 2001
```

### Toast提示
#### 显示短暂提示
```bash
# 基础Toast
termux-toast "操作成功"

# 带位置的Toast（top/bottom）
termux-toast -g top "重要提示"

# 带时长的Toast（short/long）
termux-toast -d long "这是一条较长的提示信息"
```

#### 实用示例
```bash
# 操作反馈
if termux-camera-photo ~/photo.jpg; then
  termux-toast "✅ 拍照成功"
else
  termux-toast -g top "❌ 拍照失败"
fi
```

### 剪贴板操作
#### 读取剪贴板
```bash
# 获取当前剪贴板内容
CLIPBOARD_CONTENT=$(termux-clipboard-get)
echo "$CLIPBOARD_CONTENT"
```

#### 写入剪贴板
```bash
# 设置剪贴板内容
termux-clipboard-set "要复制的文本"

# 复制文件路径
termux-clipboard-set "~/test_photo.jpg"
```

#### 实用示例
```bash
# 快速复制最近照片路径
LATEST_PHOTO=$(ls -t ~/Pictures/*.jpg | head -1)
termux-clipboard-set "$LATEST_PHOTO"
termux-toast "📋 已复制路径: $(basename $LATEST_PHOTO)"
```

### 文件分享与打开
#### 系统分享
```bash
# 分享文本
termux-share -t "text/plain" "要分享的文本内容"

# 分享文件
termux-share ~/test_photo.jpg

# 指定MIME类型分享
termux-share -t "image/jpeg" ~/test_photo.jpg
```

### 用默认应用打开
```bash
# 打开图片
termux-open ~/test_photo.jpg

# 打开URL
termux-open https://www.example.com

# 打开文件并指定应用
termux-open -m "image/*" ~/test_photo.jpg
```

### 自动化场景
#### 多步骤反馈系统
```bash
# 步骤1：开始任务
termux-notification -i 4001 -t "AI处理" -c "开始分析照片..." --ongoing

# 步骤2：中间状态
termux-toast "🔍 正在识别内容"

# 步骤3：完成
termux-notification -i 4001 -t "AI处理完成" -c "结果已保存到剪贴板"
termux-clipboard-set "分析结果：$(cat ~/result.txt)"
```

#### 错误处理提示
```bash
# 捕获错误并友好提示
if ! command_that_might_fail; then
  termux-toast -g top "❌ 操作失败，请检查权限"
  termux-notification -t "错误" -c "请查看Termux日志获取详情" -s "error"
fi
```

### 注意事项
- ⚠️ 通知权限：部分Android版本需要在系统设置中手动开启通知权限
- ⚠️ 剪贴板安全：避免在剪贴板中存储敏感信息（密码、密钥等）
- ⚠️ 文件路径：分享文件时确保路径正确，建议使用绝对路径（以~开头）
- ⚠️ 用户体验：Toast提示时间短暂，重要信息应使用系统通知

### 故障排查
通知不显示 --> 检查Android通知设置，确保Termux有通知权限
Toast显示不全 --> 使用 -d long 参数延长显示时间
剪贴板内容丢失 --> Android系统可能清理后台应用剪贴板，重要数据及时使用
分享选项为空 --> 确保文件存在且MIME类型正确

### 最佳实践
- ✅ 重要操作使用通知（持久），次要反馈使用Toast（短暂）
- ✅ 通知使用唯一ID便于更新和移除，避免通知堆积
- ✅ 剪贴板操作后立即给出视觉反馈（Toast提示）
- ✅ 文件分享前验证文件是否存在：[ -f "$FILE" ] && termux-share "$FILE"