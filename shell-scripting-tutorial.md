# 🎓 Shell Scripting Tutorial: Learning from Homebrew Scripts

This tutorial uses the Homebrew automation scripts as a practical example to teach shell scripting concepts. You'll learn by examining real-world code that solves actual problems.

## 📚 Learning Path

### Beginner Level
1. [Basic Script Structure](#basic-script-structure)
2. [Variables and Configuration](#variables-and-configuration)
3. [Functions and Modularity](#functions-and-modularity)
4. [User Input and Interaction](#user-input-and-interaction)

### Intermediate Level
5. [Error Handling and Validation](#error-handling-and-validation)
6. [Logging and Debugging](#logging-and-debugging)
7. [System Detection and Adaptation](#system-detection-and-adaptation)
8. [Configuration Management](#configuration-management)

### Advanced Level
9. [Process Management and Automation](#process-management-and-automation)
10. [Testing and Dry-Run Modes](#testing-and-dry-run-modes)
11. [Security and Safety Patterns](#security-and-safety-patterns)
12. [Documentation and Maintenance](#documentation-and-maintenance)

## 1. Basic Script Structure

### The Shebang Line
```bash
#!/usr/bin/env bash
```
**What it does:** Tells the system which interpreter to use
**Why `env bash`:** More portable than `/bin/bash` - works across different systems

### Script Metadata
```bash
###############################################################################
# Script Name: brew_setup_tahoe.sh
# Description: Educational Homebrew installer
# Version: 3.0.0
# License: MIT
###############################################################################
```
**Best Practice:** Always include metadata for maintainability

### Strict Error Handling
```bash
set -euo pipefail
```
**Breaking it down:**
- `set -e`: Exit on any command failure
- `set -u`: Exit on undefined variables
- `set -o pipefail`: Fail on pipe command failures

**Exercise:** Try removing these flags and see what happens when errors occur.

## 2. Variables and Configuration

### Constants vs Variables
```bash
# Constants (readonly)
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Variables (can change)
CURRENT_STEP=0
TOTAL_STEPS=8
```

### Configuration Arrays
```bash
# Associative arrays for structured data
declare -A CUSTOM_APPS=(
    ["visual-studio-code"]="Visual Studio Code:development"
    ["docker"]="Docker Desktop:development"
)

# Regular arrays for lists
CONFIG_LOCATIONS=(
    "$PROJECT_ROOT/config/homebrew-scripts.conf"  # Copy from .example.conf
    "$HOME/.config/homebrew-scripts/config.conf"
)
```

**Exercise:** Create your own associative array for favorite websites with categories.

## 3. Functions and Modularity

### Function Design Principles
```bash
# Good: Single responsibility, clear name, parameter validation
validate_email() {
    local email="$1"
    
    # Input validation
    if [[ -z "$email" ]]; then
        return 1
    fi
    
    # Business logic
    if [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}
```

### Function Libraries
```bash
# Source external functions
if [[ -f "$LIB_DIR/common.sh" ]]; then
    # shellcheck source=lib/common.sh
    source "$LIB_DIR/common.sh"
else
    echo "ERROR: Common library not found" >&2
    exit 1
fi
```

**Key Concepts:**
- **Single Responsibility:** Each function does one thing well
- **Parameter Validation:** Always check inputs
- **Return Codes:** Use 0 for success, non-zero for failure
- **Local Variables:** Use `local` to avoid global scope pollution

**Exercise:** Write a function that validates phone numbers using regex.

## 4. User Input and Interaction

### Interactive Prompts with Validation
```bash
ask_yes_no() {
    local prompt="$1"
    local default="${2:-y}"
    
    while true; do
        if [[ "$default" == "y" ]]; then
            echo -ne "${YELLOW}$prompt [Y/n]: ${NC}"
        else
            echo -ne "${YELLOW}$prompt [y/N]: ${NC}"
        fi
        
        read -r response
        response=${response,,}  # Convert to lowercase
        
        case "$response" in
            ""|"y"|"yes")
                [[ "$default" == "y" || "$response" != "" ]] && return 0 || return 1
                ;;
            "n"|"no")
                return 1
                ;;
            *)
                echo -e "${RED}Please answer yes or no.${NC}"
                ;;
        esac
    done
}
```

**Learning Points:**
- **Input Validation:** Loop until valid input
- **Default Values:** Handle empty input gracefully
- **Case Conversion:** `${response,,}` converts to lowercase
- **Color Coding:** Make interface user-friendly

**Exercise:** Create a function that asks for a number within a specific range.

## 5. Error Handling and Validation

### Defensive Programming
```bash
check_prerequisites() {
    local errors=0
    
    # Check operating system
    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "This script requires macOS"
        ((errors++))
    fi
    
    # Check required commands
    local required_commands=("curl" "git" "xcode-select")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_error "Required command not found: $cmd"
            ((errors++))
        fi
    done
    
    # Check disk space
    local available_space
    available_space=$(df -h "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ "${available_space%.*}" -lt 1 ]]; then
        log_error "Insufficient disk space (need at least 1GB)"
        ((errors++))
    fi
    
    return $errors
}
```

### Retry Logic with Backoff
```bash
retry_with_backoff() {
    local max_attempts="${MAX_RETRIES:-3}"
    local delay="${RETRY_DELAY:-5}"
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if "$@"; then
            return 0
        fi
        
        if [[ $attempt -lt $max_attempts ]]; then
            log_warning "Attempt $attempt failed, retrying in ${delay}s..."
            sleep "$delay"
            delay=$((delay * 2))  # Exponential backoff
        fi
        
        ((attempt++))
    done
    
    log_error "All $max_attempts attempts failed"
    return 1
}
```

**Key Patterns:**
- **Accumulate Errors:** Count problems, report all at once
- **Graceful Degradation:** Continue when possible, fail safely when not
- **Exponential Backoff:** Increase delay between retries
- **Resource Checking:** Validate system state before proceeding

## 6. Logging and Debugging

### Structured Logging System
```bash
# Log levels
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARNING=2
readonly LOG_LEVEL_ERROR=3

log_message() {
    local level="$1"
    local level_num="$2"
    local color="$3"
    local message="$4"
    
    # Check if message should be logged
    local current_level_num
    current_level_num=$(get_log_level_num)
    if [[ $level_num -lt $current_level_num ]]; then
        return 0
    fi
    
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Console output with color
    echo -e "${color}[$level]${NC} $message"
    
    # File output without color
    if [[ -n "${LOG_FILE:-}" ]]; then
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi
}
```

### Debug Mode Implementation
```bash
if [[ "${DEBUG_MODE:-false}" == "true" ]]; then
    set -x  # Enable command tracing
    LOG_LEVEL="DEBUG"
fi
```

**Learning Points:**
- **Structured Levels:** Different importance levels for different audiences
- **Dual Output:** Console for users, files for debugging
- **Conditional Logging:** Only log what's needed
- **Timestamps:** Essential for debugging timing issues

## 7. System Detection and Adaptation

### Architecture Detection
```bash
detect_architecture() {
    local arch
    arch="$(uname -m)"
    
    case "$arch" in
        "arm64")
            echo "apple_silicon"
            ;;
        "x86_64")
            echo "intel"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

get_homebrew_prefix() {
    local arch
    arch=$(detect_architecture)
    
    case "$arch" in
        "apple_silicon")
            echo "/opt/homebrew"
            ;;
        "intel")
            echo "/usr/local"
            ;;
        *)
            log_error "Unknown architecture: $arch"
            return 1
            ;;
    esac
}
```

### Network and Power Awareness
```bash
check_power_status() {
    local power_info
    power_info=$(pmset -g ps 2>/dev/null)
    
    if [[ "${REQUIRE_AC_POWER:-true}" == "true" ]]; then
        if echo "$power_info" | grep -q "AC Power"; then
            log_success "Device is connected to AC power"
            return 0
        else
            log_warning "Device is running on battery power"
            return 1
        fi
    fi
    
    # Additional battery level checking logic...
}
```

**Concepts Demonstrated:**
- **System Adaptation:** Different behavior for different systems
- **Feature Detection:** Check capabilities before using them
- **Graceful Fallbacks:** Handle unsupported scenarios
- **Environmental Awareness:** Adapt to power, network, etc.

## 🧪 Practical Exercises

### Exercise 1: Basic Function
Write a function that checks if a directory exists and creates it if it doesn't:

```bash
ensure_directory() {
    # Your code here
}
```

### Exercise 2: Configuration Validation
Create a function that validates a configuration file exists and is readable:

```bash
validate_config_file() {
    # Your code here
}
```

### Exercise 3: User Choice Menu
Build a function that presents a menu and returns the user's choice:

```bash
show_menu() {
    # Your code here
}
```

## 🔗 Next Steps

1. **Study the actual scripts** in this repository
2. **Modify configurations** to see how they affect behavior
3. **Add your own functions** to extend functionality
4. **Create your own scripts** using these patterns
5. **Share your improvements** with the community

## 📖 Additional Resources

- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [ShellCheck](https://www.shellcheck.net/) - Script analysis tool
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)
