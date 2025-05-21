#!/bin/bash
set -e
set -x

# Set target directories (must match plugin.sh)
AEX_DST="$HOME/cutefishaep/AeNux/Plug-ins"
CEP_DST="$HOME/.wine/drive_c/Program Files (x86)/Common Files/Adobe/CEP/extensions"
PRESET_DST="$HOME/Documents/Adobe/After Effects 2024/User Presets"

# Check for Zenity
if ! command -v zenity &> /dev/null; then
    echo "[DEBUG] Zenity not found. Installing..."
    sudo apt install zenity -y 
fi

# Zenity checklist for plugin selection
CHOICES=$(zenity --list --checklist \
    --title="Select Plugins to Uninstall" \
    --text="Choose which plugins you want to uninstall:" \
    --column="Uninstall" --column="Plugin" --column="Description" \
    FALSE "AEX" "AeNux AEX Plug-ins" \
    FALSE "CEP" "CEP Flow Extension" \
    FALSE "PRESET" "Preset Backup" \
    FALSE "INSTALLER" "Uninstall .exe Software" \
    --separator=":" \
)

if [ -z "$CHOICES" ]; then
    echo "[DEBUG] No plugins selected. Exiting."
    exit 0
fi

IFS=":" read -ra SELECTED <<< "$CHOICES"

uninstall_aex=false
uninstall_cep=false
uninstall_preset=false
uninstall_installer=false

for choice in "${SELECTED[@]}"; do
    case "$choice" in
        AEX) uninstall_aex=true ;;
        CEP) uninstall_cep=true ;;
        PRESET) uninstall_preset=true ;;
        INSTALLER) uninstall_installer=true ;;
    esac
done

if $uninstall_aex; then
    echo "[DEBUG] Removing Aex plugins..."
    if [ -d "$AEX_DST" ]; then
        rm -rf "$AEX_DST"/*
        echo "[DEBUG] $AEX_DST cleared."
    else
        echo "[DEBUG] $AEX_DST does not exist."
    fi
fi

if $uninstall_cep; then
    echo "[DEBUG] Removing CEP flow extension..."
    if [ -d "$CEP_DST/flowv1.4.2" ]; then
        rm -rf "$CEP_DST/flowv1.4.2"
        echo "[DEBUG] $CEP_DST/flowv1.4.2 removed."
    else
        echo "[DEBUG] $CEP_DST/flowv1.4.2 does not exist."
    fi
fi

if $uninstall_preset; then
    echo "[DEBUG] Removing preset folders..."
    PRESET_FOLDERS=(
        "Adobe Express"
        "AeNux"
        "Backgrounds"
        "Behaviors"
        "Image - Creative"
        "Image - Special Effects"
        "Image - Utilities"
        "Legacy"
        "Shapes"
        "Sound Effects"
        "Synthetics"
        "Text"
        "Transitions - Dissolves"
        "Transitions - Movement"
        "Transitions - Wipes"
    )
    for folder in "${PRESET_FOLDERS[@]}"; do
        target="$PRESET_DST/$folder"
        if [ -d "$target" ]; then
        cd "$HOME/Documents"
            rm -rf "$target"
            echo "[DEBUG] $target removed."
        else
            echo "[DEBUG] $target does not exist."
        fi
    done
fi

if $uninstall_installer; then
    zenity --info \
        --title="Manual Uninstall Required" \
        --text="After this, you need to manually uninstall via Software Manager!\n\nThe Wine Uninstaller will now open."
    wine uninstaller
fi

echo "[DEBUG] Uninstallation complete!"