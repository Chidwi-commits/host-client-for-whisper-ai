# MIT License
# Copyright (c) 2025 Heorhii Norenko
#
# Description:
# This script sets up a Flask web server that transcribes audio files using the Whisper model.
# It includes an automatic mechanism to unload the model after a period of inactivity.
#
# Import necessary libraries and modules
from flask import Flask, request, send_file, jsonify
import whisper
import os
import uuid
import threading
import time

app = Flask(__name__)

# Global variables for the model and synchronization
model = None
model_lock = threading.Lock()  # Ensures thread safety when accessing the model
last_used = None
unload_timeout = 6 * 3600  # 6 hours

def unload_model_after_timeout():
    """
    Background thread function that unloads the model if it has been inactive for the defined timeout.
    It checks every 10 minutes if the model should be unloaded.
    """
    global model, last_used
    while True:
        time.sleep(600)  # Check every 10 minutes
        with model_lock:
            # If the model is loaded and inactive for longer than unload_timeout, unload it
            if model and (time.time() - last_used > unload_timeout):
                print("Unloading model due to inactivity.")
                model = None  # Unload the model to free resources

@app.route('/transcribe', methods=['POST'])
def transcribe_audio():
    """
    Endpoint to handle audio transcription.
    Expects an audio file in the POST request with key 'file'.
    Saves the file, transcribes it using the Whisper model, and returns the transcript as a text file.
    """
    global model, last_used

    # Check if the 'file' parameter is present in the request
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'Empty filename'}), 400

    # Generate a unique filename for the audio file
    file_id = str(uuid.uuid4())
    audio_path = f'{file_id}.wav'
    file.save(audio_path)

    try:
        with model_lock:
            # Load the model if it's not already loaded
            if model is None:
                print("Model not loaded. Loading model...")
                model = whisper.load_model("medium")
                print("Model loaded successfully.")
            last_used = time.time()  # Update the last used timestamp

        # Transcribe the audio file using the loaded model
        result = model.transcribe(audio_path)

        # Save the transcription result to a text file
        transcript_path = f'{file_id}.txt'
        with open(transcript_path, 'w', encoding='utf-8') as f:
            f.write(result["text"])

        # Return the transcript file as an attachment
        return send_file(transcript_path, as_attachment=True)

    finally:
        # Clean up temporary files after processing
        if os.path.exists(audio_path):
            os.remove(audio_path)
        if os.path.exists(transcript_path):
            os.remove(transcript_path)

if __name__ == '__main__':
    # Start the background thread for unloading the model after inactivity
    threading.Thread(target=unload_model_after_timeout, daemon=True).start()
    # Run the Flask app on all available IP addresses on port 5000
    app.run(host='0.0.0.0', port=5000)
