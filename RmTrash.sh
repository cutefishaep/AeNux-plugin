#!/bin/bash
# Remove unwanted Wine application shortcuts
# Disable globbing to prevent issues with special characters
set -f


WINE_DIR=$HOME/.local/share/applications/wine

if [ -d "$WINE_DIR" ]; then
    echo "[DEBUG] Removing \"$WINE_DIR\""
    rm -rf "$WINE_DIR"
else
    echo "[DEBUG] \"$WINE_DIR\" does not exist, skipping."
fi

# Re-enable globbing if needed
set +f