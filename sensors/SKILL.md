---
name: "Termux Sensors & Battery"
description: "读取Android设备传感器数据和电池状态"
version: "1.0.0"
tags: ["sensors", "battery", "android", "hardware"]
author: "OpenClaw Community"
parent: "termux-core"
priority: 70
---

## 电池状态监控

### 获取当前电池信息
```bash
termux-battery-status
```

### 返回JSON格式数据：
```json
{
  "health": "GOOD",
  "percentage": 85,
  "plugged": "AC",
  "status": "CHARGING",
  "temperature": 32.5,
  "current": 1200,
  "voltage": 4200
}
```

### 实用示例
```bash
# 仅显示电量百分比
termux-battery-status | jq -r '.percentage'

# 检查是否在充电
termux-battery-status | jq -r '.status' | grep -q "CHARGING" && echo "🔌 正在充电"

# 低电量警告（<20%）
[ $(termux-battery-status | jq '.percentage') -lt 20 ] && termux-toast "⚠️ 电量低！"
```

### 传感器数据读取
#### 支持的传感器类型
- accelerometer - 加速度计
- gyroscope - 陀螺仪
- magnetometer - 磁力计（指南针）
- light - 光线传感器
- proximity - 距离传感器

#### 基础用法
```bash
# 读取单次传感器数据
termux-sensor -s accelerometer

# 持续读取（每1000ms一次，共5次）
termux-sensor -s light -d 1000 -n 5

# 后台持续监控（需手动终止）
termux-sensor -s gyroscope -d 500 > ~/sensor_log.txt &
```
#### 实用示例
```bash
# 获取当前光线强度
termux-sensor -s light -n 1 | jq -r '.light[0]'

# 检测设备是否晃动（加速度变化）
termux-sensor -s accelerometer -n 3 -d 100 | jq '
  .accelerometer as $acc |
  ($acc[1][0] - $acc[0][0]) as $dx |
  ($acc[1][1] - $acc[0][1]) as $dy |
  ($acc[1][2] - $acc[0][2]) as $dz |
  sqrt($dx*$dx + $dy*$dy + $dz*$dz) > 2.0
'
```

### 自动化场景
#### 电池优化工作流
```bash
# 低电量时自动降低采样频率
BATTERY=$(termux-battery-status | jq '.percentage')
if [ $BATTERY -lt 30 ]; then
  SAMPLE_RATE=2000  # 2秒一次
else
  SAMPLE_RATE=500   # 0.5秒一次
fi
termux-sensor -s accelerometer -d $SAMPLE_RATE
```
#### 传感器数据记录
```bash
# 记录10秒的加速度数据到文件
termux-sensor -s accelerometer -d 100 -n 100 > ~/accel_data_$(date +%s).json
```
### 注意事项
- ⚠️ 权限要求：首次使用需在Termux:API App中授权"身体传感器"权限
- ⚠️ 耗电警告：持续传感器采样会显著增加电池消耗，建议设置合理间隔（≥500ms）
- ⚠️ 数据格式：所有传感器数据返回JSON格式，使用jq工具解析更方便
- ⚠️ 后台限制：Android系统可能在后台限制传感器访问，重要任务建议保持屏幕常亮

### 故障排查
termux-sensor 返回空 --> 检查设备是否支持该传感器类型
传感器数据不更新      --> 增加延迟参数 -d（如 -d 1000）
权限被拒绝           --> 在Termux:API App设置中手动开启传感器权限
jq 命令未找到        --> 执行 pkg install jq 安装JSON解析工具

