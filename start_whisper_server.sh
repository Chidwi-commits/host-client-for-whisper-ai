#!/bin/bash

# Whisper Server Startup Script
# Activates virtual environment and starts the Flask server

# Change to the project directory
cd /home/$(whoami)/whisper_project

# Activate the virtual environment
source venv/bin/activate

# Export any necessary environment variables
export FLASK_APP=server.py
export FLASK_ENV=production

# Start the server
echo "Starting Whisper transcription server..."
python server.py

# Log when the script exits
echo "Whisper server stopped at $(date)" 