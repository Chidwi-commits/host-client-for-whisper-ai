#!/bin/bash

# Whisper Server Update Checker
# Checks for available updates from GitHub repository
# Author: Chidwi-commits

set -e  # Exit on any error

# Configuration - UPDATE THESE VALUES FOR YOUR REPOSITORY
REPO_URL="${WHISPER_REPO_URL:-https://github.com/YOUR_USERNAME/YOUR_REPO.git}"
PROJECT_DIR="/home/$(whoami)/whisper_project"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Checking for Whisper Server updates...${NC}"
echo

# Function to log messages
log_message() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

# Check if we're in a git repository
cd "$PROJECT_DIR"
if [[ ! -d ".git" ]]; then
    log_error "Not a git repository. Run deploy_from_github.sh first."
    exit 1
fi

# Fetch latest changes from remote
log_message "📡 Fetching latest changes from GitHub..."
git fetch origin main 2>/dev/null || {
    log_error "Failed to fetch from remote repository"
    exit 1
}

# Get current commit hash
CURRENT_COMMIT=$(git rev-parse HEAD)
REMOTE_COMMIT=$(git rev-parse origin/main)

echo -e "${BLUE}📊 Repository Status:${NC}"
echo "Current commit: $CURRENT_COMMIT"
echo "Remote commit:  $REMOTE_COMMIT"
echo

# Check if updates are available
if [[ "$CURRENT_COMMIT" == "$REMOTE_COMMIT" ]]; then
    echo -e "${GREEN}✅ Your Whisper server is up to date!${NC}"
    echo -e "${BLUE}📅 Last update: $(git log -1 --format='%cd' --date=relative)${NC}"
    echo -e "${BLUE}📝 Latest commit: $(git log -1 --format='%s')${NC}"
else
    echo -e "${YELLOW}🔄 Updates available!${NC}"
    echo
    echo -e "${BLUE}📋 Available changes:${NC}"
    git log --oneline --decorate --graph HEAD..origin/main
    echo
    echo -e "${BLUE}📈 Files that will be updated:${NC}"
    git diff --name-only HEAD origin/main
    echo
    echo -e "${GREEN}🚀 To update, run: ./update_from_github.sh${NC}"
fi

echo
echo -e "${BLUE}📊 Current server status:${NC}"
if systemctl is-active --quiet whisper-server; then
    echo -e "${GREEN}✅ Service is running${NC}"
    
    # Try to get server status via API
    if curl -s http://localhost:5000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ API is responding${NC}"
        STATUS=$(curl -s http://localhost:5000/status | grep -o '"status":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "Unknown")
        echo -e "${BLUE}📡 Server status: $STATUS${NC}"
    else
        echo -e "${YELLOW}⚠️  API not responding${NC}"
    fi
else
    echo -e "${RED}❌ Service is not running${NC}"
    echo -e "${BLUE}💡 Start with: sudo systemctl start whisper-server${NC}"
fi 