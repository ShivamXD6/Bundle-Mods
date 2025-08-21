# 🗃️ Bundle-Mods
> A tool that lets you bundle or pack all your .zip modules into one neat pack, including installed modules, set a custom name and author, and much more, perfect for carrying your favorite modules without carrying multiple zips.

![Downloads](https://img.shields.io/github/downloads/ShivamXD6/Bundle-Mods/total?color=green&style=for-the-badge)
![Release](https://img.shields.io/github/v/release/ShivamXD6/Bundle-Mods?style=for-the-badge)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Magisk](https://img.shields.io/badge/Magisk-8A2BE2?style=for-the-badge&logo=magisk&logoColor=white)
![Root](https://img.shields.io/badge/Root-ff0000?style=for-the-badge&logo=superuser&logoColor=white)

## ❔ What it does:
- 🧳 Combines all your `.zip` modules into one single zip file.
- 🧩 Include your currently installed modules in the same pack as well.
- 🏷️ Rename the final zip to set a custom name and author (by renaming the files).
- 🎮 Use volume buttons to control everything else.
- 🛠️ Supports: Magisk, KernelSU, APatch, and their forks.

> [!NOTE]
> ⚠️ Installed modules may not always be fully supported, check their compatibility status or prefer using zip files.

## 📖 Documentation
<details>
  <summary>📖 Everything About Module</summary>

  ## Scan Modes
  This tool can search for `.zip` modules in two ways (both are quick):
  - **Quick Scan:** Only checks the `Download` folder.
  - **Deep Scan:** Searches the whole Internal Storage.

  It also scans for:
  - **Installed Modules:** Finds modules inside `/data/adb/modules`.

  ## Prioritize Some ZIP Modules
  Some modules must be installed before others to avoid issues.
  - Modules marked with `⚡` are given priority and installed first.
  - **Example:** Shamiko fails if Zygisk Next isn’t installed before it.
   
  ## Compatibility of Installed Modules
  Not every installed module can be packed successfully. Many rely on special installation scripts found only in their original `.zip` files.
  To make this clear, modules are marked with a compatibility status:
  
  - 🟢 **Compatible:** Directory looks good, follows the standard module structure, and should work without problems.
  - 🟡 **Limited:** Modules that are device specific or depend on extra files/libraries. These may work, but success depends on your device and the module itself.
  - 🔴 **Incompatible:** Modules that don’t follow the basic structure or use custom directories. These are very unlikely to work when packed. Instead pack it's `.zip` file.
</details>

## 📥 Installation Guide

### Just flash Module and follow the instructions display on your screen :)
- **Still there are some video guides:**
- [How to pack modules?](https://telegram.me/buildbytes/51)
- [How to install modules pack?](https://telegram.me/buildbytes/52)

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
[Join our Telegram group](https://telegram.me/buildbytesdiscussion) and send a message with **#contribute**.
If I like your idea or fix, I’ll upload the full source (except the verification part) on GitHub so you can contribute easily.
