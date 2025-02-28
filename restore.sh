#!/usr/bin/env  bash

# MIT/X Consortium License
# © 2025 mahmoudElshimi <mahmoudelshimi@protonmail.ch>

# === Set Strict Error Handling ===
set -e  # Exit immediately if a command fails
trap 'echo "An error occurred. Exiting..." && exit 1' ERR

# === Variables ===
zipfile="$1"  # Zip file passed as argument
user="admin"  # Change this to your PostgreSQL user
user_pass="admin"  # Change this to your PostgreSQL password
restore_dir="/home/$user/restore"

# === Validate Input ===
if [ -z "$zipfile" ]; then
    echo "Usage: $0 <backup_file.zip>"
    exit 1
fi

# Get the filename without the path
zip_filename=$(basename "$zipfile" .zip)
database_name=$(echo "$zip_filename" | cut -d'_' -f1)
database_dump="$database_name.dump"

# Create a dedicated restore folder
restore_path="$restore_dir/$zip_filename"
mkdir -p "$restore_path"

# === Extract Backup ===
echo "Extracting backup to: $restore_path"
unzip -o "$zipfile" -d "$restore_path"

# === Restore PostgreSQL Database ===
if [ -f "$restore_path/$database_dump" ]; then
    echo "Restoring PostgreSQL database: $database_name"
    PGPASSWORD="$user_pass" pg_restore -U "$user" -h localhost -d "$database_name" -Fc --no-owner "$restore_path/$database_dump"
else
    echo "Error: Database dump file not found!"
    exit 1
fi

# === Restore Filestore ===
filestore_source="$restore_path/filestore/$database_name"
filestore_target="$HOME/.local/share/Odoo/filestore/$database_name"

if [ -d "$filestore_source" ]; then
    echo "Restoring filestore..."
    
    if [ -d "$filestore_target" ]; then
        echo "Backing up old filestore..."
        mv "$filestore_target" "${filestore_target}_old"
    else
        echo "No existing filestore found. Copying directly..."
    fi
    
    cp -r "$filestore_source" "$filestore_target"
    echo "Filestore restored successfully."
else
    echo "Warning: No filestore found in backup. Skipping filestore restore."
fi

echo "Restore completed successfully!"

