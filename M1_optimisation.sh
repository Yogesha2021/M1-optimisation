#!/bin/bash
#
# macOS Optimisation Script for Jamf Pro
#
# Author: Yogesh Surwase
# Date: Sept 10, 2024
#
# This script automates the cleanup of macOS computer.
# It fix Spotlight indexing, clear cache, reset nvram, repair disk permissions, check and install available macOS updates 
# and restart services.


# Define log file
LOGFILE="$HOME/m1_optimization_log.txt"

# Function to write to log file
log() {
    echo "$(date "+%Y-%m-%d %H:%M:%S") : $1" | tee -a "$LOGFILE"
}

# Function to check if the user is root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log "ERROR: This script must be run as root. Please try again with sudo."
        exit 1
    fi
}

# Fixing Spotlight Indexing issues
fix_spotlight() {
    log "Fixing Spotlight Indexing..."
    sudo mdutil -i off / >> "$LOGFILE" 2>&1
    sudo mdutil -E / >> "$LOGFILE" 2>&1
    sudo mdutil -i on / >> "$LOGFILE" 2>&1
    log "Spotlight indexing reset completed."
}

# Clear the system cache
clear_cache() {
    log "Clearing system caches..."
    sudo rm -rf ~/Library/Caches/* >> "$LOGFILE" 2>&1
    sudo rm -rf /Library/Caches/* >> "$LOGFILE" 2>&1
    log "System caches cleared."
}

# Restarting the system services
restart_services() {
    log "Restarting system services..."
    sudo killall Finder >> "$LOGFILE" 2>&1
    sudo killall Dock >> "$LOGFILE" 2>&1
    sudo killall SystemUIServer >> "$LOGFILE" 2>&1
    log "System services restarted."
}

# Uninstall unnecessary launch daemons or agents
remove_unnecessary_daemons() {
    log "Removing unnecessary launch daemons and agents..."
    sudo find /Library/LaunchDaemons /Library/LaunchAgents -name "*.plist" -type f -delete >> "$LOGFILE" 2>&1
    log "Unnecessary daemons and agents removed."
}

# Resetting PRAM/NVRAM (Equivalent via terminal)
reset_nvram() {
    log "Resetting NVRAM..."
    sudo nvram -c >> "$LOGFILE" 2>&1
    log "NVRAM reset completed."
}

# Update macOS to the latest version
update_macos() {
    log "Checking for macOS updates..."
    sudo softwareupdate -ia >> "$LOGFILE" 2>&1
    log "macOS update completed."
}

# Optimizing storage space
optimize_storage() {
    log "Optimizing storage..."
    sudo rm -rf ~/Library/Application\ Support/CrashReporter/* >> "$LOGFILE" 2>&1
    sudo rm -rf ~/Library/Logs/* >> "$LOGFILE" 2>&1
    sudo rm -rf /private/var/log/* >> "$LOGFILE" 2>&1
    log "Storage optimization completed."
}

# Perform Disk Permission Repair
repair_disk_permissions() {
    log "Repairing disk permissions..."
    sudo diskutil resetUserPermissions / `id -u` >> "$LOGFILE" 2>&1
    log "Disk permission repair completed."
}

# Main Execution
log "M1 optimization script started."
check_root
fix_spotlight
clear_cache
restart_services
remove_unnecessary_daemons
reset_nvram
update_macos
optimize_storage
repair_disk_permissions
log "System optimization completed. Please restart your machine for changes to take effect."

echo "Optimization process completed. Check the log file at $LOGFILE for details."
