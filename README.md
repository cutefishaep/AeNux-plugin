# 🎬 AeNux Plugin Installer

A simple, interactive Bash script to help you install and manage After Effects plugins, extensions, and presets on Linux (with Wine).  
**Supports:** `.aex` plugins, CEP extensions, presets, and Windows installers.

---

## 🚀 Features

- **Automatic Dependency Check:** Installs `zenity` if missing.
- **Smart Download:** Downloads all required plugin folders if missing or incomplete.
- **Interactive Selection:** Choose which plugin components to install via a GUI checklist.
- **Wine Integration:** Installs Windows `.exe` plugin installers using Wine.
- **Safe & Clean:** Cleans up unnecessary files and Wine shortcuts after installation.

---

## 📦 Folder Structure

```
AeNux-plugin/
├── aex/                # .aex plugin files
├── CEP/                # CEP extensions (e.g., flow)
├── installer/          # Windows .exe plugin installers
├── preset-backup/      # Preset files for After Effects
├── scripts/            # Additional scripts
├── plugin.sh           # Main installer script
└── README.md           # This file
```

---

## ❤️ Plugin list

```
- BCC
- SAPP***
- Element **
- Flow
- R* Universe
- Twix***
- RS**
- GLITCH***
AND MORE!!
```

## 🛠️ Requirements

- **Linux** (tested on Ubuntu/Debian)
- **Wine** (for running Windows installers)
- **Zenity** (for GUI dialogs)
- **wget**, **unzip**, **cp**, **rm** (standard utilities)

---

## ⚡ Quick Start

1. **Clone or Download** this repository.
2. **Make the script executable:**
   ```bash
   chmod +x plugin.sh
   ```
3. **Run the installer:**
   ```bash
   ./plugin.sh
   ```
4. **Follow the on-screen Zenity dialogs** to select and install plugins.

---

## 🧩 What Gets Installed?

- **AEX:** `.aex` plugin files to `~/cutefishaep/AeNux/Plug-ins`
- **CEP:** Flow extension to your Wine Adobe CEP directory
- **PRESET:** Presets to `~/Documents/Adobe/After Effects 2024/User Presets`
- **INSTALLER:** Runs `.exe` installers in Wine and copies any resulting `.aex`/license files

---

## 🧹 Cleanup

The script will remove unnecessary Wine application shortcuts for a cleaner menu.

---

## 📝 Notes

- If required folders are missing, the script will prompt to download a 2GB ZIP from HuggingFace.
- For `.exe` installers, **manual steps may be required** after installation (see Zenity instructions).
- **No files are deleted** unless you confirm via Zenity.

---

## 💬 Troubleshooting

- **Wine not installed?**  
  Install with: `sudo apt install wine`
- **Zenity not installed?**  
  The script will auto-install it, or run: `sudo apt install zenity`
- **Permission denied?**  
  Run: `chmod +x plugin.sh`

---

## 🤝 Credits

- [cutefishae/AeNux-model on HuggingFace](https://huggingface.co/cutefishae/AeNux-model)
- Inspired by the After Effects plugin community

---

## 📜 License

This project is provided for educational and personal use only.  
Redistribution or commercial use is not permitted.

---

> **Happy Editing!** 🎉
