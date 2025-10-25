#!/bin/bash
set -e

# --- Configuration ---
# Your project directory (where your compose file is)
PROJECT_DIR="/home/patpr/n8n-docker-caddy-psql"

# Directory to store backups
BACKUP_DIR="/home/patpr/backups"

# Volume names
VOL_POSTGRES="postgres_data"
VOL_N8N="n8n_data"
VOL_CADDY="caddy_data"

# --- Main Script ---
echo "Starting stack backup..."
mkdir -p $BACKUP_DIR
cd $PROJECT_DIR

# 1. Stop the containers
echo "Stopping containers..."
docker compose down

# 2. Create the backup
TIMESTAMP=$(date +"%F")
BACKUP_FILE="$BACKUP_DIR/n8n_stack_backup_$TIMESTAMP.tar.gz"
echo "Backing up data to $BACKUP_FILE..."

docker run --rm \
  -v $VOL_POSTGRES:/volumes/postgres \
  -v $VOL_N8N:/volumes/n8n \
  -v $VOL_CADDY:/volumes/caddy \
  -v $PROJECT_DIR/local_files:/volumes/local_files \
  -v $BACKUP_DIR:/backup \
  alpine tar -czf /backup/n8n_stack_backup_$TIMESTAMP.tar.gz -C /volumes .

echo "Backup complete."

# 3. Restart the containers
echo "Restarting containers..."
docker compose up -d

# 4. Clean up old backups
echo "Cleaning up old backups..."
find $BACKUP_DIR -mtime +7 -exec rm {} \;

echo "Stack backup finished."