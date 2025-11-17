# 🗃️ Bundle-Mods
> A simple tool that lets you bundle all your magisk or lsposed modules or even your local apps or user apps (with parts like Swift Backup) into one neat pack or in a separate folder, set a custom name, author, version, and much more, perfect for carrying your favorite modules or apps without carrying multiple files.

[![Downloads](https://img.shields.io/github/downloads/ShivamXD6/Bundle-Mods/total?color=green&style=for-the-badge)](https://github.com/ShivamXD6/Bundle-Mods/releases/latest)
[![Release](https://img.shields.io/github/v/release/ShivamXD6/Bundle-Mods?style=for-the-badge)](https://github.com/ShivamXD6/Bundle-Mods/releases/latest)
[![Join Build Bytes](https://img.shields.io/badge/Join-Build%20Bytes-2CA5E0?style=for-the-badge&logo=telegram)](https://telegram.me/BuildBytes)
[![Join Chat](https://img.shields.io/badge/Join%20Chat-Build%20Bytes%20Discussion-2CA5E0?style=for-the-badge&logo=telegram)](https://telegram.me/BuildBytesDiscussion)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Root](https://img.shields.io/badge/Root-ff0000?style=for-the-badge&logo=superuser&logoColor=white)
![Magisk](https://img.shields.io/badge/Magisk-8A2BE2?style=for-the-badge&logo=magisk&logoColor=white)
![KernelSU](https://img.shields.io/badge/KernelSU-000000?style=for-the-badge&logo=linux&logoColor=white)
![APatch](https://img.shields.io/badge/APatch-FF6B00?style=for-the-badge&logo=android&logoColor=white)

## ❔ What it does:
- 🧳 Combines all your `.zip` modules or app files (`.apk`, `.apks`, `.apkm`) into a single pack.
- 📱 Additionally Include User Apps with their parts/data much faster then Swift Backup or other Data Backup Apps.
- 🧩 Add **LSPosed modules** and other supported modules to the same pack.
- 🗂️ Optionally it includes **backup & restore data** for certain modules (e.g., ReVanced settings, Tricky Store).
- ⚙️ Add a **custom installation script** to run before or after pack installation.
- 🏷️ Rename the final pack to set a custom name, version and author (by renaming the files).
- ✂️ **Selection method:** just delete placeholders to select those modules or apps easily.
- 🎮 Control installation with **volume buttons**.
- 🛠️ Supports: Magisk, KernelSU, APatch, and their forks.

## 📖 Documentation

  ## SD Card Support?
  - Yes, it supports sdcard you will prompt to select for backup or restore, if there's any sdcard exist.

  ## Can I rename #Backup folder to something else?
  - Yes you can, just keep `.bundle-mods` file in it to check later if it's a backup folder or not.
  
  ## Backup Styles:
  - **Separate Folder** - Faster, no Compression or extraction but less portability, messy many files.
  - **Zip Package** - Slower, because of compression and extraction but better portability, neat 1 file.
  
  ## Selection Styles:
  - Delete temporary Files or placeholders to select modules or apps in `Delete_To_Select` folder.
  - Use Volume Keys to Select, (not much advanced or fast)

  ## What it can backup?
  - Magsik or ZIP modules [Emojis: 🔗⚡]
  - User Apps (with Data) [Emoji: 📱]
  - LSPosed Modules [Emoji: 🧩]
  - Local Apps (supports: apk,apks,apkm) [Emoji: 📲]

  ## Prioritize Some ZIP Modules
  Some modules must be installed before others to avoid issues.
  - Modules marked with `⚡` are given priority and installed first.
  - **Example:** Shamiko fails if Zygisk Next isn’t installed before it.

  ## Backup Restore modules data
  - It backups or restores data from the respective paths from the data.sh.
  
  ## User Apps

  ### Selection Method for Components/Parts of Apps
  - If you select app only, and delete it's temporary/placeholder file, it will auto select available parts (except Android ID or All Permissions)
  - For selecting specific parts, select parts and apps (which you want to backup for the apps)
  
  ### Why it's faster then apps like Swift Backup?
  - It uses ZAPDOS (zstd) with tar as it's compressing binary, which is much faster then zip or other binaries.
  - For Batch backup or installation, it uses Parallel Processing with Decreasing order of Apps sizes.
  - Also for Batch apps installation, it install app and runs optimization for that particular app in Background, meanwhile it install the next app which saves time.
  - [Click to Check the Comparison Between Swift Backup and Bundle Mods Here](https://telegram.me/buildbytes/142)
  
  ### What it backup?
  - `#App` - App (including splits)
  - `#Data` - Data (from /data/data)
  - `#UserDe` (included with data default) - User Direct Encryption (from /data/user_de)
  - `#ExtData` - External Data (from /Internal Storage/Android/data)
  - `#Media` - Media (from /Internal Storage/Android/media)
  - `#Obb` - OBB (from /Internal Storage/Android/obb)
  - `Granted Permissions` by default backup.
  - `#PermAll` - All Supported Permissions (not only granted one)
  - `#AndroidID` - SSAID (from /data/system/users/0/settings_ssaid.xml)

  ## Pre-Install and Post-Install Scripts
  You can add your own custom installation scripts either in zip file directly or by placing them in: ``/Internal Storage/#Backup/``
  They will be automatically executed if named:
  
  **Pre-Install.sh** → Runs before installation of modules or apps.
  
  **Post-Install.sh** → Runs after installation of modules or apps.

## 📥 Installation Guide

### Just flash Module and follow the instructions display on your screen :)
### [Created Modules pack example here](https://t.me/buildbytes/54)

> [!NOTE]
> This module doesn’t install itself. It just helps you to build or install your modules pack.

## 🙏 Support & Donations

If you find Bundle-Mods helpful and want to support development, you can donate here:

💰 **PayPal:** [Donate via PayPal](https://paypal.me/ShivamXD6)

📲 **SuperMoney:** UPI ID - **shivam.dhage@superyes**

🔗 **GPay UPI QR Code:** [Donate via UPI QR](https://i.ibb.co/5g4J2RXR/1f38d6d7-a8a2-4696-88e6-9cf503e0592c.png)

Every contribution helps keep the project alive and improved! Thank you! 😊

## 🤝 Contribute
### Want to help improve this project?
Even if you don't know coding much you can contribute to data.sh for modules data paths :)
