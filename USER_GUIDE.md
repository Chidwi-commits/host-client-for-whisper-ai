# 📖 User Guide

Complete guide to using the Whisper Transcription Server through web interface and API.

## 🌐 Web Interface

Access the web interface at: `http://YOUR_SERVER_IP:5000`

### Interface Overview

The web interface provides a modern, responsive dashboard for managing audio transcription with real-time monitoring and control capabilities.

#### Main Sections

1. **📊 Server Status Panel** - Real-time server monitoring
2. **🎛️ Control Panel** - Server management buttons  
3. **🎵 Transcription Panel** - File upload and processing
4. **📝 Activity Log** - Real-time operation logging

### Server Status Panel

Displays current server state and resource usage:

| Field | Description |
|-------|-------------|
| **Status** | Server state: Ready (green), Processing (yellow), Not Ready (red) |
| **Memory** | Current RAM usage in MB |
| **Model** | Currently loaded Whisper model name |
| **Processing Time** | Duration of current operation |

Status updates automatically every 2 seconds.

### Control Panel

#### Available Controls

| Button | Function | Description |
|--------|----------|-------------|
| 🔍 **Check Status** | Manual refresh | Force immediate status update |
| 🤖 **Change Model** | Model selection | Open model selection modal |
| 🔄 **Reset Server** | Server reset | Reset server state (with confirmation) |
| 🏥 **Health Check** | Health diagnosis | Comprehensive server health check |

#### Model Selection

Click "🤖 Change Model" to open the model selection modal featuring:

- **Visual Grid**: Interactive model cards with full specifications
- **Model Information**: Size, VRAM usage, speed, and description
- **Performance Comparison**: Speed multipliers and quality ratings

##### Available Models

**Performance Models:**
- **tiny** (39M, ~1GB, ~10x speed) - Fastest, minimal quality
- **base** (74M, ~1GB, ~7x speed) - Basic quality, very fast
- **small** (244M, ~2GB, ~4x speed) - Decent quality, fast
- **medium** (769M, ~5GB, ~2x speed) - Good quality, faster
- **large** (1550M, ~10GB, 1x speed) - Best quality, standard
- **large-v3** (1550M, ~10GB, 1x speed) - Latest best quality (default)
- **turbo** (809M, ~6GB, ~8x speed) - Balanced speed/quality

**English-Only Models:**
- **tiny.en, base.en, small.en, medium.en** - Optimized for English content

### Transcription Process

#### Step-by-Step Workflow

1. **Select Model** (optional)
   - Click "🤖 Change Model" if you want to change from default
   - Choose model based on your speed/quality needs
   - Confirm selection

2. **Upload Audio File**
   - Click "📄 Select Audio File for Transcription"
   - Choose from: WAV, MP3, M4A, FLAC, OGG
   - File information appears in activity log

3. **Start Transcription**
   - Click "🚀 Start Transcription"
   - Monitor real-time progress (0-100%)
   - Watch processing time and status updates

4. **Download Result**
   - Transcription automatically downloads when complete
   - File saved as `.txt` format
   - Success notification appears

#### Progress Monitoring

During transcription, you'll see:
- **Progress Bar**: Visual 0-100% completion indicator
- **Status Updates**: Real-time processing stage information
- **Time Tracking**: Live processing duration
- **Memory Usage**: Resource consumption monitoring

### Activity Log

Real-time log system with color-coded entries:

- 🔵 **Info** (blue): General information and status updates
- 🟢 **Success** (green): Completed operations
- 🟡 **Warning** (yellow): Non-critical issues
- 🔴 **Error** (red): Problems and error conditions

#### Log Management
- **Auto-scroll**: Automatically shows latest entries
- **Timestamped**: Each entry shows exact time
- **Clear Log**: Manual log clearing option
- **Entry Limit**: Maintains last 100 entries for performance

### Smart Notifications

Toast notification system provides non-intrusive feedback:
- **Success**: Green notifications for completed operations
- **Error**: Red notifications for failures
- **Warning**: Yellow notifications for advisories
- **Info**: Blue notifications for general information

Notifications appear from the right side and auto-dismiss after 3-5 seconds.

## 🔧 API Reference

### Base URL
```
http://YOUR_SERVER_IP:5000
```

### Endpoints

#### GET /status
Returns current server status and metrics.

**Response:**
```json
{
  "status": "Ready",
  "current_model": "large-v3",
  "model_loaded": false,
  "memory_usage_mb": 437.03,
  "progress": 0,
  "processing_time": null,
  "current_task_id": null,
  "time_since_last_use": null,
  "timestamp": 1753102635.011476
}
```

**Example:**
```bash
curl -s http://localhost:5000/status | jq
```

#### POST /transcribe
Transcribe audio file to text.

**Parameters:**
- `file` (required): Audio file
- `model` (optional): Whisper model name

**Supported Formats:** WAV, MP3, M4A, FLAC, OGG

**Example:**
```bash
curl -X POST \
  -F "file=@audio.wav" \
  -F "model=medium" \
  http://localhost:5000/transcribe \
  --output transcription.txt
```

**Python Example:**
```python
import requests

# Basic transcription
with open('audio.wav', 'rb') as f:
    files = {'file': f}
    response = requests.post('http://localhost:5000/transcribe', files=files)
    
if response.status_code == 200:
    with open('transcription.txt', 'w') as f:
        f.write(response.text)

# With specific model
with open('audio.wav', 'rb') as f:
    files = {'file': f}
    data = {'model': 'small'}
    response = requests.post('http://localhost:5000/transcribe', 
                           files=files, data=data)
```

#### POST /reset
Reset server state (unload model, cancel processing).

**Example:**
```bash
curl -X POST http://localhost:5000/reset
```

**Response:**
```json
{
  "success": true,
  "message": "Server reset completed successfully",
  "status": "Ready",
  "memory_usage_mb": 437.03,
  "timestamp": 1753102635.011476
}
```

#### GET /health
Simple health check endpoint.

**Example:**
```bash
curl -s http://localhost:5000/health
```

**Response:**
```json
{
  "status": "healthy",
  "server_status": "Ready",
  "timestamp": 1753102635.011476,
  "memory_usage_mb": 437.03
}
```

### API Error Handling

#### Common HTTP Status Codes

- **200**: Success
- **400**: Bad request (missing file, invalid format)
- **409**: Processing cancelled
- **429**: Server busy (processing another request)
- **500**: Internal server error

#### Error Response Format
```json
{
  "error": "Error description",
  "timestamp": 1753102635.011476
}
```

### Advanced API Usage

#### Progress Monitoring

Monitor transcription progress by polling the status endpoint:

```python
import requests
import time

def monitor_transcription():
    while True:
        response = requests.get('http://localhost:5000/status')
        data = response.json()
        
        if data['status'] == 'Processing':
            print(f"Progress: {data['progress']}%")
            time.sleep(1)
        elif data['status'] == 'Ready':
            print("Transcription complete!")
            break
        else:
            print(f"Status: {data['status']}")
            time.sleep(2)

# Start transcription then monitor
with open('audio.wav', 'rb') as f:
    files = {'file': f}
    response = requests.post('http://localhost:5000/transcribe', files=files)
    
if response.status_code == 200:
    print("Transcription started")
    monitor_transcription()
```

#### Batch Processing

Process multiple files sequentially:

```python
import requests
import os
import time

def transcribe_file(file_path, model='large-v3'):
    """Transcribe a single file"""
    with open(file_path, 'rb') as f:
        files = {'file': f}
        data = {'model': model}
        response = requests.post('http://localhost:5000/transcribe', 
                               files=files, data=data)
    
    if response.status_code == 200:
        output_path = file_path.replace('.wav', '.txt')
        with open(output_path, 'w') as f:
            f.write(response.text)
        return output_path
    else:
        print(f"Error transcribing {file_path}: {response.status_code}")
        return None

def process_directory(directory, model='medium'):
    """Process all audio files in a directory"""
    audio_files = [f for f in os.listdir(directory) 
                   if f.endswith(('.wav', '.mp3', '.m4a'))]
    
    for audio_file in audio_files:
        file_path = os.path.join(directory, audio_file)
        print(f"Processing: {audio_file}")
        
        # Wait for server to be ready
        while True:
            status = requests.get('http://localhost:5000/status').json()
            if status['status'] == 'Ready':
                break
            time.sleep(1)
        
        # Transcribe file
        result = transcribe_file(file_path, model)
        if result:
            print(f"Completed: {result}")
        
        time.sleep(1)  # Small delay between files

# Usage
process_directory('./audio_files', model='small')
```

## 📱 Mobile Usage

The web interface is fully responsive and optimized for mobile devices:

### Mobile-Specific Features
- **Touch-friendly**: Large buttons optimized for finger interaction
- **Responsive Layout**: Single-column layout on small screens
- **Adaptive Typography**: Readable text on all screen sizes
- **Gesture Support**: Drag & drop file upload where supported

### Mobile Workflow
1. Open browser on mobile device
2. Navigate to server URL
3. Use same interface as desktop
4. Upload files using camera or file picker
5. Monitor progress and download results

## 🎯 Usage Scenarios

### Quick Transcription (Speed Priority)
- **Model**: tiny or small
- **Use Case**: Meeting notes, quick voice memos
- **Benefit**: Fast results for basic transcription needs

### High-Quality Transcription (Accuracy Priority)
- **Model**: large-v3 (default)
- **Use Case**: Important interviews, lectures, legal recordings
- **Benefit**: Best possible accuracy for critical content

### English Content Processing
- **Model**: medium.en or small.en
- **Use Case**: English podcasts, meetings, presentations
- **Benefit**: Faster processing than multilingual models

### Balanced Processing (General Purpose)
- **Model**: medium or turbo
- **Use Case**: Regular transcription work
- **Benefit**: Good balance of speed and quality

## 🚨 Troubleshooting

### Web Interface Issues

#### Page Won't Load
- Check server is running: `sudo systemctl status whisper-server`
- Verify URL: `http://YOUR_SERVER_IP:5000`
- Check network connectivity
- Try refreshing browser cache (Ctrl+F5)

#### Upload Fails
- Check file format (WAV, MP3, M4A, FLAC, OGG supported)
- Verify file size (large files may take longer)
- Ensure server status is "Ready"
- Try different browser

#### No Progress Updates
- Refresh page and try again
- Check browser JavaScript is enabled
- Monitor server logs for errors

### API Issues

#### Connection Refused
```bash
# Check if server is running
curl -I http://localhost:5000/

# Check firewall
sudo ufw status

# Check port binding
ss -tlnp | grep :5000
```

#### Timeout Errors
- Large files may take several minutes to process
- Check server memory and CPU usage
- Consider using smaller model for faster processing

#### 429 (Server Busy) Errors
- Server processes one file at a time
- Wait for current transcription to complete
- Check status endpoint before retrying

Your Whisper transcription server provides both an intuitive web interface and powerful API for all your audio transcription needs! 