#!/bin/bash
set -euxo pipefail

IMG_GZ="$1"
IMG_RAW="openwrt.img"
MOUNT_DIR="/mnt/openwrt"
OUT_FILE="rootfs.tar.gz"

# 解压
gunzip -c "$IMG_GZ" > "$IMG_RAW"

# 建立 loop 设备并识别分区（自动生成 looppX）
LOOP_DEV=$(sudo losetup --show -fP "$IMG_RAW")
echo "Loop device: $LOOP_DEV"

# 查看分区信息（调试用）
sudo partx -l "$LOOP_DEV" || true

# 默认使用第2个分区（rootfs 所在）
ROOT_PART="${LOOP_DEV}p2"

# 创建挂载目录
sudo mkdir -p "$MOUNT_DIR"

# 挂载 root 分区
sudo mount "$ROOT_PART" "$MOUNT_DIR"

# 导出 rootfs
sudo tar --numeric-owner -C "$MOUNT_DIR" -czf "$OUT_FILE" .

# 清理资源
sudo umount "$MOUNT_DIR"
sudo losetup -d "$LOOP_DEV"

echo "✅ 成功生成: $OUT_FILE"
