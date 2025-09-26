# 📝 Sample Configurations

This document provides example configurations for different use cases, helping you understand how to customize the Homebrew scripts for your needs.

## 🎯 Configuration Examples

### 1. Developer Setup

Perfect for software developers who need development tools and productivity apps.

```bash
# Network Configuration
WIFI_NETWORK=""  # Allow any network
REQUIRE_AC_POWER=false  # Allow battery operation
MIN_BATTERY_PERCENTAGE=30

# Notifications
EMAIL_ADDRESS="developer@example.com"
PHONE_NUMBER="+1234567890"
ENABLE_EMAIL_NOTIFICATIONS=true
ENABLE_TEXT_NOTIFICATIONS=true

# Application Categories
INSTALL_DEVELOPMENT_TOOLS=true
INSTALL_PRODUCTIVITY_APPS=true
INSTALL_CREATIVE_APPS=false
INSTALL_COMMUNICATION_APPS=true
INSTALL_UTILITIES=true

# Custom Applications
declare -A CUSTOM_APPS=(
    # Development Tools
    ["visual-studio-code"]="Visual Studio Code:development"
    ["iterm2"]="iTerm2:development"
    ["docker"]="Docker Desktop:development"
    ["postman"]="Postman:development"
    ["sourcetree"]="Sourcetree:development"
    
    # Productivity
    ["notion"]="Notion:productivity"
    ["obsidian"]="Obsidian:productivity"
    ["alfred"]="Alfred:productivity"
    
    # Communication
    ["slack"]="Slack:communication"
    ["discord"]="Discord:communication"
    ["zoom"]="Zoom:communication"
    
    # Utilities
    ["rectangle"]="Rectangle:utilities"
    ["the-unarchiver"]="The Unarchiver:utilities"
    ["appcleaner"]="AppCleaner:utilities"
)

# Scheduling
DEFAULT_SCHEDULE="weekly"
```

### 2. Creative Professional Setup

Ideal for designers, video editors, and creative professionals.

```bash
# Network Configuration
WIFI_NETWORK="StudioWiFi"  # Require specific network
REQUIRE_AC_POWER=true  # Require AC power for large downloads

# Notifications
EMAIL_ADDRESS="creative@studio.com"
PHONE_NUMBER="+1987654321"

# Application Categories
INSTALL_DEVELOPMENT_TOOLS=false
INSTALL_PRODUCTIVITY_APPS=true
INSTALL_CREATIVE_APPS=true
INSTALL_COMMUNICATION_APPS=true
INSTALL_UTILITIES=true

# Custom Applications
declare -A CUSTOM_APPS=(
    # Creative Tools
    ["adobe-creative-cloud"]="Adobe Creative Cloud:creative"
    ["figma"]="Figma:creative"
    ["sketch"]="Sketch:creative"
    ["blender"]="Blender:creative"
    
    # Productivity
    ["notion"]="Notion:productivity"
    ["todoist"]="Todoist:productivity"
    
    # Communication
    ["slack"]="Slack:communication"
    ["zoom"]="Zoom:communication"
    
    # Utilities
    ["cleanmymac"]="CleanMyMac X:utilities"
    ["the-unarchiver"]="The Unarchiver:utilities"
)

# Scheduling (less frequent for large creative apps)
DEFAULT_SCHEDULE="manual"
```

### 3. Minimal Setup

For users who want just the basics with minimal automation.

```bash
# Network Configuration
WIFI_NETWORK=""  # Any network
REQUIRE_AC_POWER=false

# Notifications (disabled)
EMAIL_ADDRESS=""
PHONE_NUMBER=""
ENABLE_EMAIL_NOTIFICATIONS=false
ENABLE_TEXT_NOTIFICATIONS=false
ENABLE_DESKTOP_NOTIFICATIONS=true

# Application Categories (minimal)
INSTALL_DEVELOPMENT_TOOLS=false
INSTALL_PRODUCTIVITY_APPS=true
INSTALL_CREATIVE_APPS=false
INSTALL_COMMUNICATION_APPS=false
INSTALL_UTILITIES=true

# Custom Applications (essential only)
declare -A CUSTOM_APPS=(
    # Productivity
    ["alfred"]="Alfred:productivity"
    ["notion"]="Notion:productivity"
    
    # Utilities
    ["rectangle"]="Rectangle:utilities"
    ["the-unarchiver"]="The Unarchiver:utilities"
)

# Scheduling
DEFAULT_SCHEDULE="manual"
DEBUG_MODE=false
DRY_RUN_MODE=false
```

### 4. Enterprise/Corporate Setup

For corporate environments with specific security and compliance requirements.

```bash
# Network Configuration
WIFI_NETWORK="CorpNetwork"  # Require corporate network
ALLOWED_NETWORKS="CorpNetwork CorpGuest"  # Multiple allowed networks
REQUIRE_AC_POWER=true

# Notifications
EMAIL_ADDRESS="admin@company.com"
EMAIL_SUBJECT_PREFIX="[IT-Homebrew]"
ENABLE_EMAIL_NOTIFICATIONS=true
ENABLE_TEXT_NOTIFICATIONS=false  # Disable personal notifications

# Application Categories
INSTALL_DEVELOPMENT_TOOLS=true
INSTALL_PRODUCTIVITY_APPS=true
INSTALL_CREATIVE_APPS=false  # Restricted in corporate environment
INSTALL_COMMUNICATION_APPS=true
INSTALL_UTILITIES=true

# Custom Applications (corporate approved)
declare -A CUSTOM_APPS=(
    # Development (approved tools only)
    ["visual-studio-code"]="Visual Studio Code:development"
    ["docker"]="Docker Desktop:development"
    
    # Productivity
    ["microsoft-office"]="Microsoft Office:productivity"
    ["teams"]="Microsoft Teams:communication"
    
    # Security & Utilities
    ["1password"]="1Password:utilities"
    ["rectangle"]="Rectangle:utilities"
)

# Scheduling (during maintenance windows)
DEFAULT_SCHEDULE="weekly"
WEEKLY_UPDATE_DAY=0  # Sunday
WEEKLY_UPDATE_HOUR=3  # 3 AM

# Advanced settings
MAX_RETRIES=5
RETRY_DELAY=600  # 10 minutes
LOG_RETENTION_DAYS=90  # Keep logs longer for compliance
```

## 🔧 Configuration Patterns

### Environment-Specific Configurations

You can create different configuration files for different environments:

```bash
# Development environment
cp config/homebrew-scripts.conf config/dev-config.conf

# Production environment  
cp config/homebrew-scripts.conf config/prod-config.conf

# Use specific config
export HOMEBREW_CONFIG_FILE="config/dev-config.conf"
./homebrew-setup.sh
```

### Application Categories Explained

- **development**: IDEs, version control, containers, API tools
- **productivity**: Note-taking, task management, office suites
- **creative**: Design tools, video editing, 3D modeling
- **communication**: Chat, video conferencing, email clients
- **utilities**: System tools, file management, maintenance

### Notification Strategies

1. **Full Notifications**: Email + text for complete awareness
2. **Email Only**: Detailed reports without text interruptions
3. **Silent Mode**: Desktop notifications only
4. **Corporate Mode**: Email to admin, no personal notifications

### Scheduling Best Practices

- **daily**: For development machines with frequent changes
- **weekly**: Recommended for most users (balance of updates vs. interruption)
- **manual**: For critical systems or when you want full control

## 🧪 Testing Your Configuration

Always test your configuration before deploying:

```bash
# Validate configuration syntax
./homebrew-setup.sh --config-only

# Test with dry-run mode
./homebrew-setup.sh --dry-run

# Test with debug output
./homebrew-setup.sh --debug --dry-run
```

## 📚 Learning Exercises

1. **Modify the developer setup** to include your favorite tools
2. **Create a configuration** for a specific role (data scientist, designer, etc.)
3. **Set up different notification preferences** for work vs. personal use
4. **Experiment with scheduling options** to find what works for your workflow

## 🔗 Related Documentation

- [Configuration File Reference](../config/homebrew-scripts.conf)
- [Common Functions Library](../lib/common.sh)
- [Main Setup Script](../homebrew-setup.sh)
