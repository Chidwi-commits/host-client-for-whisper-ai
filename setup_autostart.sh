#!/bin/bash

# Setup script for Whisper Server Autostart
# This script installs and configures the systemd service for automatic startup

echo "=== Setting up Whisper Server Autostart ==="

# Make the startup script executable
echo "Making startup script executable..."
chmod +x /home/chidwi/whisper_project/start_whisper_server.sh

# Copy the service file to systemd directory
echo "Installing systemd service..."
sudo cp /home/chidwi/whisper_project/whisper-server.service /etc/systemd/system/

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