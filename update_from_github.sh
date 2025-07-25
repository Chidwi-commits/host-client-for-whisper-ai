#!/bin/bash

# Whisper Server Auto-Update Script
# Updates the server from GitHub repository
# Author: Chidwi-commits

set -e  # Exit on any error

# Configuration - UPDATE THESE VALUES FOR YOUR REPOSITORY  
REPO_URL="${WHISPER_REPO_URL:-https://github.com/YOUR_USERNAME/YOUR_REPO.git}"
PROJECT_DIR="/home/$(whoami)/whisper_project"
BACKUP_DIR="/home/$(whoami)/whisper_backup_$(date +%Y%m%d_%H%M%S)"
SERVICE_NAME="whisper-server"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Whisper Server Update Process Started${NC}"
echo "Repository: $REPO_URL"
echo "Project Directory: $PROJECT_DIR"
echo "Backup Directory: $BACKUP_DIR"
echo

# Function to log messages
log_message() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

# Check if running as correct user
if [[ $EUID -eq 0 ]]; then
   log_error "This script should not be run as root"
   exit 1
fi

# Check if we're in the correct directory
if [[ ! -f "$PROJECT_DIR/server.py" ]]; then
    log_error "Whisper server files not found in $PROJECT_DIR"
    exit 1
fi

# Step 1: Create backup
log_message "📦 Creating backup of current installation..."
mkdir -p "$BACKUP_DIR"
cp -r "$PROJECT_DIR"/* "$BACKUP_DIR/"
log_message "Backup created at: $BACKUP_DIR"

# Step 2: Check if service is running and stop it
log_message "🛑 Stopping Whisper service..."
if sudo systemctl is-active --quiet $SERVICE_NAME; then
    sudo systemctl stop $SERVICE_NAME
    log_message "Service stopped successfully"
else
    log_warning "Service was not running"
fi

# Step 3: Save current virtual environment
log_message "💾 Preserving virtual environment..."
if [[ -d "$PROJECT_DIR/venv" ]]; then
    mv "$PROJECT_DIR/venv" "$BACKUP_DIR/venv_backup"
    log_message "Virtual environment backed up"
fi

# Step 4: Clone or pull latest version
cd "$PROJECT_DIR"
if [[ -d ".git" ]]; then
    log_message "📥 Pulling latest changes from GitHub..."
    git fetch origin
    git reset --hard origin/main
    git clean -fd
else
    log_message "📥 Cloning repository from GitHub..."
    cd ..
    rm -rf whisper_project_temp
    git clone "$REPO_URL" whisper_project_temp
    cd whisper_project_temp
    
    # Move files to project directory
    find . -maxdepth 1 ! -name '.' ! -name '.git' -exec mv {} "$PROJECT_DIR/" \;
    cd "$PROJECT_DIR"
    rm -rf ../whisper_project_temp
fi

# Step 5: Restore virtual environment
log_message "🔄 Restoring virtual environment..."
if [[ -d "$BACKUP_DIR/venv_backup" ]]; then
    mv "$BACKUP_DIR/venv_backup" "$PROJECT_DIR/venv"
    log_message "Virtual environment restored"
else
    log_warning "No virtual environment found in backup"
fi

# Step 6: Update dependencies
log_message "📦 Updating Python dependencies..."
if [[ -d "$PROJECT_DIR/venv" ]]; then
    source "$PROJECT_DIR/venv/bin/activate"
    pip install --upgrade pip
    if [[ -f "$PROJECT_DIR/requirements.txt" ]]; then
        pip install -r "$PROJECT_DIR/requirements.txt"
    fi
    deactivate
    log_message "Dependencies updated"
else
    log_warning "Virtual environment not found, skipping dependency update"
fi

# Step 7: Set proper permissions
log_message "🔐 Setting file permissions..."
chmod +x "$PROJECT_DIR"/*.sh
chown -R $(whoami):$(whoami) "$PROJECT_DIR"
log_message "Permissions set"

# Step 8: Update systemd service if needed
if [[ -f "$PROJECT_DIR/whisper-server.service" ]]; then
    log_message "🔧 Updating systemd service..."
    sudo cp "$PROJECT_DIR/whisper-server.service" /etc/systemd/system/
    sudo systemctl daemon-reload
    log_message "Systemd service updated"
fi

# Step 9: Start service
log_message "🚀 Starting Whisper service..."
sudo systemctl start $SERVICE_NAME
sudo systemctl enable $SERVICE_NAME

# Wait a moment and check status
sleep 3
if sudo systemctl is-active --quiet $SERVICE_NAME; then
    log_message "✅ Service started successfully"
else
    log_error "❌ Service failed to start"
    log_message "📋 Service status:"
    sudo systemctl status $SERVICE_NAME --no-pager
    
    log_message "🔄 Attempting to restore from backup..."
    sudo systemctl stop $SERVICE_NAME
    rm -rf "$PROJECT_DIR"/*
    cp -r "$BACKUP_DIR"/* "$PROJECT_DIR/"
    sudo systemctl start $SERVICE_NAME
    log_error "Update failed, restored from backup"
    exit 1
fi

# Step 10: Cleanup old backups (keep last 5)
log_message "🧹 Cleaning up old backups..."
ls -dt /home/$(whoami)/whisper_backup_* 2>/dev/null | tail -n +6 | xargs rm -rf 2>/dev/null || true

echo
echo -e "${GREEN}✅ Update completed successfully!${NC}"
echo -e "${BLUE}📊 Service Status:${NC}"
sudo systemctl status $SERVICE_NAME --no-pager -l
echo
echo -e "${BLUE}🌐 Access your server at: http://localhost:5000${NC}"
echo -e "${BLUE}📁 Backup saved at: $BACKUP_DIR${NC}" 