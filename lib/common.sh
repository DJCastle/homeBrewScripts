#!/usr/bin/env bash
###############################################################################
# Library: common.sh
# Description: 📚 Common functions and utilities for Homebrew scripts
# Version: 2.0.0
#
# EDUCATIONAL PURPOSE:
# This library demonstrates modular shell scripting practices, showing how to:
# - Create reusable functions across multiple scripts
# - Implement consistent error handling and logging
# - Manage configuration loading and validation
# - Provide user-friendly output with colors and formatting
#
# LEARNING OBJECTIVES:
# - Understand shell script libraries and sourcing
# - Learn about function design and parameter handling
# - See examples of input validation and error handling
# - Practice with logging patterns and user interaction
###############################################################################

# Prevent multiple sourcing of this library
if [[ -n "${HOMEBREW_COMMON_LIB_LOADED:-}" ]]; then
    return 0
fi
readonly HOMEBREW_COMMON_LIB_LOADED=1

# =============================================================================
# GLOBAL VARIABLES AND CONSTANTS
# =============================================================================

# Script directory detection (works from any script location)
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
readonly LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$LIB_DIR/.." && pwd)"

# Configuration file locations (in order of precedence)
readonly CONFIG_LOCATIONS=(
    "$PROJECT_ROOT/config/homebrew-scripts.conf"
    "$HOME/.config/homebrew-scripts/config.conf"
    "$HOME/.homebrew-scripts.conf"
)

# Color codes for output formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Log levels
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARNING=2
readonly LOG_LEVEL_ERROR=3

# Default configuration values
readonly DEFAULT_LOG_DIR="$HOME/Library/Logs"
readonly DEFAULT_CONFIG_DIR="$HOME/.config/homebrew-scripts"

# =============================================================================
# CONFIGURATION MANAGEMENT
# =============================================================================

# Load configuration file
load_config() {
    local config_file=""
    
    # Find the first existing configuration file
    for config_path in "${CONFIG_LOCATIONS[@]}"; do
        if [[ -f "$config_path" ]]; then
            config_file="$config_path"
            break
        fi
    done
    
    # If no config file found, create a default one
    if [[ -z "$config_file" ]]; then
        log_info "No configuration file found. Creating default configuration..."
        create_default_config
        config_file="${CONFIG_LOCATIONS[0]}"
    fi
    
    # Source the configuration file
    if [[ -f "$config_file" ]]; then
        # shellcheck source=/dev/null
        source "$config_file" || {
            log_error "Failed to load configuration from: $config_file"
            return 1
        }
        log_debug "Configuration loaded from: $config_file"
    else
        log_error "Configuration file not found: $config_file"
        return 1
    fi
    
    # Set up logging after configuration is loaded
    setup_logging
    
    return 0
}

# Create default configuration file
create_default_config() {
    local config_dir
    config_dir="$(dirname "${CONFIG_LOCATIONS[0]}")"
    
    # Create config directory if it doesn't exist
    mkdir -p "$config_dir" || {
        log_error "Failed to create config directory: $config_dir"
        return 1
    }
    
    # Copy the template configuration
    if [[ -f "$PROJECT_ROOT/config/homebrew-scripts.conf" ]]; then
        cp "$PROJECT_ROOT/config/homebrew-scripts.conf" "${CONFIG_LOCATIONS[0]}" || {
            log_error "Failed to create default configuration file"
            return 1
        }
        log_info "Created default configuration: ${CONFIG_LOCATIONS[0]}"
    else
        log_error "Template configuration file not found"
        return 1
    fi
}

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================

# Set up logging based on configuration
setup_logging() {
    # Create log directory if it doesn't exist
    local log_dir="${LOG_DIR:-$DEFAULT_LOG_DIR}"
    mkdir -p "$log_dir" || {
        echo "ERROR: Failed to create log directory: $log_dir" >&2
        return 1
    }
    
    # Set default log file if not specified
    if [[ -z "${LOG_FILE:-}" ]]; then
        LOG_FILE="$log_dir/${MAIN_LOG_FILE:-HomebrewScripts.log}"
    fi
    
    # Initialize log file with session header
    {
        echo ""
        echo "=========================================="
        echo "Session started: $(date)"
        echo "Script: ${0##*/}"
        echo "User: $(whoami)"
        echo "System: $(uname -a)"
        echo "=========================================="
    } >> "$LOG_FILE"
}

# Get numeric log level
get_log_level_num() {
    case "${LOG_LEVEL:-INFO}" in
        "DEBUG") echo $LOG_LEVEL_DEBUG ;;
        "INFO") echo $LOG_LEVEL_INFO ;;
        "WARNING") echo $LOG_LEVEL_WARNING ;;
        "ERROR") echo $LOG_LEVEL_ERROR ;;
        *) echo $LOG_LEVEL_INFO ;;
    esac
}

# Generic logging function
log_message() {
    local level="$1"
    local level_num="$2"
    local color="$3"
    local message="$4"
    local current_level_num
    current_level_num=$(get_log_level_num)

    # Check if message should be logged based on log level
    if [[ $level_num -lt $current_level_num ]]; then
        return 0
    fi

    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local iso_timestamp
    iso_timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

    # Print to console with color
    echo -e "${color}[$level]${NC} $message"

    # Write to standard log file without color codes
    if [[ -n "${LOG_FILE:-}" ]]; then
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi

    # Write to JSON log file if enabled (NEW in 2026)
    if [[ "${ENABLE_JSON_LOGS:-false}" == "true" ]] && [[ -n "${LOG_FILE:-}" ]]; then
        local json_log_file="${LOG_FILE%.log}.json"
        # Escape quotes and backslashes in message for JSON
        local escaped_message
        escaped_message=$(echo "$message" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
        # Write JSON log entry
        echo "{\"timestamp\":\"$iso_timestamp\",\"level\":\"$level\",\"message\":\"$escaped_message\",\"script\":\"${0##*/}\",\"user\":\"$(whoami)\",\"pid\":$$}" >> "$json_log_file"
    fi
}

# Specific logging functions
log_debug() {
    log_message "DEBUG" $LOG_LEVEL_DEBUG "$PURPLE" "$1"
}

log_info() {
    log_message "INFO" $LOG_LEVEL_INFO "$BLUE" "$1"
}

log_success() {
    log_message "SUCCESS" $LOG_LEVEL_INFO "$GREEN" "$1"
}

log_warning() {
    log_message "WARNING" $LOG_LEVEL_WARNING "$YELLOW" "$1"
}

log_error() {
    log_message "ERROR" $LOG_LEVEL_ERROR "$RED" "$1" >&2
}

# Log step with progress tracking
log_step() {
    local step_num="${1:-}"
    local total_steps="${2:-}"
    local message="$3"
    
    if [[ -n "$step_num" && -n "$total_steps" ]]; then
        echo -e "\n${CYAN}==> Step $step_num/$total_steps: $message${NC}"
        log_info "Step $step_num/$total_steps: $message"
    else
        echo -e "\n${CYAN}==> $message${NC}"
        log_info "$message"
    fi
}

# =============================================================================
# USER INTERACTION FUNCTIONS
# =============================================================================

# Ask yes/no question with timeout support
ask_yes_no() {
    local prompt="$1"
    local default="${2:-y}"
    local timeout="${INPUT_TIMEOUT:-0}"
    
    # Skip prompts if configured to do so
    if [[ "${SKIP_CONFIRMATIONS:-false}" == "true" ]]; then
        log_debug "Skipping confirmation (auto-yes): $prompt"
        return 0
    fi
    
    # In dry run mode, always return yes but show what would be asked
    if [[ "${DRY_RUN_MODE:-false}" == "true" ]]; then
        log_info "[DRY RUN] Would ask: $prompt"
        return 0
    fi
    
    local prompt_text
    if [[ "$default" == "y" ]]; then
        prompt_text="${YELLOW}$prompt [Y/n]: ${NC}"
    else
        prompt_text="${YELLOW}$prompt [y/N]: ${NC}"
    fi
    
    while true; do
        local response
        
        if [[ $timeout -gt 0 ]]; then
            echo -ne "$prompt_text"
            if read -t "$timeout" -r response; then
                echo  # Add newline after input
            else
                echo  # Add newline after timeout
                log_warning "Input timeout after ${timeout}s, using default: $default"
                response=""
            fi
        else
            echo -ne "$prompt_text"
            read -r response
        fi
        
        response=${response,,}  # Convert to lowercase
        
        case "$response" in
            ""|"y"|"yes")
                if [[ "$default" == "y" || "$response" != "" ]]; then
                    return 0
                else
                    return 1
                fi
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

# Ask for choice from multiple options
ask_choice() {
    local prompt="$1"
    shift
    local options=("$@")
    
    # Skip prompts if configured to do so
    if [[ "${SKIP_CONFIRMATIONS:-false}" == "true" ]]; then
        log_debug "Skipping choice (auto-selecting first): $prompt"
        echo "1"
        return
    fi
    
    # In dry run mode, show what would be asked
    if [[ "${DRY_RUN_MODE:-false}" == "true" ]]; then
        log_info "[DRY RUN] Would ask: $prompt"
        echo "1"
        return
    fi
    
    echo -e "${YELLOW}$prompt${NC}"
    for i in "${!options[@]}"; do
        echo "  $((i + 1)). ${options[i]}"
    done
    
    while true; do
        echo -ne "${YELLOW}Enter your choice [1-${#options[@]}]: ${NC}"
        local choice
        read -r choice
        
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "${#options[@]}" ]]; then
            echo "$choice"
            return
        else
            echo -e "${RED}Please enter a number between 1 and ${#options[@]}.${NC}"
        fi
    done
}

# Display a checkpoint with optional continuation
checkpoint() {
    local message="$1"
    local default="${2:-y}"
    
    echo
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}CHECKPOINT${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if ! ask_yes_no "$message" "$default"; then
        log_info "Skipping this step as requested"
        return 1
    fi
    
    return 0
}

# =============================================================================
# SYSTEM DETECTION FUNCTIONS
# =============================================================================

# Detect system architecture
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

# Get Homebrew prefix based on architecture
get_homebrew_prefix() {
    if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
        echo "$HOMEBREW_PREFIX"
        return
    fi
    
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

# Check if running on macOS
is_macos() {
    [[ "$(uname)" == "Darwin" ]]
}

# Get macOS version
get_macos_version() {
    if is_macos; then
        sw_vers -productVersion
    else
        echo "Not macOS"
        return 1
    fi
}

# =============================================================================
# NETWORK FUNCTIONS
# =============================================================================

# Check if connected to allowed WiFi network
check_wifi_network() {
    # Skip check if no network requirements configured
    if [[ -z "${WIFI_NETWORK:-}" && -z "${ALLOWED_NETWORKS:-}" ]]; then
        log_debug "No WiFi network requirements configured, skipping check"
        return 0
    fi
    
    local interface="${NETWORK_INTERFACE:-en0}"
    local current_network
    current_network=$(networksetup -getairportnetwork "$interface" 2>/dev/null | awk -F': ' '{print $2}')
    
    if [[ -z "$current_network" ]]; then
        log_warning "Could not determine current WiFi network"
        return 1
    fi
    
    # Check against specific network
    if [[ -n "${WIFI_NETWORK:-}" ]]; then
        if [[ "$current_network" == "$WIFI_NETWORK" ]]; then
            log_success "Connected to required WiFi network: $WIFI_NETWORK"
            return 0
        else
            log_warning "Not connected to required WiFi network '$WIFI_NETWORK' (current: '$current_network')"
            return 1
        fi
    fi
    
    # Check against allowed networks list
    if [[ -n "${ALLOWED_NETWORKS:-}" ]]; then
        local allowed_array
        read -ra allowed_array <<< "$ALLOWED_NETWORKS"
        
        for allowed_network in "${allowed_array[@]}"; do
            if [[ "$current_network" == "$allowed_network" ]]; then
                log_success "Connected to allowed WiFi network: $allowed_network"
                return 0
            fi
        done
        
        log_warning "Not connected to any allowed WiFi network (current: '$current_network')"
        log_info "Allowed networks: $ALLOWED_NETWORKS"
        return 1
    fi
    
    return 1
}

# Check internet connectivity
check_internet_connection() {
    local timeout="${NETWORK_TIMEOUT:-30}"
    
    log_debug "Checking internet connectivity..."
    
    if curl --connect-timeout "$timeout" --silent --head "https://www.google.com" >/dev/null 2>&1; then
        log_success "Internet connection verified"
        return 0
    else
        log_error "No internet connection available"
        return 1
    fi
}

# =============================================================================
# POWER MANAGEMENT FUNCTIONS
# =============================================================================

# Check power status
check_power_status() {
    local power_info
    power_info=$(pmset -g ps 2>/dev/null)
    
    if [[ -z "$power_info" ]]; then
        log_warning "Could not determine power status"
        return 1
    fi
    
    # Check if AC power is required
    if [[ "${REQUIRE_AC_POWER:-true}" == "true" ]]; then
        if echo "$power_info" | grep -q "AC Power"; then
            log_success "Device is connected to AC power"
            return 0
        else
            log_warning "Device is running on battery power (AC power required)"
            return 1
        fi
    else
        # Check battery percentage if running on battery
        if echo "$power_info" | grep -q "Battery Power"; then
            local battery_pct
            battery_pct=$(echo "$power_info" | grep -o '[0-9]*%' | head -1 | tr -d '%')
            local min_battery="${MIN_BATTERY_PERCENTAGE:-50}"
            
            if [[ -n "$battery_pct" && "$battery_pct" -ge "$min_battery" ]]; then
                log_success "Battery level sufficient: ${battery_pct}% (minimum: ${min_battery}%)"
                return 0
            else
                log_warning "Battery level too low: ${battery_pct}% (minimum: ${min_battery}%)"
                return 1
            fi
        else
            log_success "Device is connected to AC power"
            return 0
        fi
    fi
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Retry function with exponential backoff
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

# Clean up old log files
cleanup_old_logs() {
    local log_dir="${LOG_DIR:-$DEFAULT_LOG_DIR}"
    local retention_days="${LOG_RETENTION_DAYS:-30}"

    if [[ ! -d "$log_dir" ]]; then
        return 0
    fi

    log_debug "Cleaning up log files older than $retention_days days..."

    find "$log_dir" -name "*.log" -type f -mtime "+$retention_days" -delete 2>/dev/null || true
}

# =============================================================================
# EDUCATIONAL ERROR HANDLING SYSTEM
# =============================================================================

# Enhanced error reporting with educational context
report_error() {
    local error_code="$1"
    local error_message="$2"
    local context="${3:-}"
    local suggestions="${4:-}"

    log_error "❌ Error $error_code: $error_message"

    if [[ -n "$context" ]]; then
        echo
        echo -e "${YELLOW}📖 What this means:${NC}"
        echo "$context"
    fi

    if [[ -n "$suggestions" ]]; then
        echo
        echo -e "${CYAN}💡 How to fix this:${NC}"
        echo "$suggestions"
    fi

    echo
    echo -e "${BLUE}🔍 For more help:${NC}"
    echo "  • Check the log file: ${LOG_FILE:-~/Library/Logs/HomebrewScripts.log}"
    echo "  • Run with --debug for more details"
    echo "  • See docs/safety-and-best-practices.md for troubleshooting"
    echo
}

# Common error scenarios with educational explanations
handle_network_error() {
    report_error "NET001" "Network connection failed" \
        "This usually means your internet connection is down or unstable, or there's a firewall blocking the connection." \
        "1. Check your internet connection
2. Try connecting to a different network
3. Check if your firewall is blocking connections
4. Wait a few minutes and try again"
}

handle_permission_error() {
    local file_path="$1"
    report_error "PERM001" "Permission denied accessing: $file_path" \
        "This means the script doesn't have permission to read or write to this location. This is a security feature of macOS." \
        "1. Make sure you're running the script as your user (not root)
2. Check if the file/directory exists and is readable
3. You may need to enter your password when prompted
4. Some operations require administrator privileges"
}

handle_disk_space_error() {
    local required_space="$1"
    local available_space="$2"
    report_error "DISK001" "Insufficient disk space" \
        "The script needs $required_space but only $available_space is available. Homebrew and applications require significant disk space." \
        "1. Free up disk space by deleting unnecessary files
2. Empty your Trash
3. Use 'brew cleanup' to remove old package versions
4. Consider using external storage for large files"
}

handle_homebrew_error() {
    local operation="$1"
    report_error "BREW001" "Homebrew operation failed: $operation" \
        "Homebrew encountered an error during $operation. This could be due to network issues, package conflicts, or system configuration problems." \
        "1. Run 'brew doctor' to check for issues
2. Run 'brew update' to get the latest package information
3. Check your internet connection
4. Try the operation again after a few minutes
5. Check if the package name is correct"
}

handle_configuration_error() {
    local config_file="$1"
    local line_number="${2:-}"
    report_error "CONFIG001" "Configuration file error: $config_file" \
        "There's a syntax error or invalid value in your configuration file. Configuration files use bash syntax and must be valid." \
        "1. Check the syntax of your configuration file
2. Look for missing quotes, brackets, or semicolons
3. Validate variable names and values
4. Compare with the example configuration
5. Use 'bash -n $config_file' to check syntax"
}

handle_system_requirement_error() {
    local requirement="$1"
    local current_value="$2"
    local required_value="$3"
    report_error "SYS001" "System requirement not met: $requirement" \
        "Your system has $requirement = '$current_value' but this script requires '$required_value'. This ensures compatibility and safety." \
        "1. Check if your system meets the minimum requirements
2. Update your system if possible
3. Use a different script version if available
4. Contact support if you believe this is an error"
}

# Validation error with educational context
validate_with_error() {
    local validation_function="$1"
    local value="$2"
    local field_name="$3"
    local help_text="${4:-}"

    if ! "$validation_function" "$value"; then
        echo
        log_error "❌ Invalid $field_name: '$value'"

        if [[ -n "$help_text" ]]; then
            echo -e "${YELLOW}📖 Expected format:${NC}"
            echo "$help_text"
        fi

        echo -e "${CYAN}💡 Examples:${NC}"
        case "$field_name" in
            "email")
                echo "  • user@example.com"
                echo "  • john.doe@company.org"
                echo "  • admin@domain.co.uk"
                ;;
            "phone")
                echo "  • +1234567890 (US/Canada)"
                echo "  • +447123456789 (UK)"
                echo "  • +33123456789 (France)"
                ;;
            "percentage")
                echo "  • 50 (for 50%)"
                echo "  • 75 (for 75%)"
                echo "  • 100 (for 100%)"
                ;;
        esac

        return 1
    fi

    return 0
}

# Initialize the common library
init_common_lib() {
    # Load configuration
    if ! load_config; then
        handle_configuration_error "${CONFIG_LOCATIONS[0]}"
        return 1
    fi

    # Clean up old logs
    cleanup_old_logs

    log_debug "Common library initialized successfully"
    return 0
}

###############################################################################
# END OF COMMON LIBRARY
###############################################################################
