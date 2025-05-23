#!/bin/bash
set -e
set -x  # Enable full debug (print each command before executing)

# Ensure zenity is installed
if ! command -v zenity &> /dev/null; then
    echo "[DEBUG] Zenity not found. Installing..."
    sudo apt install zenity -y
fi

# Required folders
REQUIRED_FOLDERS=("aex" "CEP" "installer" "preset-backup" "scripts")
MISSING_FOLDERS=()
FOUND_FOLDERS=0

for folder in "${REQUIRED_FOLDERS[@]}"; do
    if [ -d "$folder" ]; then
        FOUND_FOLDERS=$((FOUND_FOLDERS+1))
    else
        MISSING_FOLDERS+=("$folder")
    fi
done

if [ "$FOUND_FOLDERS" -eq 0 ]; then
    zenity --question \
        --title="AeNux Plugin not found" \
        --text="AeNux Plugin not found, do you want to download it now?\nSize: 2gb" \
        --ok-label="Yes" \
        --cancel-label="No"
    if [ $? -ne 0 ]; then
        zenity --info --title="Exiting..." --text="Exiting..."
        exit 0
    fi
    wget -O aenux-require-plugin.zip "https://huggingface.co/cutefishae/AeNux-model/resolve/main/aenux-require-plugin.zip"
    unzip aenux-require-plugin.zip
    zenity --question \
        --title="Delete ZIP?" \
        --text="Do you want to delete the .zip file?\nIt's no longer needed." \
        --ok-label="Yes" \
        --cancel-label="No"
    if [ $? -eq 0 ]; then
        rm -f aenux-require-plugin.zip
    fi
elif [ "${#MISSING_FOLDERS[@]}" -ne 0 ]; then
    zenity --question \
        --title="AeNux Plugin detected" \
        --text="AeNux Plugin detected, but not all required plugin folders are here:\n${MISSING_FOLDERS[*]}\nDo you want to download it completely?"
    if [ $? -ne 0 ]; then
        zenity --info --title="Exiting..." --text="Exiting..."
        exit 0
    fi
    wget -O aenux-require-plugin.zip "https://huggingface.co/cutefishae/AeNux-model/resolve/main/aenux-require-plugin.zip"
    unzip -o aenux-require-plugin.zip
    zenity --question \
        --title="Delete ZIP?" \
        --text="Do you want to delete the .zip file?\nIt's no longer needed." \
        --ok-label="Yes" \
        --cancel-label="No"
    if [ $? -eq 0 ]; then
        rm -f aenux-require-plugin.zip
    fi
fi
# Set target directories
AEX_SRC="aex"
AEX_DST="$HOME/cutefishaep/AeNux/Plug-ins"

CEP_SRC="CEP/flowv1.4.2"
CEP_DST="$HOME/.wine/drive_c/Program Files (x86)/Common Files/Adobe/CEP/extensions"

PRESET_SRC="preset-backup/"
PRESET_DST="$HOME/Documents/Adobe/After Effects 2024/User Presets"

INSTALLER_SRC="installer"

echo "[DEBUG] Checking for Zenity..."
if ! command -v zenity &> /dev/null; then
    echo "[DEBUG] Zenity not found. Installing..."
    sudo apt install zenity -y 
fi

# Zenity checklist for plugin selection
CHOICES=$(zenity --list --checklist \
    --title="Select Plugins to Install" \
    --text="Choose which plugins you want to install:" \
    --column="Install" --column="Plugin" --column="Description" \
    TRUE "AEX" ".aex plugin" \
    TRUE "CEP" "For now only flow available!" \
    TRUE "PRESET" "Base preset + AeNux Preset" \
    TRUE "INSTALLER" "Run .exe Installers" \
    --separator=":" \
)

if [ -z "$CHOICES" ]; then
    echo "[DEBUG] No plugins selected. Exiting."
    exit 0
fi

# Convert choices to array for easier checking
IFS=":" read -ra SELECTED <<< "$CHOICES"

install_aex=false
install_cep=false
install_preset=false
install_installer=false

for choice in "${SELECTED[@]}"; do
    case "$choice" in
        AEX) install_aex=true ;;
        CEP) install_cep=true ;;
        PRESET) install_preset=true ;;
        INSTALLER) install_installer=true ;;
    esac
done

if $install_aex; then
    echo "[DEBUG] Copying Aex plugins..."
    mkdir -p "$AEX_DST"
    if [ -d "$AEX_SRC" ] && [ "$(ls -A "$AEX_SRC")" ]; then
        cp -r "$AEX_SRC"/* "$AEX_DST"/
    else
        echo "[DEBUG] Warning: $AEX_SRC is empty or does not exist."
    fi
fi

if $install_cep; then
    echo "[DEBUG] Copying CEP flow extension..."
    if [ -f "AddKeys.reg" ]; then
        wine regedit "AddKeys.reg"
    else
        echo "[DEBUG] Warning: AddKeys.reg not found, skipping registry import."
    fi
    mkdir -p "$CEP_DST"
    if [ -d "$CEP_SRC" ] && [ "$(ls -A "$CEP_SRC")" ]; then
        wine regedit "$CEP_DST/AddKeys.reg"
    else
        echo "[DEBUG] Warning: $CEP_SRC is empty or does not exist."
    fi
fi

if $install_preset; then
    echo "[DEBUG] Copying preset-backup..."
    mkdir -p "$PRESET_DST"
    if [ -d "$PRESET_SRC" ] && [ "$(ls -A "$PRESET_SRC")" ]; then
        cp -r "$PRESET_SRC" "$PRESET_DST"/
    else
        echo "[DEBUG] Warning: $PRESET_SRC is empty or does not exist."
    fi
fi

if $install_installer; then
    echo "[DEBUG] Prompting user with Zenity..."
    zenity --question \
        --title="Manual Installation Required" \
        --text="After this, you will install software in .exe format. This process cannot be done automatically—you will need to manually copy the files to:\n\n$HOME/cutefishaep/AeNux/Plug-ins (for plugins)\n\nDo you want to continue?" \
        --ok-label="Yes" \
        --cancel-label="Nevermind"

    if [ $? -ne 0 ]; then
        echo "[DEBUG] Installation cancelled."
        exit 1
    fi
    if [ -d "$INSTALLER_SRC" ]; then
        cd "$INSTALLER_SRC"

        # Separate E3D.exe and saber.exe from other installers
        E3D_EXE="E3D.exe"
        SABER_EXE="saber.exe"

        # Install all .exe except E3D.exe and saber.exe
        for exe in *.exe; do
            if [ -f "$exe" ] && [[ "$exe" != "$E3D_EXE" && "$exe" != "$SABER_EXE" ]]; then
                echo "[DEBUG] Installing: $exe"
                wine "$exe" /verysilent /suppressmsgboxes || echo "[DEBUG] Failed to install $exe"
            fi
        done

        # Now run E3D.exe and saber.exe, but do not copy Element.aex or Element.license yet
        while true; do
            for special_exe in "$E3D_EXE" "$SABER_EXE"; do
                if [ -f "$special_exe" ]; then
                    echo "[DEBUG] Running installer: $special_exe"
                    wine "$special_exe" || echo "[DEBUG] Failed to run $special_exe"
                else
                    echo "[DEBUG] $special_exe not found, skipping."
                fi
            done

            zenity --question \
                --title="Manual Step Required" \
                --text="Are you done installing Element3D and Saber?" \
                --ok-label="Yes" \
                --cancel-label="No"

            if [ $? -eq 0 ]; then
                break
            fi
        done

        # After confirmation, copy Element.aex and Element.license if they exist
        if [ -f "Element.aex" ]; then
            cp "Element.aex" "$AEX_DST/VideoCopilot"/
            echo "[DEBUG] Copied Element.aex to $AEX_DST"
        fi
        if [ -f "Element.license" ]; then
            cp "Element.license" "$AEX_DST/VideoCopilot"/
            echo "[DEBUG] Copied Element.license to $AEX_DST"
        fi

        cd - > /dev/null
    else
        echo "[DEBUG] Warning: $INSTALLER_SRC does not exist."
    fi
fi

echo "[DEBUG] All done!"
