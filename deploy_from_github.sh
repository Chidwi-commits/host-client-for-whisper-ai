#!/bin/bash

# Whisper Server Initial Deployment Script
# Deploys the server from GitHub repository for the first time
# Author: Chidwi-commits

set -e  # Exit on any error

# Configuration - UPDATE THESE VALUES FOR YOUR REPOSITORY
REPO_URL="${WHISPER_REPO_URL:-https://github.com/YOUR_USERNAME/YOUR_REPO.git}"
PROJECT_DIR="/home/$(whoami)/whisper_project"
SERVICE_NAME="whisper-server"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Whisper Server Initial Deployment Started${NC}"
echo "Repository: $REPO_URL"
echo "Target Directory: $PROJECT_DIR"
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

# Step 1: Install system dependencies
log_message "📦 Installing system dependencies..."
sudo apt update
sudo apt install -y python3 python3-pip python3-venv git ffmpeg

# Step 2: Clone repository
log_message "📥 Cloning repository from GitHub..."
if [[ -d "$PROJECT_DIR" ]]; then
    log_warning "Project directory already exists, backing it up..."
    sudo mv "$PROJECT_DIR" "${PROJECT_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
fi

git clone "$REPO_URL" "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Step 3: Create virtual environment
log_message "🐍 Creating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Step 4: Install Python dependencies
log_message "📦 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

deactivate

# Step 5: Set proper permissions
log_message "🔐 Setting file permissions..."
chmod +x "$PROJECT_DIR"/*.sh
chown -R $(whoami):$(whoami) "$PROJECT_DIR"

# Step 6: Install systemd service
log_message "🔧 Installing systemd service..."
sudo cp "$PROJECT_DIR/whisper-server.service" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME

# Step 7: Start service
log_message "🚀 Starting Whisper service..."
sudo systemctl start $SERVICE_NAME

# Wait a moment and check status
sleep 5
if sudo systemctl is-active --quiet $SERVICE_NAME; then
    log_message "✅ Service started successfully"
else
    log_error "❌ Service failed to start"
    log_message "📋 Service status:"
    sudo systemctl status $SERVICE_NAME --no-pager
    exit 1
fi

echo
echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "${BLUE}📊 Service Status:${NC}"
sudo systemctl status $SERVICE_NAME --no-pager -l
echo
echo -e "${BLUE}🌐 Access your server at: http://localhost:5000${NC}"
echo -e "${BLUE}🔄 Use ./update_from_github.sh for future updates${NC}"
echo
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "1. Configure firewall if needed: sudo ufw allow 5000"
echo "2. Test the server: curl http://localhost:5000/health"
echo "3. Check logs: sudo journalctl -u whisper-server -f" 