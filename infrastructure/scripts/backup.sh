#!/bin/bash
# Backup script for OutfitStyle production database
set -e
BACKUP_DIR="/backups"
RETENTION_DAYS=7
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/outfitstyle_backup_$TIMESTAMP.sql.gz"
echo "🔄 Starting database backup..."
# Create backup directory if not exists
mkdir -p $BACKUP_DIR
# Get database credentials from environment
DB_HOST="${DB_HOST:-postgres}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-outfitstyle}"
DB_NAME="${DB_NAME:-outfitstyle}"
DB_PASSWORD="${DB_PASSWORD}"
# Create backup using pg_dump
PGPASSWORD=$DB_PASSWORD pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -F c -b -v -f $BACKUP_FILE
if [ $? -ne 0 ]; then
    echo "❌ Backup failed"
    exit 1
fi
echo "✅ Backup created successfully: $BACKUP_FILE"
# Set proper permissions
chmod 600 $BACKUP_FILE
# Clean up old backups
echo "🧹 Cleaning up backups older than $RETENTION_DAYS days..."
find $BACKUP_DIR -name "outfitstyle_backup_*.sql.gz" -type f -mtime +$RETENTION_DAYS -delete
echo "✅ Cleanup completed"
# Optional: Upload to cloud storage
if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ] && [ -n "$S3_BUCKET_NAME" ]; then
    echo "☁️ Uploading backup to S3..."
    AWS_REGION="${AWS_REGION:-us-east-1}"
    s3_path="s3://$S3_BUCKET_NAME/backups/$(basename $BACKUP_FILE)"
    aws s3 cp $BACKUP_FILE $s3_path --region $AWS_REGION
    if [ $? -eq 0 ]; then
        echo "✅ Backup uploaded to S3: $s3_path"
    else
        echo "⚠️ Failed to upload backup to S3, but local backup is safe"
    fi
fi
echo "🎉 Backup process completed successfully!"