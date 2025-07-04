#!/bin/bash

echo "For queries, contact: mohit.seismology@gmail.com"

##################################
# Step 0: Ask for SD card device

echo ""
echo "⚠️  WARNING: You are about to FORMAT an SD card. This will ERASE ALL DATA on the selected device."
lsblk
read -rp "Enter the device path of your SD card (e.g., /dev/sde): " SD_DEVICE

if [[ ! -b "$SD_DEVICE" ]]; then
    echo "Error: '$SD_DEVICE' is not a valid block device."
    exit 1
fi

read -rp "Are you absolutely sure you want to format $SD_DEVICE? This will ERASE all data. (yes/NO): " CONFIRM_FORMAT
if [[ "$CONFIRM_FORMAT" != "yes" ]]; then
    echo "Aborting format."
    exit 0
fi

##################################
# FORMAT SD CARD

echo "Unmounting and formatting $SD_DEVICE..."
sudo umount "${SD_DEVICE}"* 2>/dev/null
sudo wipefs -a "$SD_DEVICE"
sudo parted "$SD_DEVICE" --script mklabel msdos
sudo parted "$SD_DEVICE" --script mkpart primary fat32 1MiB 100%
sudo mkfs.vfat -F 32 "${SD_DEVICE}1"

##################################
# Prepare Raspberry Shake Image

ZIP_PATH="/home/sig/Downloads/raspishake-release.zip"
WORK_DIR="/home/sig/Downloads/raspishake-work"
IMG_NAME="rshake-os.img"

# Clean work dir
if [ -d "$WORK_DIR" ]; then
  rm -rf "$WORK_DIR"
fi

mkdir -p "$WORK_DIR"

if [ ! -f "$ZIP_PATH" ]; then
    echo "Error: $ZIP_PATH not found."
    exit 1
fi

echo "Extracting $ZIP_PATH to $WORK_DIR..."
unzip -o "$ZIP_PATH" -d "$WORK_DIR" || { echo "Unzip failed"; exit 1; }

# Extract .xz
XZ_FILE=$(find "$WORK_DIR" -name "*.xz" | head -n 1)
if [ -z "$XZ_FILE" ]; then
    echo "Error: No .xz file found in extracted content."
    exit 1
fi

echo "Decompressing $XZ_FILE..."
xz -dk "$XZ_FILE" || { echo "Decompression failed"; exit 1; }

IMG_FILE="${XZ_FILE%.xz}"

##################################
# Confirm before writing image

echo ""
echo "⚠️  FINAL WARNING: About to WRITE the image to $SD_DEVICE"
lsblk
read -rp "Are you sure you want to write the image to $SD_DEVICE? (yes/NO): " CONFIRM_WRITE

if [[ "$CONFIRM_WRITE" != "yes" ]]; then
    echo "Aborting write."
    exit 0
fi

echo "Writing $IMG_FILE to $SD_DEVICE..."
sudo dd if="$IMG_FILE" of="$SD_DEVICE" bs=4M status=progress conv=fsync || { echo "dd failed"; exit 1; }

echo "✅ SD card is ready. You may now insert it into your Raspberry Shake device."
