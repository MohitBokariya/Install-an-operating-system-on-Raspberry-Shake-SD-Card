This guide helps you install the Raspberry Shake operating system onto a microSD card using a Bash script.
📥 Step 1: Download the OS

Download the latest raspishake-release.zip file from the official Raspberry Shake GitLab:

🔗 Download raspishake-release.zip
💾 Step 2: Prepare Your SD Card

Insert your microSD card into your computer.

Use the provided Bash script, which automates formatting (to FAT32) and flashing the image.

    ⚠️ Important: You must update the script to reflect the correct SD card device (e.g., /dev/sde). You can find this using the lsblk command.

📜 Step 3: Edit and Run the Script

    Edit the script:

        Change the ZIP_PATH variable to match where you've stored raspishake-release.zip

        Update the SD_DEVICE variable (or input it when prompted) to match your SD card (e.g., /dev/sde)

    Make the script executable and run it:

chmod +x Install_Raspberry_Shake_OS.sh
./Install_Raspberry_Shake_OS.sh

The script will:

    Format your SD card to FAT32

    Extract and decompress the Raspberry Shake image

    Flash the image onto the SD card

✅ Done!

Once complete, insert the SD card into your Raspberry Shake device and power it on. The system will boot and automatically unpack the image.
