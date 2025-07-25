# Copyright © Heorhii Norenko, 2025
# License: This software is licensed for non-commercial use and modification only.
# For commercial use, explicit permission from the developer is required.
#
# Description:
# This script sets up a Flask web server that transcribes audio files using the Whisper model.
# It includes an automatic mechanism to unload the model after a period of inactivity.
# Added server status monitoring and reset functionality.
#
# Import necessary libraries and modules
from flask import Flask, request, send_file, jsonify, render_template
import whisper
import os
import uuid
import threading
import time
import gc
import psutil

app = Flask(__name__)

# Server status constants
STATUS_NOT_READY = "Not Ready"    # Used only during reset or critical errors
STATUS_READY = "Ready"            # Server ready to accept requests (default state)
STATUS_PROCESSING = "Processing"  # Currently processing transcription

# Global variables for the model and synchronization
model = None
current_model_name = "large-v3"  # Default model
model_lock = threading.Lock()  # Ensures thread safety when accessing the model
last_used = None
unload_timeout = 60  # 1 minute

# Status tracking variables
server_status = STATUS_NOT_READY
processing_progress = 0
current_task_id = None
processing_start_time = None
cancel_processing = threading.Event()

def get_memory_usage():
    """Get current memory usage in MB"""
    process = psutil.Process(os.getpid())
    return round(process.memory_info().rss / 1024 / 1024, 2)

def update_status(status, progress=0, task_id=None):
    """Update server status and progress"""
    global server_status, processing_progress, current_task_id
    server_status = status
    processing_progress = progress
    if task_id:
        current_task_id = task_id
    print(f"Status updated: {status} ({progress}%)")

def reset_server_state():
    """Reset all server state variables"""
    global model, current_model_name, last_used, server_status, processing_progress, current_task_id, processing_start_time
    
    with model_lock:
        if model:
            print("Unloading model for reset...")
            model = None
        
        # Cancel any ongoing processing
        cancel_processing.set()
        
        # Reset status variables - server becomes Ready after reset
        update_status(STATUS_READY, 0)
        current_model_name = "large-v3"  # Reset to default model
        last_used = None
        current_task_id = None
        processing_start_time = None
        
        # Force garbage collection
        gc.collect()
        
        print("Server state reset completed.")

@app.route('/')
def index():
    """
    Main web interface for Whisper transcription server.
    """
    return render_template('index.html')

def unload_model_after_timeout():
    """
    Background thread function that unloads the model if it has been inactive for the defined timeout.
    It checks every 1 minute if the model should be unloaded.
    Server remains Ready even when model is unloaded.
    """
    global model, last_used
    while True:
        time.sleep(60)  # Check every 1 minute
        with model_lock:
            # If the model is loaded and inactive for longer than unload_timeout, unload it
            if model and last_used and (time.time() - last_used > unload_timeout):
                print("Unloading model due to inactivity.")
                model = None  # Unload the model to free resources
                # Server remains Ready - can still accept requests and load model when needed
                gc.collect()

@app.route('/status', methods=['GET'])
def get_server_status():
    """
    Endpoint to check server status and processing progress.
    Returns current status, progress, memory usage, and other metrics.
    """
    global server_status, processing_progress, current_task_id, processing_start_time, last_used
    
    # Calculate processing time if processing
    processing_time = None
    if processing_start_time and server_status == STATUS_PROCESSING:
        processing_time = round(time.time() - processing_start_time, 2)
    
    # Calculate time since last use
    time_since_last_use = None
    if last_used:
        time_since_last_use = round(time.time() - last_used, 2)
    
    status_response = {
        'status': server_status,
        'progress': processing_progress,
        'current_task_id': current_task_id,
        'processing_time': processing_time,
        'memory_usage_mb': get_memory_usage(),
        'model_loaded': model is not None,
        'current_model': current_model_name,
        'time_since_last_use': time_since_last_use,
        'timestamp': time.time()
    }
    
    return jsonify(status_response)

@app.route('/reset', methods=['POST'])
def reset_server():
    """
    Endpoint to reset the server state.
    Unloads the model, cancels any ongoing processing, and resets all status variables.
    """
    try:
        reset_server_state()
        
        # Clear the cancel flag for future operations
        cancel_processing.clear()
        
        return jsonify({
            'success': True,
            'message': 'Server reset completed successfully',
            'status': server_status,
            'memory_usage_mb': get_memory_usage(),
            'timestamp': time.time()
        })
    
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Reset failed: {str(e)}',
            'timestamp': time.time()
        }), 500

@app.route('/transcribe', methods=['POST'])
def transcribe_audio():
    """
    Endpoint to handle audio transcription.
    Expects an audio file in the POST request with key 'file'.
    Optionally accepts 'model' parameter to specify which Whisper model to use.
    Saves the file, transcribes it using the Whisper model, and returns the transcript as a text file.
    """
    global model, current_model_name, last_used, processing_start_time
    
    # Check if server is already processing
    if server_status == STATUS_PROCESSING:
        return jsonify({'error': 'Server is currently processing another request'}), 429

    # Check if the 'file' parameter is present in the request
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'Empty filename'}), 400

    # Get model parameter from request (default to current model)
    requested_model = request.form.get('model', current_model_name)
    
    # Validate model name
    valid_models = ['tiny', 'tiny.en', 'base', 'base.en', 'small', 'small.en', 
                   'medium', 'medium.en', 'large', 'large-v3', 'turbo']
    if requested_model not in valid_models:
        return jsonify({'error': f'Invalid model: {requested_model}. Valid models: {valid_models}'}), 400

    # Generate a unique filename for the audio file
    file_id = str(uuid.uuid4())
    audio_path = f'{file_id}.wav'
    transcript_path = f'{file_id}.txt'
    
    # Clear cancel flag and start processing
    cancel_processing.clear()
    processing_start_time = time.time()
    update_status(STATUS_PROCESSING, 10, file_id)
    
    try:
        file.save(audio_path)
        update_status(STATUS_PROCESSING, 20, file_id)
        
        # Check for cancellation
        if cancel_processing.is_set():
            return jsonify({'error': 'Processing was cancelled'}), 409
        
        with model_lock:
            # Load or reload the model if needed
            if model is None or current_model_name != requested_model:
                print(f"Loading model: {requested_model}...")
                update_status(STATUS_PROCESSING, 30, file_id)
                model = whisper.load_model(requested_model)
                current_model_name = requested_model
                print(f"Model {requested_model} loaded successfully.")
                update_status(STATUS_PROCESSING, 50, file_id)
            else:
                print(f"Using already loaded model: {current_model_name}")
                update_status(STATUS_PROCESSING, 40, file_id)
            
            last_used = time.time()  # Update the last used timestamp

        # Check for cancellation again
        if cancel_processing.is_set():
            update_status(STATUS_READY, 0)
            return jsonify({'error': 'Processing was cancelled'}), 409

        # Transcribe the audio file using the loaded model
        print(f"Starting transcription for file: {file.filename}")
        update_status(STATUS_PROCESSING, 60, file_id)
        
        result = model.transcribe(audio_path)
        
        # Check for cancellation after transcription
        if cancel_processing.is_set():
            update_status(STATUS_READY, 0)
            return jsonify({'error': 'Processing was cancelled'}), 409
        
        update_status(STATUS_PROCESSING, 90, file_id)

        # Save the transcription result to a text file
        with open(transcript_path, 'w', encoding='utf-8') as f:
            f.write(result["text"])
        
        update_status(STATUS_PROCESSING, 100, file_id)
        print(f"Transcription completed for file: {file.filename}")
        
        # Update status to ready before sending response
        update_status(STATUS_READY, 0)
        
        # Return the transcript file as an attachment
        return send_file(transcript_path, as_attachment=True)

    except Exception as e:
        print(f"Error during transcription: {str(e)}")
        update_status(STATUS_READY, 0)
        return jsonify({'error': f'Transcription failed: {str(e)}'}), 500
    
    finally:
        # Clean up temporary files after processing
        if os.path.exists(audio_path):
            os.remove(audio_path)
        if os.path.exists(transcript_path):
            os.remove(transcript_path)
        
        # Ensure status is reset if not already done
        if server_status == STATUS_PROCESSING:
            update_status(STATUS_READY, 0)

@app.route('/health', methods=['GET'])
def health_check():
    """Simple health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'server_status': server_status,
        'timestamp': time.time(),
        'memory_usage_mb': get_memory_usage()
    })

if __name__ == '__main__':
    # Initialize server status as Ready (ready to accept requests)
    update_status(STATUS_READY, 0)
    
    # Start the background thread for unloading the model after inactivity
    threading.Thread(target=unload_model_after_timeout, daemon=True).start()
    
    print("Whisper Transcription Server starting...")
    print("Available endpoints:")
    print("  GET  /           - Web interface")
    print("  POST /transcribe - Transcribe audio file")
    print("  GET  /status     - Check server status")
    print("  POST /reset      - Reset server state")
    print("  GET  /health     - Health check")
    
    # Run the Flask app on all available IP addresses on port 5000
    app.run(host='0.0.0.0', port=5000)
