# 🎤 Whisper Transcription Server

Modern web-based audio transcription server using OpenAI's Whisper models with automatic startup, real-time monitoring, and **automated GitHub deployment system**.

[![GitHub](https://img.shields.io/badge/GitHub-Chidwi--commits-blue?logo=github)](https://github.com/Chidwi-commits/host-client-for-whisper-ai)
[![Python](https://img.shields.io/badge/Python-3.8+-green?logo=python)](https://python.org)
[![Whisper](https://img.shields.io/badge/OpenAI-Whisper-orange?logo=openai)](https://github.com/openai/whisper)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## 🚀 Simple Installation

**Download and run - that's it!**

### Method 1: Download Repository (Recommended)
```bash
# Option A: Download with git
git clone https://github.com/Chidwi-commits/host-client-for-whisper-ai.git
cd host-client-for-whisper-ai

# Option B: Download ZIP file and extract it
# Then cd into the extracted folder

# Run the installer
./install.sh
```

### Method 2: One-command from Internet
```bash
# Deploy directly from GitHub (no local download needed)
curl -sSL https://raw.githubusercontent.com/Chidwi-commits/host-client-for-whisper-ai/main/deploy_from_github.sh | bash
```

**After installation:**
- 🌐 **Web interface:** `http://localhost:5000`
- 🔄 **Check updates:** `./check_updates.sh`
- ⬆️ **Apply updates:** `./update_from_github.sh`

> **🎯 Zero configuration needed!** Just download and run the installer.  
> **📖 Need help?** See [USAGE_SCENARIOS.md](USAGE_SCENARIOS.md) for different usage options.

## ✨ Features

- **🌐 Web Interface**: Modern, responsive web dashboard accessible from any device
- **🤖 Multiple Models**: 11 Whisper models from tiny (fast) to large-v3 (best quality)
- **📊 Real-time Monitoring**: Live status updates, progress tracking, and resource monitoring
- **🎛️ Server Management**: Reset functionality, health checks, and model switching
- **⚡ Auto-startup**: Systemd service for automatic server startup on boot
- **🔧 RESTful API**: Complete HTTP API for programmatic access
- **💾 Memory Optimization**: Intelligent model loading and automatic cleanup
- **📱 Mobile Support**: Fully responsive design for mobile and tablet devices
- **📝 Activity Logging**: Real-time operation logs with color-coded entries
- **🔔 Smart Notifications**: Toast notifications for user feedback

## 📁 Project Structure

```
whisper_project/
├── server.py                     # Main Flask server with web interface
├── templates/                    # Web interface templates
│   └── index.html               # Main web dashboard
├── static/                      # Web assets (CSS, JavaScript)
│   ├── css/style.css           # Responsive styling
│   └── js/app.js               # Real-time functionality
├── start_whisper_server.sh     # Server startup script
├── whisper-server.service      # Systemd service configuration
├── setup_autostart.sh         # Automated installation script
├── test_server_features.sh    # Testing utilities
├── install.sh                  # 🆕 Simple local installer (recommended)
├── deploy_from_github.sh       # 🆕 Remote deployment from GitHub
├── update_from_github.sh       # 🆕 Auto-update script
├── check_updates.sh            # 🆕 Update checker script
├── requirements.txt            # 🆕 Python dependencies
├── .gitignore                  # 🆕 Git ignore rules
├── README.md                  # Project overview and quick start  
├── SETUP_GUIDE.md             # Installation and configuration guide
├── USER_GUIDE.md              # Web interface and API documentation
├── CONFIGURATION.md           # 🆕 Developer configuration guide
├── USAGE_SCENARIOS.md         # 🆕 Different usage scenarios explained
└── venv/                      # Python virtual environment
```

## 🚀 Quick Start

### 1. Download and Install
```bash
# Download the repository
git clone https://github.com/Chidwi-commits/host-client-for-whisper-ai.git
cd host-client-for-whisper-ai

# Run installer (does everything automatically)
./install.sh
```

### 2. Use Web Interface
Open your browser: `http://localhost:5000`

### 3. Start Transcribing
1. Select audio file (WAV, MP3, M4A, FLAC, OGG)
2. Choose Whisper model (optional)
3. Click "Start Transcription"
4. Download result when complete

**That's it!** The installer handles all dependencies, services, and configuration.

## 🌐 Web Dashboard

Modern, responsive web interface accessible from any device at `http://YOUR_SERVER_IP:5000`

### Interface Components
- **📊 Status Panel**: Real-time server monitoring with memory usage and model info
- **🎛️ Control Panel**: Model selection, server reset, and health checks  
- **🎵 Transcription Panel**: File upload with drag & drop and progress tracking
- **📝 Activity Log**: Color-coded operation logs with timestamps

### Model Selection
Choose from 11 Whisper models through an intuitive modal interface:
- **tiny** to **large-v3**: From fastest (tiny) to best quality (large-v3)
- **English-only models**: Optimized for English content processing
- **Visual selection**: Cards with specifications, speed ratings, and descriptions

## 📚 Documentation

- **📖 [Setup Guide](./SETUP_GUIDE.md)** - Installation, configuration, and auto-startup setup
- **🌐 [User Guide](./USER_GUIDE.md)** - Web interface usage and complete API reference

## 🔧 API Endpoints

### Core Endpoints
- **`POST /transcribe`** - Transcribe audio file with optional model selection
- **`GET /status`** - Real-time server status and progress monitoring
- **`POST /reset`** - Reset server state and cancel processing
- **`GET /health`** - Health check and diagnostics

### Quick Examples
```bash
# Basic transcription
curl -X POST -F "file=@audio.wav" http://localhost:5000/transcribe --output result.txt

# With specific model
curl -X POST -F "file=@audio.wav" -F "model=medium" http://localhost:5000/transcribe --output result.txt

# Check server status
curl http://localhost:5000/status
```

## 🛠️ Service Management

```bash
# Check status
sudo systemctl status whisper-server

# Start/Stop service
sudo systemctl start whisper-server
sudo systemctl stop whisper-server

# View logs
sudo journalctl -u whisper-server -f
```

## 🎵 Supported Formats

**Audio**: WAV, MP3, M4A, FLAC, OGG  
**Output**: Plain text (.txt)

## 🎯 Usage Methods

### Web Interface (Recommended)
Access dashboard: `http://YOUR_SERVER_IP:5000`

### Command Line
```bash
curl -X POST -F "file=@audio.wav" http://localhost:5000/transcribe --output result.txt
```

### Python Integration
```python
import requests
with open('audio.wav', 'rb') as f:
    response = requests.post('http://localhost:5000/transcribe', files={'file': f})
    print(response.text)
```

### 4. Monitoring & Management / Моніторинг та управління
```bash
# Check status / Перевірити статус
curl http://localhost:5000/status

# Reset server / Скинути сервер
curl -X POST http://localhost:5000/reset

# Health check / Перевірка здоров'я
curl http://localhost:5000/health
```

## 📄 License / Ліцензія

This software is licensed for non-commercial use and modification only. For commercial use, explicit permission from the developer is required.

Це програмне забезпечення ліцензовано лише для некомерційного використання та модифікації. Для комерційного використання потрібен явний дозвіл розробника.

---

**Author / Автор**: Heorhii Norenko  
**Year / Рік**: 2025 