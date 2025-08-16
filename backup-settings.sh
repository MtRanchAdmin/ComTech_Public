#!/bin/bash

# Backup Cursor settings script

# Detect OS and set backup path
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows
    SETTINGS_PATH="$APPDATA/Cursor/User/settings.json"
    BACKUP_PATH="$APPDATA/Cursor/User/settings.json.backup"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    SETTINGS_PATH="$HOME/Library/Application Support/Cursor/User/settings.json"
    BACKUP_PATH="$HOME/Library/Application Support/Cursor/User/settings.json.backup"
else
    # Linux
    SETTINGS_PATH="$HOME/.config/Cursor/User/settings.json"
    BACKUP_PATH="$HOME/.config/Cursor/User/settings.json.backup"
fi

# Create backup
if [ -f "$SETTINGS_PATH" ]; then
    cp "$SETTINGS_PATH" "$BACKUP_PATH"
    echo "Settings backed up to: $BACKUP_PATH"
else
    echo "Settings file not found at: $SETTINGS_PATH"
    echo "Creating new settings file..."
    mkdir -p "$(dirname "$SETTINGS_PATH")"
    echo "{}" > "$SETTINGS_PATH"
fi