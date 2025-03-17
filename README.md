# Host-Client for Whisper AI

A simple and efficient setup for audio transcription using OpenAI's [Whisper model](https://github.com/openai/whisper).

Developed by **Heorhii Norenko**, 2025.

---

## Project Structure

```
host-client-for-whisper-ai/
├── host/
│   └── server.py
├── client/
│   └── transcribe_test.py
├── .gitattributes
├── .gitignore
├── LICENSE
└── README.md
```

---

## Prerequisites

- Python 3.8 or higher
- pip (Python package manager)

**Note:** Whisper and its dependencies must be installed separately. Refer to the [Whisper GitHub repository](https://github.com/openai/whisper) for detailed installation instructions.

---

## Installation

### Server Setup

1. **Clone the repository on the server machine:**

```bash
git clone https://github.com/Chidwi-commits/host-client-for-whisper-ai.git
cd host-client-for-whisper-ai/host
```

2. **Create and activate a virtual environment:**

```bash
python -m venv env

# Windows
.\env\Scripts\activate

# Linux or MacOS
source env/bin/activate
```

3. **Install server dependencies:**

```bash
pip install flask
```

### Client Setup

1. **Clone the repository on the client machine:**

```bash
git clone https://github.com/Chidwi-commits/host-client-for-whisper-ai.git
cd host-client-for-whisper-ai/client
```

2. **Create and activate a virtual environment:**

```bash
python -m venv env

# Windows
.\env\Scripts\activate

# Linux or MacOS
source env/bin/activate
```

3. **Install client dependencies:**

```bash
pip install requests
```

---

## Configuration

### Host (`server.py`)

- **Whisper Model Selection:**

The default Whisper model is `medium`. Modify the model as needed:

```python
model = whisper.load_model("medium")
```

Available models: `tiny`, `base`, `small`, `medium`, `large`

- **Server Port:**

The server listens by default on port `5000`. To use a different port, modify:

```python
app.run(host='0.0.0.0', port=5000)
```

### Client (`transcribe_test.py`)

- **Server URL:**

Update the `server_url` variable to match the IP address and port of your Whisper server:

```python
server_url = 'http://192.168.0.210:5000/transcribe'
```

- **Audio File:**

Specify the path to your audio file:

```python
audio_file_path = 'test.wav'
```

It's recommended to use `.wav` format for best compatibility.

---

## Running the Application

### Starting the Server

Navigate to the `host` directory and launch the server:

```bash
cd host
python server.py
```

The Whisper model loads automatically upon the first transcription request.

### Running the Client

In another terminal window, navigate to the `client` directory and execute:

```bash
cd client
python transcribe_test.py
```

This script uploads the specified audio file to the server and saves the transcription as `transcript_result.txt`.

---

## Output

Upon successful transcription, the output (`transcript_result.txt`) will contain the transcribed text.

---

## License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) for details.

