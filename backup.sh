#!/usr/bin/env  bash

# MIT/X Consortium License
# © 2025 mahmoudElshimi <mahmoudelshimi@protonmail.ch>

# === Set Strict Error Handling ===
set -e  # Exit immediately if a command fails
trap 'echo "An error occurred. Exiting..." && exit 1' ERR

# === Variables ===
database_name="aws"  # Change to your actual database name
user="admin"         # Change to your PostgreSQL user
user_pass="admin"    # Change to your PostgreSQL password
backup_dir="/home/$user/backups"
filestore_source="$HOME/.local/share/Odoo/filestore/$database_name"
timestamp=$(date +"%d-%m-%y-%H-%M")
backupfile="$database_name.dump"
zipfile="$backup_dir/${database_name}_${timestamp}.zip"

# === Ensure Backup Directory Exists ===
mkdir -p "$backup_dir"

# === Backup Database ===
echo "Backing up PostgreSQL database: $database_name"
PGPASSWORD="$user_pass" pg_dump -U "$user" -h localhost -d "$database_name" -Fc --no-owner --no-privileges -f "$backup_dir/$backupfile"

# === Prepare Filestore for Zipping ===
filestore_target="filestore/$database_name"
mkdir -p "$backup_dir/filestore"
if [ -d "$filestore_source" ]; then
    cp -r "$filestore_source" "$backup_dir/$filestore_target"
    echo "Filestore copied to $backup_dir/$filestore_target"
else
    echo "Warning: Filestore directory does not exist ($filestore_source). Skipping filestore backup."
fi

# === Compress Everything (Without Full Paths) ===
echo "Creating ZIP archive: $zipfile"
cd "$backup_dir"
zip -r "$zipfile" "$backupfile" "filestore/$database_name"

# === Remove Temporary Files ===
rm -f "$backupfile"
rm -rf "filestore/$database_name"
echo "Removed temporary files."

# === Cleanup Old Backup Files (Optional: Keep Last 7 Days) ===
find "$backup_dir" -type f -name "*.zip" -mtime +7 -exec rm {} \;

echo "Backup completed successfully!"

