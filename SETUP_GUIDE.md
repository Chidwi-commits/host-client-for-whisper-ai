# 🛠️ Setup Guide

Complete installation and autostart configuration for Whisper Transcription Server.

## 📋 Prerequisites

- **Python 3.8+** with pip
- **Linux system** with systemd support
- **Internet connection** for downloading Whisper models
- **Sufficient RAM** (minimum 2GB, recommended 8GB+ for large models)

## 🚀 Quick Installation

### 1. Clone and Setup
```bash
cd /home/your-username/
git clone <repository-url> whisper_project
cd whisper_project
```

### 2. Create Virtual Environment
```bash
python3 -m venv venv
source venv/bin/activate
```

### 3. Install Dependencies
```bash
pip install flask whisper psutil
```

### 4. Test Server
```bash
python server.py
```
Server should start at `http://localhost:5000`

## ⚡ Automatic Startup Configuration

### Using Setup Script (Recommended)
Run the automated setup script:
```bash
chmod +x setup_autostart.sh
./setup_autostart.sh
```

This script will:
- Make startup script executable
- Install systemd service
- Enable automatic startup
- Start the service immediately

### Manual Configuration

#### 1. Create Startup Script
File: `start_whisper_server.sh`
```bash
#!/bin/bash
cd /home/your-username/whisper_project
source venv/bin/activate
export FLASK_APP=server.py
export FLASK_ENV=production
echo "Starting Whisper transcription server..."
python server.py
echo "Whisper server stopped at $(date)"
```

#### 2. Create Systemd Service
File: `whisper-server.service`
```ini
[Unit]
Description=Whisper Audio Transcription Server
After=network.target
Wants=network.target

[Service]
Type=simple
User=your-username
Group=your-username
WorkingDirectory=/home/your-username/whisper_project
ExecStart=/bin/bash /home/your-username/whisper_project/start_whisper_server.sh
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=whisper-server

Environment=PATH=/home/your-username/whisper_project/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
Environment=VIRTUAL_ENV=/home/your-username/whisper_project/venv

NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

#### 3. Install and Enable Service
```bash
# Make startup script executable
chmod +x start_whisper_server.sh

# Copy service file
sudo cp whisper-server.service /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable and start service
sudo systemctl enable whisper-server.service
sudo systemctl start whisper-server.service
```

## 🔧 Service Management

### Basic Commands
```bash
# Check service status
sudo systemctl status whisper-server

# Start service
sudo systemctl start whisper-server

# Stop service
sudo systemctl stop whisper-server

# Restart service
sudo systemctl restart whisper-server

# Disable autostart
sudo systemctl disable whisper-server

# View logs
sudo journalctl -u whisper-server -f
```

### Service Status Check
```bash
# Check if service is running
systemctl is-active whisper-server

# Check if service is enabled for autostart
systemctl is-enabled whisper-server
```

## 🌐 Network Configuration

### Local Access Only
Default configuration binds to all interfaces (`0.0.0.0:5000`)

### Firewall Configuration
```bash
# Allow port 5000 through firewall
sudo ufw allow 5000

# Or for specific IP range
sudo ufw allow from 192.168.0.0/24 to any port 5000
```

### Access URLs
- **Local**: `http://localhost:5000`
- **Network**: `http://YOUR_SERVER_IP:5000`
- **Example**: `http://192.168.0.210:5000`

## 🧪 Testing Installation

### 1. Service Status Test
```bash
sudo systemctl status whisper-server
# Should show: Active: active (running)
```

### 2. Web Interface Test
Open browser: `http://YOUR_SERVER_IP:5000`
- Should show Whisper web interface
- Status should display "Ready"
- All controls should be visible

### 3. API Test
```bash
# Health check
curl http://localhost:5000/health

# Status check
curl http://localhost:5000/status
```

### 4. Transcription Test
Upload a short audio file through web interface to verify full functionality.

## 🚨 Troubleshooting

### Service Won't Start
```bash
# Check service logs
sudo journalctl -u whisper-server --no-pager

# Check if port is in use
sudo netstat -tlnp | grep :5000

# Verify Python environment
/home/your-username/whisper_project/venv/bin/python --version
```

### Permission Issues
```bash
# Fix script permissions
chmod +x start_whisper_server.sh

# Verify user ownership
sudo chown -R your-username:your-username /home/your-username/whisper_project
```

### Network Access Issues
```bash
# Check if server is binding correctly
ss -tlnp | grep :5000

# Test local connectivity
curl -I http://localhost:5000

# Check firewall
sudo ufw status
```

### Memory Issues
```bash
# Check available memory
free -h

# Monitor memory usage during operation
top -p $(pgrep -f "python.*server.py")
```

## 📁 File Structure After Setup
```
whisper_project/
├── server.py                     # Main server script
├── start_whisper_server.sh       # Startup script
├── whisper-server.service        # Systemd service file
├── setup_autostart.sh           # Automated setup script
├── venv/                         # Python virtual environment
├── templates/                    # Web interface templates
├── static/                       # CSS and JavaScript files
└── *.md                         # Documentation files
```

## 🔄 Updates and Maintenance

### Updating the Server
```bash
# Stop service
sudo systemctl stop whisper-server

# Update code
git pull  # if using git

# Restart service
sudo systemctl start whisper-server
```

### Log Rotation
Logs are automatically managed by systemd/journald. To limit log size:
```bash
# Configure log retention
sudo journalctl --vacuum-time=30d
sudo journalctl --vacuum-size=100M
```

## ✅ Verification Checklist

- [ ] Python virtual environment created and activated
- [ ] Dependencies installed (flask, whisper, psutil)
- [ ] Server starts manually without errors
- [ ] Startup script is executable
- [ ] Systemd service file is installed
- [ ] Service is enabled and running
- [ ] Web interface accessible from browser
- [ ] API endpoints respond correctly
- [ ] Audio transcription works end-to-end
- [ ] Service automatically starts after system reboot

Your Whisper transcription server is now ready for production use with automatic startup! 