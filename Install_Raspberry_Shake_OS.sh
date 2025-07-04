#!/bin/bash

##################################
#FORMAT SD CARD
#sudo umount /dev/sde*
#sudo wipefs -a /dev/sde
#sudo parted /dev/sde --script mklabel msdos
#sudo parted /dev/sde --script mkpart primary fat32 1MiB 100%
#sudo mkfs.vfat -F 32 /dev/sde1

##########################
# Define paths
ZIP_PATH="/home/sig/Downloads/raspishake-release.zip"
WORK_DIR="/home/sig/Downloads/raspishake-work"
IMG_NAME="rshake-os.img"

if [ -d $WORK_DIR ]; then
  rm -rf $WORK_DIR
fi

# Ensure working directory exists
mkdir -p "$WORK_DIR"

# Step 1: Check if ZIP file exists
if [ ! -f "$ZIP_PATH" ]; then
    echo "Error: $ZIP_PATH not found."
    exit 1
fi

echo "Extracting $ZIP_PATH to $WORK_DIR..."
unzip -o "$ZIP_PATH" -d "$WORK_DIR" || { echo "Unzip failed"; exit 1; }

# Step 2: Find .xz file
XZ_FILE=$(find "$WORK_DIR" -name "*.xz" | head -n 1)
if [ -z "$XZ_FILE" ]; then
    echo "Error: No .xz file found in extracted content."
    exit 1
fi

echo "Decompressing $XZ_FILE..."
xz -dk "$XZ_FILE" || { echo "Decompression failed"; exit 1; }

# Get decompressed .img path
IMG_FILE="${XZ_FILE%.xz}"

# Step 3: Confirm SD card path
echo ""
echo "⚠️ WARNING: You are about to write to an SD card. This will erase all data on the device."
lsblk
read -rp "Enter the device path for your SD card (e.g., /dev/sdb): " SD_DEVICE

if [[ ! -b "$SD_DEVICE" ]]; then
    echo "Error: $SD_DEVICE is not a valid block device."
    exit 1
fi

read -rp "Are you sure you want to write to $SD_DEVICE? (yes/NO): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Aborting."
    exit 0
fi

# Step 4: Burn image to SD card
echo "Writing $IMG_FILE to $SD_DEVICE..."
sudo dd if="$IMG_FILE" of="$SD_DEVICE" bs=4M status=progress conv=fsync || { echo "dd failed"; exit 1; }

echo "✅ Done. You may now insert the SD card into your Raspberry Shake device."

