---
name: "Termux Communications"
description: "访问Android设备的短信、通话记录和联系人信息"
version: "1.0.0"
tags: ["sms", "call", "contact", "android", "comms"]
author: "OpenClaw Community"
parent: "termux-core"
priority: 60
---

## 短信功能

### 查看短信列表
```bash
# 列出所有短信
termux-sms-list

# 按号码过滤
termux-sms-list -t "+1234567890"

# 按状态过滤（inbox/sent/draft/failed）
termux-sms-list -s inbox
```

#### 返回JSON格式示例：
```json
[
  {
    "id": "123",
    "address": "+1234567890",
    "body": "Hello from OpenClaw!",
    "date": 1700000000000,
    "status": "inbox",
    "read": 1
  }
]
```

### 发送短信
```bash
# 发送短信
termux-sms-send -n "+1234567890" "Your message here"
```

### 实用示例
```bash
# 获取最近一条未读短信
termux-sms-list -s inbox | jq 'map(select(.read == 0)) | last'

# 自动回复特定关键词
if termux-sms-list -s inbox | jq -r '.[-1].body' | grep -q "STATUS"; then
  LAST_NUM=$(termux-sms-list -s inbox | jq -r '.[-1].address')
  termux-sms-send -n "$LAST_NUM" "System OK - Battery: $(termux-battery-status | jq '.percentage')%"
fi
```

### 通话记录
#### 查看通话记录
```bash
# 列出所有通话记录
termux-call-log

# 按号码过滤
termux-call-log -n "+1234567890"

# 按类型过滤（incoming/outgoing/missed）
termux-call-log -t incoming
```

#### 返回JSON格式示例：
```json
[
  {
    "number": "+1234567890",
    "name": "John Doe",
    "type": "incoming",
    "date": 1700000000000,
    "duration": 120
  }
]
```

#### 实用示例
```bash
# 获取最近一次通话
termux-call-log | jq '.[0]'

# 统计今日通话次数
termux-call-log | jq '
  map(select(.date > (now * 1000 - 86400000))) | length
'
```

### 联系人管理
#### 查看联系人列表
```bash
# 列出所有联系人
termux-contact-list

# 按姓名搜索
termux-contact-list -n "John"
```
#### 返回JSON格式示例：
```json
[
  {
    "id": "456",
    "name": "John Doe",
    "numbers": ["+1234567890", "+0987654321"],
    "emails": ["john@example.com"]
  }
]
```

#### 实用示例
```json
# 查找联系人电话号码
termux-contact-list -n "Emergency" | jq -r '.[0].numbers[0]'

# 获取所有联系人姓名
termux-contact-list | jq -r '.[].name'
```

### 自动化场景
#### 紧急通知系统
```bash
# 低电量时自动发送短信给紧急联系人
if [ $(termux-battery-status | jq '.percentage') -lt 10 ]; then
  EMERGENCY_NUM=$(termux-contact-list -n "Emergency" | jq -r '.[0].numbers[0]')
  termux-sms-send -n "$EMERGENCY_NUM" "⚠️ 设备电量低于10%，即将关机"
fi
```

#### 通话日志备份
```bash
# 每日备份通话记录
termux-call-log > ~/call_logs/calls_$(date +%Y%m%d).json
```

### 安全与隐私
- ⚠️ 敏感权限：短信/通话/联系人属于高危权限，需在Termux:API App中明确授权
- ⚠️ 数据保护：避免在日志中明文存储电话号码和短信内容
- ⚠️ 合规使用：仅用于个人自动化，不得用于监控他人设备
- ⚠️ 飞书集成：如需将通信数据发送到飞书，务必先脱敏处理（如隐藏部分号码）

### 故障排查
命令返回空列表 --> 检查是否已授权对应权限（短信/通话/联系人）
发送短信失败 --> 确认设备有SIM卡且信号正常
联系人显示不全 --> 部分联系人可能存储在Google账户而非本地
权限被拒绝 --> 在Android系统设置 → 应用 → Termux:API → 权限中手动开启

### 最佳实践
- ✅ 敏感操作前先测试读取功能，确认权限正常
- ✅ 自动化脚本中添加错误处理，避免因权限问题崩溃
- ✅ 定期清理敏感数据缓存文件
