# 🗃️ Bundle-Mods
> A tool that lets you bundle or pack all your .zip modules into one neat pack, including installed modules, set a custom name and author, and much more, perfect for carrying your favorite modules without carrying multiple zips.

![Downloads](https://img.shields.io/github/downloads/ShivamXD6/Bundle-Mods/total?color=green&style=for-the-badge)
![Release](https://img.shields.io/github/v/release/ShivamXD6/Bundle-Mods?style=for-the-badge)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Magisk](https://img.shields.io/badge/Magisk-8A2BE2?style=for-the-badge&logo=magisk&logoColor=white)
![Root](https://img.shields.io/badge/Root-ff0000?style=for-the-badge&logo=superuser&logoColor=white)

## ❔ What it does:
- 🧳 Combines all your `.zip` modules or app files (`.apk`, `.apks`, `.apkm`) into a single pack.
- 🧩 Add **LSPosed modules** and other supported modules to the same pack.
- 🗂️ Optionally it includes **backup & restore data** for certain modules (e.g., ReVanced settings, Tricky Store).
- ⚙️ Add a **custom installation script** to run before or after pack installation.
- 🏷️ Rename the final pack to set a custom name and author (by renaming the files).
- ✂️ **Modules selection method:** just delete placeholders to select those modules easily.
- 🎮 Control installation with **volume buttons**.
- 🛠️ Supports: Magisk, KernelSU, APatch, and their forks.

## 📖 Documentation
<details>
  <summary>📖 Everything about the Module (click here to view) </summary>

  ## Everything it can pack
  - Magsik or ZIP modules [Emojis: 🔗⚡]
  - LSPosed Modules [Emoji: 🧩]
  - Local Apps (supports: apk,apks,apkm) [Emoji: 📱]

  ## Prioritize Some ZIP Modules
  Some modules must be installed before others to avoid issues.
  - Modules marked with `⚡` are given priority and installed first.
  - **Example:** Shamiko fails if Zygisk Next isn’t installed before it.

  ## Backup Restore modules data
  - It backups or restores data from the respective paths from the data.sh.
   
  ## Pre-Install and Post-Install Scripts
  You can add your own custom installation scripts either when bundling or by placing them in: ``/Internal Storage/Download/``
  They will be automatically executed if named:
  **Pre-Install.sh** → Runs before installing modules
  **Post-Install.sh** → Runs after installing modules
  ### Below are some examples 👇
  🔹 Pre-Install Script Examples
  1. Skip/Remove Certain Modules Before Install
  ```sh
  #!/system/bin/sh
  # Example Pre-Install script
  # Use this to prevent some modules from being installed.

  DEKH "⚡ Running Pre-Install checks..." "h" # "h" represents heading with random borders

  # Suppose you don’t want 'youtube-revanced' module
  SKIPPED="youtube-revanced $SKIPPED" # or you can use func, ADDSTR "youtube-revanced" "$SKIPPED"

  # Or dynamically skip based on condition
  if getprop ro.build.version.release | grep -q "14"; then
    DEKH "⛔ Skipping youtube-revanced on Android 14"
    SKIPPED="youtube-revanced $SKIPPED"
  fi
```
**2. Prompt User to Choose Removal**
```sh
#!/system/bin/sh
# Interactive Pre-Install using Volume Keys

DEKH "🤔 Do you want to skip installing LSPosed?" "h*" # "h*" represents heading with ***** borders
DEKH "🔊 Vol+ = Yes, Skip\n🔉 Vol- = No, Install"

OPT
if [ $? -eq 0 ]; then
  SKIPPED="lsposed $SKIPPED"
  DEKH "✅ LSPosed skipped."
else
  DEKH "📥 LSPosed will be installed."
fi
```
### 🔹 Post-Install Script Examples
**1. Restore Modules Config**
```sh
#!/system/bin/sh
# Restore configs after installation

DEKH "🔁 Restoring modules config..." "h"
RSTDATA # It will run automatically by main script btw.
DEKH "✅ All configs restored."
```
**2. Post-Install Safety Check**
```
#!/system/bin/sh
# Verify if all important modules installed

IMPORTANT=("lsposed" "zygisk-detach" "riru")

for mod in "${IMPORTANT[@]}"; do
  if [ ! -d "$MODDIR/$mod" ]; then
    DEKH "❌ $mod missing after install!" "hx"
  else
    DEKH "✅ $mod is installed." "h"
  fi
done
```
</details>

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
