# Odoo Backup & Restore Scripts

This repository contains two Bash scripts to **backup and restore** an Odoo database along with its filestore.

## Features
- Automates PostgreSQL database and filestore backup  
- Compresses backup with timestamped ZIP format  
- Restores database and filestore with error handling  
- Ensures safe rollback of previous filestore  
- Supports automatic scheduled backups  


### Note:
This module is actively developed and open to improvements. Contributions, feedback, and suggestions are highly welcome! Remember: **RTFM** (Read The F*cking Manual) and **KISS** (Keep It Simple, Stupid!). 

---

## 1 Backup Script (`odoo_backup.sh`)

### **Usage**
Run the script to create a backup of your Odoo database and filestore:
```bash
./odoo_backup.sh
```
### **What It Does**
- Creates a compressed ZIP backup of the database and filestore  
- Saves backups under `/home/user/backups/` with the format:  
  ```
  database_name_dd-mm-yy-hh-mm.zip
  ```
- Retains backups for **7 days**, deleting older ones automatically  

### ** Automating Backups with Cron**  
To schedule a daily backup at **2:00 AM**, add this cron job:  
```bash
crontab -e
```
Then add the following line:  
```bash
0 2 * * * /path/to/odoo_backup.sh >> /var/log/odoo_backup.log 2>&1
```
This runs the backup script **every night at 2:00 AM** and logs output to `/var/log/odoo_backup.log`.

---

## 2 Restore Script (`odoo_restore.sh`)

### **Usage**
Run the script with the backup ZIP file:
```bash
./odoo_restore.sh /path/to/backup.zip
```

### **What It Does**
- Extracts the backup into `/home/user/restore/backup_name/`  
- Restores the PostgreSQL database  
- Moves the previous filestore (if exists) and restores the new one  
- Skips filestore restoration if missing in backup  

---

## 3 Database Credentials Setup  

If the PostgreSQL user does not have a password, set it with:
```bash
sudo -u postgres psql
ALTER USER user WITH PASSWORD 'your_password';
\q
```

---

## 4 Preparing for Restore  

If a database with the same name exists, drop and recreate it before restoring:
```bash
sudo -u postgres dropdb database_name
sudo -u postgres createdb -O user database_name
```

---

## 5 Filestore Location  

For source-based Odoo installations, filestore is usually under:
```
~/.local/share/Odoo/filestore/database_name
```
For other installations (Docker, custom setups), **verify the actual filestore path** before restoring.

---

## License  
This project is released under the MIT/X License.

