#!/bin/bash

# 🎤 Whisper Server Simple Installation Script
# Run this after downloading the repository to set up everything automatically

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

clear
echo -e "${BLUE}"
echo "=================================================="
echo "🎤 WHISPER TRANSCRIPTION SERVER INSTALLATION"
echo "=================================================="
echo -e "${NC}"
echo "This script will set up everything you need to run"
echo "the Whisper AI transcription server with web interface."
echo
echo -e "${YELLOW}What this script does:${NC}"
echo "1. ✅ Install system dependencies (Python, ffmpeg, etc.)"
echo "2. ✅ Create Python virtual environment"
echo "3. ✅ Install Python packages (Whisper, Flask, etc.)"
echo "4. ✅ Set up systemd service for auto-start"
echo "5. ✅ Start the web server"
echo
read -p "Press Enter to continue or Ctrl+C to cancel..."

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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   log_error "Please don't run this script as root (no sudo needed)"
   echo "Run as regular user: ./install.sh"
   exit 1
fi

# Get current directory and user
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
USER_NAME="$(whoami)"

log_message "🏠 Project directory: $PROJECT_DIR"
log_message "👤 Installing for user: $USER_NAME"

# Step 1: Install system dependencies
log_message "📦 Installing system dependencies..."
sudo apt update
sudo apt install -y python3 python3-pip python3-venv git ffmpeg curl

# Step 2: Create Python virtual environment
log_message "🐍 Creating Python virtual environment..."
if [[ -d "$PROJECT_DIR/venv" ]]; then
    log_warning "Virtual environment exists, recreating..."
    rm -rf "$PROJECT_DIR/venv"
fi

python3 -m venv "$PROJECT_DIR/venv"
source "$PROJECT_DIR/venv/bin/activate"

# Step 3: Install Python dependencies
log_message "📦 Installing Whisper and dependencies..."
pip install --upgrade pip

# Install from requirements.txt if exists, otherwise install individually
if [[ -f "$PROJECT_DIR/requirements.txt" ]]; then
    pip install -r "$PROJECT_DIR/requirements.txt"
else
    log_message "Installing core dependencies..."
    pip install flask flask-cors openai-whisper torch torchaudio transformers requests psutil werkzeug jinja2
fi

deactivate

# Step 4: Set file permissions
log_message "🔐 Setting file permissions..."
chmod +x "$PROJECT_DIR"/*.sh
chown -R "$USER_NAME:$USER_NAME" "$PROJECT_DIR"

# Step 5: Set up systemd service
log_message "🔧 Setting up system service..."

# Generate systemd service file
cat > /tmp/whisper-server.service << EOF
[Unit]
Description=Whisper Audio Transcription Server
After=network.target
Wants=network.target

[Service]
Type=simple
User=$USER_NAME
Group=$USER_NAME
WorkingDirectory=$PROJECT_DIR
ExecStart=/bin/bash $PROJECT_DIR/start_whisper_server.sh
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=whisper-server

# Environment variables
Environment=PATH=$PROJECT_DIR/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
Environment=VIRTUAL_ENV=$PROJECT_DIR/venv

# Security settings
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# Install and enable service
sudo cp /tmp/whisper-server.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable whisper-server

# Step 6: Start the service
log_message "🚀 Starting Whisper server..."
sudo systemctl start whisper-server

# Wait a moment for startup
sleep 5

# Step 7: Check if everything is working
log_message "🔍 Checking server status..."
if sudo systemctl is-active --quiet whisper-server; then
    if curl -s http://localhost:5000/health > /dev/null 2>&1; then
        log_message "✅ SUCCESS! Server is running and responding"
    else
        log_warning "⚠️  Service started but not responding yet (may take a moment to load)"
    fi
else
    log_error "❌ Service failed to start"
    echo
    echo "Troubleshooting information:"
    sudo systemctl status whisper-server --no-pager
    exit 1
fi

# Step 8: Configure firewall (optional)
log_message "🔥 Configuring firewall..."
if command -v ufw >/dev/null 2>&1; then
    sudo ufw allow 5000/tcp 2>/dev/null || true
    log_message "Firewall rule added for port 5000"
fi

# Final success message
echo
echo -e "${GREEN}🎉 INSTALLATION COMPLETE! 🎉${NC}"
echo
echo -e "${BLUE}📍 Your Whisper server is now running at:${NC}"
echo "   🌐 Local access:    http://localhost:5000"
echo "   🌍 Network access:  http://$(hostname -I | cut -d' ' -f1):5000"
echo
echo -e "${BLUE}🎯 What you can do now:${NC}"
echo "   1. Open the web interface in your browser"
echo "   2. Upload audio files for transcription"
echo "   3. Choose different Whisper models"
echo "   4. Monitor real-time progress"
echo
echo -e "${BLUE}🔧 Useful commands:${NC}"
echo "   • Check status:      sudo systemctl status whisper-server"
echo "   • View logs:         sudo journalctl -u whisper-server -f"
echo "   • Restart service:   sudo systemctl restart whisper-server"
echo "   • Stop service:      sudo systemctl stop whisper-server"
echo "   • Check for updates: ./check_updates.sh"
echo
echo -e "${YELLOW}📖 For help:${NC}"
echo "   • README.md - Quick start guide"
echo "   • USER_GUIDE.md - Complete user manual"
echo "   • SETUP_GUIDE.md - Advanced configuration"
echo
echo -e "${GREEN}Happy transcribing! 🎵➡️📝${NC}" 