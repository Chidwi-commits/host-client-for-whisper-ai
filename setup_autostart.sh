#!/bin/bash

# Whisper Server Auto-startup Setup Script
# This script installs the Whisper server as a systemd service for automatic startup

set -e  # Exit on any error

# Make the startup script executable
chmod +x /home/$(whoami)/whisper_project/start_whisper_server.sh

echo "Setting up Whisper server for automatic startup..."

# Generate systemd service file with current user
cat > /tmp/whisper-server.service << EOF
[Unit]
Description=Whisper Audio Transcription Server
After=network.target
Wants=network.target

[Service]
Type=simple
User=$(whoami)
Group=$(whoami)
WorkingDirectory=/home/$(whoami)/whisper_project
ExecStart=/bin/bash /home/$(whoami)/whisper_project/start_whisper_server.sh
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=whisper-server

# Environment variables
Environment=PATH=/home/$(whoami)/whisper_project/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
Environment=VIRTUAL_ENV=/home/$(whoami)/whisper_project/venv

# Security settings
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# Copy the service file to systemd
sudo cp /tmp/whisper-server.service /etc/systemd/system/

# Reload systemd to recognize the new service
echo "Reloading systemd..."
sudo systemctl daemon-reload

# Enable the service to start on boot
echo "Enabling service for autostart..."
sudo systemctl enable whisper-server.service

# Start the service now
echo "Starting Whisper server service..."
sudo systemctl start whisper-server.service

# Check service status
echo "Checking service status..."
sudo systemctl status whisper-server.service

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Useful commands:"
echo "  Check status:     sudo systemctl status whisper-server"
echo "  Stop service:     sudo systemctl stop whisper-server"
echo "  Start service:    sudo systemctl start whisper-server"
echo "  Restart service:  sudo systemctl restart whisper-server"
echo "  Disable autostart: sudo systemctl disable whisper-server"
echo "  View logs:        sudo journalctl -u whisper-server -f"
echo ""
echo "Your Whisper server will now start automatically on system boot!"
echo "Server will be available at http://localhost:5000 or http://your-ip:5000" 