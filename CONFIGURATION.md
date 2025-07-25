# 🔧 Configuration Guide

**⚠️ This guide is ONLY for developers who want to modify the code and maintain their own fork.**

**For regular usage, no configuration is needed** - just use the deployment command from README.md

---

This guide explains how to configure the Whisper Server for your own GitHub repository and environment.

## 📋 Prerequisites

**Do you really need this?** 
- ✅ **Just want to use Whisper server?** → Use the main deployment command, skip this guide
- ✅ **Want to modify the code?** → Continue reading

For developers only:
1. **Fork this repository** to your GitHub account
2. **Update repository references** in the deployment scripts
3. **Configure for your modifications**

## 🔗 Repository Configuration

### Step 1: Update Repository URLs

Edit the following files and replace `YOUR_USERNAME/YOUR_REPO` with your actual GitHub repository:

**deploy_from_github.sh:**
```bash
# Line 9: Update repository URL
REPO_URL="${WHISPER_REPO_URL:-https://github.com/YOUR_USERNAME/YOUR_REPO.git}"
```

**update_from_github.sh:**
```bash
# Line 9: Update repository URL  
REPO_URL="${WHISPER_REPO_URL:-https://github.com/YOUR_USERNAME/YOUR_REPO.git}"
```

**check_updates.sh:**
```bash
# Line 9: Update repository URL
REPO_URL="${WHISPER_REPO_URL:-https://github.com/YOUR_USERNAME/YOUR_REPO.git}"
```

### Step 2: Update README.md

**Line 14: Update deployment command:**
```bash
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/deploy_from_github.sh | bash
```

**Line 4: Update badge (optional):**
```markdown
[![GitHub](https://img.shields.io/badge/GitHub-YOUR_USERNAME-blue?logo=github)](https://github.com/YOUR_USERNAME/YOUR_REPO)
```

## 🌍 Environment Variables (Optional)

You can also set environment variables to avoid editing files:

```bash
# Set repository URL globally
export WHISPER_REPO_URL="https://github.com/your-username/whisper-server.git"

# Then run scripts normally
./deploy_from_github.sh
./update_from_github.sh
```

## 📁 Directory Structure

The scripts automatically adapt to any username:
- Project directory: `/home/$(whoami)/whisper_project`
- Backup directory: `/home/$(whoami)/whisper_backup_TIMESTAMP`
- User/Group: `$(whoami):$(whoami)`

## 🔐 Security Notes

**✅ Safe to share:**
- All scripts use dynamic user detection
- No hardcoded passwords or keys
- Generic localhost references only

**⚠️ Before sharing, verify:**
- No personal API keys in code
- No custom IP addresses in documentation
- No sensitive configuration data

## 🚀 Deployment Examples

### For Your Own Repository:

```bash
# Option 1: Edit scripts directly
git clone https://github.com/your-username/whisper-server.git
cd whisper-server
# Edit repository URLs in scripts
./deploy_from_github.sh

# Option 2: Use environment variable
export WHISPER_REPO_URL="https://github.com/your-username/whisper-server.git"
curl -sSL https://raw.githubusercontent.com/your-username/whisper-server/main/deploy_from_github.sh | bash
```

### For Testing/Development:

```bash
# Use a different project directory
export WHISPER_PROJECT_DIR="/opt/whisper-test"
./deploy_from_github.sh
```

## 📝 Customization Tips

1. **Custom project directory:** Modify `PROJECT_DIR` variable in scripts
2. **Different service name:** Change `SERVICE_NAME` variable  
3. **Custom backup location:** Modify `BACKUP_DIR` variable
4. **Additional repositories:** Fork and modify for multiple instances

## 🔄 Maintenance

After updating repository URLs:

```bash
# Test configuration
./check_updates.sh

# Update existing installation
./update_from_github.sh
``` 