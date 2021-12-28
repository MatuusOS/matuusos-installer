#!/usr/bin/env bash
# Ask user if they want to try MatuusOS or if they want to install it on a disk
kdialog --title "Matuusos Installer" --menu "Choose the option" 0 0 0 \
"Install MatuusOS" "Install MatuusOS on a disk" \
"Try MatuusOS" "Try MatuusOS. This will not install MatuusOS on your disk." 2> /tmp/installer.txt
cat /tmp/installer.txt
# if the value is Install MatuusOS, then proceed to next screen with dropdown menu where user can choose the timezone.
ls /usr/share/zoneinfo/*/* > /tmp/timezones.txt
kdialog --title "Matuusos Installer" --menu "Choose the timezone" 0 0 0 $(cat /tmp/timezones.txt) 2> /tmp/timezone.txt
# remember the timezone and then ask for keyboard layout
ls /usr/share/kbd/keymaps/* > /tmp/keyboards.txt
kdialog --title "Matuusos Installer" --menu "Choose the keyboard layout" 0 0 0 $(cat /tmp/keyboards.txt) 2> /tmp/keyboard.txt
# remember the keyboard layout and then ask for the hostname
kdialog --title "Matuusos Installer" --inputbox "Enter the hostname" 0 0 "matuusos" 2> /tmp/hostname.txt
# remember the hostname and then ask for the username
kdialog --title "Matuusos Installer" --inputbox "Enter the username" 0 0 "matuusos" 2> /tmp/username.txt
# remember the username and then ask for the password
kdialog --title "Matuusos Installer" --password "Enter the password" 0 0 2> /tmp/password.txt
# remember the password and then ask for the password again
kdialog --title "Matuusos Installer" --password "Enter the password again" 0 0 2> /tmp/password2.txt
# remember the password again and then ask for the disk partition layout
# when selected Standard, then use 500M to /boot and rest of the disk to /
lsblk -f >> /tmp/disks.txt
kdialog --title "Matuusos Installer" --menu "Choose the disk" 0 0 0 $(cat /tmp/disks.txt) 2> /tmp/disk.txt
# remember the disk and then ask for the partition layout
kdialog --title "Matuusos Installer" --menu "Choose the partition layout" 0 0 0 \
"Standard" "500M to /boot and rest of the disk to /" \
"Extended" "Extended partition with /boot and /" 2> /tmp/layout.txt
# remember the partition layout and then ask for the bootloader
kdialog --title "Matuusos Installer" --menu "Choose the bootloader" 0 0 0 \
"GRUB" "GRUB bootloader" \
"Syslinux" "Syslinux bootloader" 2> /tmp/bootloader.txt
# summarize the information and then ask if the user wants to proceed
kdialog --title "Matuusos Installer" --yesnocancel "Are you sure you want to install MatuusOS on this disk?\n\nHostname: $(cat /tmp/hostname.txt)\nUsername: $(cat /tmp/username.txt)\nPassword: $(cat /tmp/password.txt)\nPassword again: $(cat /tmp/password2.txt)\nTimezone: $(cat /tmp/timezone.txt)\nKeyboard layout: $(cat /tmp/keyboard.txt)\nDisk: $(cat /tmp/disk.txt)\nPartition layout: $(cat /tmp/layout.txt)\nBootloader: $(cat /tmp/bootloader.txt)" 0 0
# grep the partition from /tmp/partition.txt and then find the bigger partition
# then use the bigger partition to mount it to /mnt.
cat /tmp/partition.txt | grep -E "^[0-9]+" | sort -n | tail -n 1 > /tmp/bigger.txt
source /tmp/bigger.txt
mount $(cat /tmp/bigger.txt) /mnt
# if the user wants to install MatuusOS on what partition, then show the progress bar and then source information from /tmp/partition.txt, /tmp/bigger.txt, /tmp/layout.txt
# then create the partition and then format it.
if [ $? -eq 0 ]; then
    kdialog --progressbar "Installing MatuusOS" 0 0
    source /tmp/timezone.txt
    source /tmp/keyboard.txt
    source /tmp/hostname.txt
    source /tmp/username.txt
    source /tmp/password.txt
    source /tmp/bootloader.txt
    source /tmp/partition.txt
    source /tmp/bigger.txt
    source /tmp/layout.txt
    parted -s /dev/sda mkpart primary $(cat /tmp/bigger.txt) 100%
    mkfs.ext4 -F $(cat /tmp/partition.txt)
    mount $(cat /tmp/partition.txt) /mnt
fi
mount $(cat /tmp/partition.txt) /mnt
pacstrap /mnt - < lists/pkgs.sh

# if pacman.conf is in the lists/ directory, then copy it to /mnt/etc/pacman.conf
if [ -f lists/pacman.conf ]; then
    cp lists/pacman.conf /mnt/etc/pacman.conf
fi
kdialog --title "Matuusos Installer" --progressbar "Installing MatuusOS" 10 0
