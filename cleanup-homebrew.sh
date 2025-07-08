#!/bin/bash

###############################################################################
# 🧹 Homebrew Cleanup Script for macOS
# ------------------------------------
# This script performs comprehensive Homebrew cleanup and maintenance:
#
# ✅ CLEANUP FEATURES:
#   - Removes old versions of packages and casks
#   - Cleans up download cache
#   - Removes orphaned dependencies
#   - Runs brew doctor for health check
#   - Logs all cleanup activities
#
# 🔧 USAGE INSTRUCTIONS:
# 1. Make sure Homebrew is installed first:
#      ./install-homebrew.sh
# 2. Run cleanup:
#      ./cleanup-homebrew.sh
#
# 📁 Log output is saved to:
#      ~/Library/Logs/HomebrewCleanup.log
#
# ℹ️ Requirements:
#   - Homebrew must be installed
#   - macOS with admin privileges
#
# 🚨 Notes:
# - This script will remove old versions of packages
# - It's safe to run multiple times
# - Large cleanup operations may take time
###############################################################################

LOG="$HOME/Library/Logs/HomebrewCleanup.log"
echo "Starting Homebrew cleanup at $(date)" >> "$LOG"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG"
}

# Function to check if Homebrew is installed
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew is not installed. Please run ./install-homebrew.sh first."
        return 1
    fi
    return 0
}

# Function to get disk usage before cleanup
get_disk_usage() {
    local brew_prefix=$(brew --prefix)
    local usage=$(du -sh "$brew_prefix" 2>/dev/null | awk '{print $1}')
    echo "$usage"
}

# Function to perform cleanup operations
perform_cleanup() {
    local cleanup_summary=""
    local errors=""
    local success_count=0
    local error_count=0
    
    print_status "Starting Homebrew cleanup operations..."
    
    # Update Homebrew first
    print_status "Updating Homebrew..."
    if brew update >> "$LOG" 2>&1; then
        cleanup_summary+="✅ Homebrew updated successfully<br>"
        ((success_count++))
    else
        errors+="❌ Homebrew update failed<br>"
        ((error_count++))
    fi
    
    # Clean up old versions
    print_status "Cleaning up old versions..."
    if brew cleanup >> "$LOG" 2>&1; then
        cleanup_summary+="✅ Old versions cleaned up successfully<br>"
        ((success_count++))
    else
        errors+="❌ Cleanup failed<br>"
        ((error_count++))
    fi
    
    # Clean up download cache
    print_status "Cleaning up download cache..."
    if brew cleanup --prune=all >> "$LOG" 2>&1; then
        cleanup_summary+="✅ Download cache cleaned up successfully<br>"
        ((success_count++))
    else
        errors+="❌ Cache cleanup failed<br>"
        ((error_count++))
    fi
    
    # Remove orphaned dependencies
    print_status "Removing orphaned dependencies..."
    if brew autoremove >> "$LOG" 2>&1; then
        cleanup_summary+="✅ Orphaned dependencies removed successfully<br>"
        ((success_count++))
    else
        errors+="❌ Orphaned dependency removal failed<br>"
        ((error_count++))
    fi
    
    # Run brew doctor for health check
    print_status "Running brew doctor for health check..."
    if brew doctor >> "$LOG" 2>&1; then
        cleanup_summary+="✅ Health check completed successfully<br>"
        ((success_count++))
    else
        errors+="❌ Health check failed<br>"
        ((error_count++))
    fi
    
    # Return summary
    echo "$cleanup_summary"
    echo "$errors"
    echo "$success_count"
    echo "$error_count"
}

# Function to show cleanup statistics
show_cleanup_stats() {
    local before_usage="$1"
    local after_usage="$2"
    
    echo ""
    print_status "Cleanup Statistics:"
    echo "Before cleanup: $before_usage"
    echo "After cleanup:  $after_usage"
    
    # Calculate space saved (if possible)
    if [ "$before_usage" != "$after_usage" ]; then
        print_success "Space saved through cleanup!"
    fi
}

# Main execution
main() {
    print_status "Homebrew cleanup started at $(date)"
    
    # Check prerequisites
    if ! check_homebrew; then
        exit 1
    fi
    
    print_success "Homebrew is available. Starting cleanup..."
    
    # Get disk usage before cleanup
    print_status "Checking disk usage before cleanup..."
    local before_usage=$(get_disk_usage)
    print_status "Current Homebrew disk usage: $before_usage"
    
    # Perform cleanup operations
    local cleanup_results=$(perform_cleanup)
    local cleanup_summary=$(echo "$cleanup_results" | head -1)
    local errors=$(echo "$cleanup_results" | head -2 | tail -1)
    local success_count=$(echo "$cleanup_results" | head -3 | tail -1)
    local error_count=$(echo "$cleanup_results" | head -4 | tail -1)
    
    # Get disk usage after cleanup
    print_status "Checking disk usage after cleanup..."
    local after_usage=$(get_disk_usage)
    print_status "Homebrew disk usage after cleanup: $after_usage"
    
    # Show cleanup summary
    print_status "Cleanup complete! Summary:"
    echo "----------------------------------------" | tee -a "$LOG"
    
    if [ "$error_count" -eq 0 ]; then
        print_success "✅ All cleanup operations completed successfully ($success_count operations)"
    else
        print_warning "⚠️ Some cleanup operations had issues ($success_count/$((success_count + error_count)) operations)"
        print_warning "Failed operations:"
        echo "$errors" | tee -a "$LOG"
    fi
    
    # Show cleanup statistics
    show_cleanup_stats "$before_usage" "$after_usage"
    
    echo "" | tee -a "$LOG"
    print_status "Next steps:"
    echo "1. Your Homebrew installation is now cleaned up" | tee -a "$LOG"
    echo "2. Check the log file for detailed information: $LOG" | tee -a "$LOG"
    echo "3. Run this script periodically to maintain your Homebrew installation" | tee -a "$LOG"
    
    print_success "Homebrew cleanup completed at $(date)"
}

# Run main function
main "$@" 