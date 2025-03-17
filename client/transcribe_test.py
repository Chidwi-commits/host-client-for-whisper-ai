# MIT License
# Copyright (c) 2025 Heorhii Norenko
#
# Description:
# This script sends an audio file to a Whisper transcription server and saves the transcription result.
# The server is expected to run at the provided IP address.

import requests

# Define the server URL where the Whisper transcription service is running.
server_url = 'http://192.168.0.210:5000/transcribe'  # Replace with your Whisper server's IP address

# Path to the audio file to be transcribed.
audio_file_path = 'test.wav'

# Open the audio file in binary mode and send it as a POST request to the transcription server.
with open(audio_file_path, 'rb') as f:
    files = {'file': f}
    response = requests.post(server_url, files=files)

# Check the response status and handle the transcription result.
if response.status_code == 200:
    # Save the received transcript file.
    output_filename = 'transcript_result.txt'
    with open(output_filename, 'wb') as f:
        f.write(response.content)
    print("Transcription successful! Transcript saved as", output_filename)
else:
    print("Error:", response.json())
