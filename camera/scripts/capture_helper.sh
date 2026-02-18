#!/data/data/com.termux/files/usr/bin/bash
# Termux Camera Helper - 封装拍照+压缩流程，专为飞书通信优化

set -e

USAGE="Usage: $0 [-c CAMERA] -o OUTPUT [-q]
Options:
  -c CAMERA  Camera ID (0=后置, 1=前置, default:0)
  -o OUTPUT  Output path (required, e.g., ~/photo.jpg)
  -q         Quiet mode (no toast)
"

CAMERA=0
OUTPUT=""
QUIET=0

while getopts "c:o:qh" opt; do
  case $opt in
    c) CAMERA=$OPTARG ;;
    o) OUTPUT=$OPTARG ;;
    q) QUIET=1 ;;
    h) echo "$USAGE"; exit 0 ;;
    *) echo "$USAGE"; exit 1 ;;
  esac
done

# 必须指定输出路径
if [ -z "$OUTPUT" ]; then
  echo "Error: Output path required (-o)" >&2
  echo "$USAGE"
  exit 1
fi

# 临时原始文件
RAW_FILE="$HOME/raw_$(date +%s).jpg"

# 1. 拍照
termux-camera-photo -c "$CAMERA" "$RAW_FILE"

# 2. 等待异步完成（关键延迟）
sleep 1

# 3. 压缩图片（适配飞书限制）
magick convert "$RAW_FILE" -resize "2048x2048>" "$OUTPUT"

# 4. 清理临时文件
rm "$RAW_FILE"

# 5. 触发媒体扫描
termux-media-scan "$OUTPUT"

# 6. 显示反馈
if [ $QUIET -eq 0 ]; then
  termux-toast "📸 已保存压缩照片: $(basename $OUTPUT)"
fi

echo "$OUTPUT"