// Whisper Server Web Interface JavaScript
class WhisperWebClient {
    constructor() {
        this.statusUpdateInterval = null;
        this.isMonitoring = false;
        this.currentFile = null;
        
        this.initializeElements();
        this.bindEvents();
        this.startStatusMonitoring();
        this.addLogEntry('Web interface initialized', 'info');
    }
    
    initializeElements() {
        // Status elements
        this.serverStatus = document.getElementById('server-status');
        this.memoryUsage = document.getElementById('memory-usage');
        this.currentModel = document.getElementById('current-model');
        this.processingTime = document.getElementById('processing-time');
        
        // Control buttons
        this.checkStatusBtn = document.getElementById('check-status-btn');
        this.changeModelBtn = document.getElementById('change-model-btn');
        this.resetServerBtn = document.getElementById('reset-server-btn');
        this.healthCheckBtn = document.getElementById('health-check-btn');
        
        // File upload elements
        this.audioFileInput = document.getElementById('audio-file');
        this.transcribeBtn = document.getElementById('transcribe-btn');
        this.progressFill = document.getElementById('progress-fill');
        this.progressText = document.getElementById('progress-text');
        
        // Log elements
        this.activityLog = document.getElementById('activity-log');
        this.clearLogBtn = document.getElementById('clear-log-btn');
        
        // Modal elements
        this.resetModal = document.getElementById('reset-modal');
        this.confirmResetBtn = document.getElementById('confirm-reset');
        this.cancelResetBtn = document.getElementById('cancel-reset');
        this.modelModal = document.getElementById('model-modal');
        this.confirmModelBtn = document.getElementById('confirm-model');
        this.cancelModelBtn = document.getElementById('cancel-model');
        
        // Notification element
        this.notification = document.getElementById('notification');
    }
    
    bindEvents() {
        // Control buttons
        this.checkStatusBtn.addEventListener('click', () => this.checkStatus());
        this.changeModelBtn.addEventListener('click', () => this.showModelModal());
        this.resetServerBtn.addEventListener('click', () => this.showResetModal());
        this.healthCheckBtn.addEventListener('click', () => this.performHealthCheck());
        
        // File upload
        this.audioFileInput.addEventListener('change', (e) => this.handleFileSelect(e));
        this.transcribeBtn.addEventListener('click', () => this.startTranscription());
        
        // Log management
        this.clearLogBtn.addEventListener('click', () => this.clearLog());
        
        // Modal events
        this.confirmResetBtn.addEventListener('click', () => this.resetServer());
        this.cancelResetBtn.addEventListener('click', () => this.hideResetModal());
        this.confirmModelBtn.addEventListener('click', () => this.changeModel());
        this.cancelModelBtn.addEventListener('click', () => this.hideModelModal());
        
        // Close modal when clicking outside
        this.resetModal.addEventListener('click', (e) => {
            if (e.target === this.resetModal) {
                this.hideResetModal();
            }
        });
        
        this.modelModal.addEventListener('click', (e) => {
            if (e.target === this.modelModal) {
                this.hideModelModal();
            }
        });
        
        // Model card selection
        document.querySelectorAll('.model-card').forEach(card => {
            card.addEventListener('click', () => this.selectModelCard(card));
        });
        
        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                this.hideResetModal();
                this.hideModelModal();
            }
        });
    }
    
    async checkStatus() {
        this.addLogEntry('Checking server status...', 'info');
        
        try {
            const response = await fetch('/status');
            if (response.ok) {
                const data = await response.json();
                this.updateStatusDisplay(data);
                this.addLogEntry(`Status: ${data.status}`, 'success');
            } else {
                this.addLogEntry(`Status check failed: HTTP ${response.status}`, 'error');
            }
        } catch (error) {
            this.addLogEntry(`Connection error: ${error.message}`, 'error');
        }
    }
    
    updateStatusDisplay(data) {
        // Update server status with color coding
        this.serverStatus.textContent = data.status || 'Unknown';
        this.serverStatus.className = 'status-value';
        
        if (data.status === 'Ready') {
            this.serverStatus.classList.add('ready');
        } else if (data.status === 'Processing') {
            this.serverStatus.classList.add('processing');
        } else {
            this.serverStatus.classList.add('not-ready');
        }
        
        // Update other status information
        this.memoryUsage.textContent = `${(data.memory_usage_mb || 0).toFixed(1)} MB`;
        this.processingTime.textContent = data.processing_time 
            ? `${data.processing_time.toFixed(1)} sec` 
            : '-';
        
        // Update current model display
        if (data.current_model) {
            this.currentModel.textContent = data.current_model;
        }
        
        // Update progress if processing
        if (data.status === 'Processing' && data.progress !== undefined) {
            this.updateProgress(data.progress);
            this.progressText.textContent = `Processing: ${data.progress}%`;
        } else if (data.status === 'Ready') {
            this.updateProgress(0);
            this.progressText.textContent = 'Ready to process';
        } else if (data.status === 'Not Ready') {
            this.updateProgress(0);
            this.progressText.textContent = 'Server not ready';
        }
    }
    
    updateProgress(percentage) {
        this.progressFill.style.width = `${percentage}%`;
    }
    
    async performHealthCheck() {
        this.addLogEntry('Performing health check...', 'info');
        
        try {
            const response = await fetch('/health');
            if (response.ok) {
                const data = await response.json();
                this.addLogEntry(`Health: ${data.status}`, 'success');
                this.showNotification(
                    `Server is healthy\nStatus: ${data.server_status}\nMemory: ${data.memory_usage_mb.toFixed(1)} MB`,
                    'success'
                );
            } else {
                this.addLogEntry(`Health check failed: HTTP ${response.status}`, 'error');
                this.showNotification('Health check failed', 'error');
            }
        } catch (error) {
            this.addLogEntry(`Health check error: ${error.message}`, 'error');
            this.showNotification('Health check error', 'error');
        }
    }
    
    showResetModal() {
        this.resetModal.style.display = 'block';
    }
    
    hideResetModal() {
        this.resetModal.style.display = 'none';
    }
    
    async resetServer() {
        this.hideResetModal();
        this.addLogEntry('Resetting server state...', 'warning');
        
        try {
            const response = await fetch('/reset', { method: 'POST' });
            
            if (response.ok) {
                const data = await response.json();
                if (data.success) {
                    this.addLogEntry('Server successfully reset', 'success');
                    this.showNotification('Server reset successfully', 'success');
                } else {
                    this.addLogEntry(`Reset error: ${data.error}`, 'error');
                    this.showNotification(`Reset error: ${data.error}`, 'error');
                }
            } else {
                this.addLogEntry(`Reset error: HTTP ${response.status}`, 'error');
                this.showNotification('Reset failed', 'error');
            }
        } catch (error) {
            this.addLogEntry(`Connection error during reset: ${error.message}`, 'error');
            this.showNotification('Connection error during reset', 'error');
        }
    }
    
    handleFileSelect(event) {
        const file = event.target.files[0];
        if (file) {
            this.currentFile = file;
            this.transcribeBtn.disabled = false;
            this.addLogEntry(`File selected: ${file.name} (${(file.size / 1024 / 1024).toFixed(2)} MB)`, 'info');
        } else {
            this.currentFile = null;
            this.transcribeBtn.disabled = true;
        }
    }
    
    showModelModal() {
        // Update selected model in modal
        const currentModel = this.currentModel.textContent;
        document.querySelectorAll('.model-card').forEach(card => {
            card.classList.remove('selected');
            if (card.dataset.model === currentModel) {
                card.classList.add('selected');
            }
        });
        
        this.modelModal.style.display = 'block';
    }
    
    hideModelModal() {
        this.modelModal.style.display = 'none';
    }
    
    selectModelCard(card) {
        // Remove selected class from all cards
        document.querySelectorAll('.model-card').forEach(c => c.classList.remove('selected'));
        // Add selected class to clicked card
        card.classList.add('selected');
    }
    
    changeModel() {
        const selectedCard = document.querySelector('.model-card.selected');
        if (!selectedCard) {
            this.showNotification('Please select a model', 'warning');
            return;
        }
        
        const selectedModel = selectedCard.dataset.model;
        const modelName = selectedCard.querySelector('.model-name').textContent;
        const modelSpecs = selectedCard.querySelector('.model-specs').textContent;
        
        this.hideModelModal();
        this.addLogEntry(`Model changed to: ${selectedModel}`, 'info');
        this.showNotification(`Model selected: ${modelName} (${modelSpecs})`, 'success', 4000);
        
        // Update current model display immediately
        this.currentModel.textContent = selectedModel;
    }
    
    async startTranscription() {
        if (!this.currentFile) {
            this.showNotification('Please select an audio file first', 'warning');
            return;
        }
        
        // Check if server is ready
        try {
            const statusResponse = await fetch('/status');
            if (statusResponse.ok) {
                const statusData = await statusResponse.json();
                if (statusData.status === 'Processing') {
                    this.showNotification('Server is currently processing another file. Please try again later.', 'warning');
                    return;
                }
            }
        } catch (error) {
            this.addLogEntry('Failed to check server status', 'error');
            return;
        }
        
        const selectedModel = this.currentModel.textContent;
        this.addLogEntry(`Starting transcription: ${this.currentFile.name} with model: ${selectedModel}`, 'info');
        this.transcribeBtn.disabled = true;
        this.transcribeBtn.textContent = '🔄 Processing...';
        
        const formData = new FormData();
        formData.append('file', this.currentFile);
        formData.append('model', selectedModel);
        
        try {
            const response = await fetch('/transcribe', {
                method: 'POST',
                body: formData
            });
            
            if (response.ok) {
                // Get the filename from the response or use default
                const contentDisposition = response.headers.get('Content-Disposition');
                let filename = 'transcript.txt';
                if (contentDisposition) {
                    const match = contentDisposition.match(/filename="?([^"]+)"?/);
                    if (match) filename = match[1];
                }
                
                // Create download link
                const blob = await response.blob();
                const url = window.URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = filename;
                document.body.appendChild(a);
                a.click();
                window.URL.revokeObjectURL(url);
                document.body.removeChild(a);
                
                this.addLogEntry(`Transcription completed: ${filename}`, 'success');
                this.showNotification('Transcription completed successfully', 'success');
                
            } else if (response.status === 429) {
                this.addLogEntry('Server busy', 'warning');
                this.showNotification('Server is currently processing another request', 'warning');
            } else if (response.status === 409) {
                this.addLogEntry('Processing cancelled', 'warning');
                this.showNotification('Processing was cancelled', 'warning');
            } else {
                const errorText = await response.text();
                this.addLogEntry(`Server error: HTTP ${response.status}`, 'error');
                this.showNotification(`Server error: ${response.status}`, 'error');
            }
            
        } catch (error) {
            this.addLogEntry(`Connection error: ${error.message}`, 'error');
            this.showNotification('Connection error occurred', 'error');
        } finally {
            this.transcribeBtn.disabled = false;
            this.transcribeBtn.textContent = '🚀 Start Transcription';
        }
    }
    
    startStatusMonitoring() {
        if (this.isMonitoring) return;
        
        this.isMonitoring = true;
        this.statusUpdateInterval = setInterval(async () => {
            try {
                const response = await fetch('/status');
                if (response.ok) {
                    const data = await response.json();
                    this.updateStatusDisplay(data);
                }
            } catch (error) {
                // Silently handle errors in background monitoring
            }
        }, 2000); // Update every 2 seconds
        
        this.addLogEntry('Automatic status monitoring started', 'info');
    }
    
    stopStatusMonitoring() {
        if (this.statusUpdateInterval) {
            clearInterval(this.statusUpdateInterval);
            this.statusUpdateInterval = null;
            this.isMonitoring = false;
            this.addLogEntry('Automatic status monitoring stopped', 'info');
        }
    }
    
    addLogEntry(message, type = 'info') {
        const timestamp = new Date().toLocaleTimeString();
        const logEntry = document.createElement('div');
        logEntry.className = `log-entry ${type}`;
        logEntry.textContent = `[${timestamp}] ${message}`;
        
        this.activityLog.appendChild(logEntry);
        this.activityLog.scrollTop = this.activityLog.scrollHeight;
        
        // Keep only last 100 entries
        const entries = this.activityLog.children;
        if (entries.length > 100) {
            this.activityLog.removeChild(entries[0]);
        }
    }
    
    clearLog() {
        this.activityLog.innerHTML = '';
        this.addLogEntry('Activity log cleared', 'info');
    }
    
    showNotification(message, type = 'info', duration = 5000) {
        this.notification.textContent = message;
        this.notification.className = `notification ${type}`;
        this.notification.classList.add('show');
        
        setTimeout(() => {
            this.notification.classList.remove('show');
        }, duration);
    }
}

// Initialize the web client when the page loads
document.addEventListener('DOMContentLoaded', () => {
    window.whisperClient = new WhisperWebClient();
});

// Handle page unload
window.addEventListener('beforeunload', () => {
    if (window.whisperClient) {
        window.whisperClient.stopStatusMonitoring();
    }
}); 