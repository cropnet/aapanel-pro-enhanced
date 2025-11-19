#!/bin/bash

################################################################################
# aaPanel PRO Enhanced - Revert Script
# schema.cx
#
# Purpose: Safely restore aaPanel to original state
# Version: 1.0.0
# License: MIT
#
# This script will restore your aaPanel installation from backups
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PANEL_PATH="/www/server/panel"
BACKUP_BASE="/root/aapanel_backups"

################################################################################
# Functions
################################################################################

print_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════╗
║        aaPanel PRO Enhanced - Revert Tool              ║
║            Schema Network Organisation                 ║
╚════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

print_step() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        exit 1
    fi
}

list_backups() {
    echo ""
    print_step "Available backups:"
    echo ""
    
    if [[ ! -d "$BACKUP_BASE" ]]; then
        print_error "No backup directory found at $BACKUP_BASE"
        exit 1
    fi
    
    local backups=($(ls -1t "$BACKUP_BASE" 2>/dev/null))
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        print_error "No backups found"
        echo ""
        print_warning "You can restore from official aaPanel sources using:"
        echo "  bt 15"
        exit 1
    fi
    
    local i=1
    for backup in "${backups[@]}"; do
        if [[ -f "$BACKUP_BASE/$backup/MANIFEST.txt" ]]; then
            local date=$(head -2 "$BACKUP_BASE/$backup/MANIFEST.txt" | tail -1 | cut -d: -f2-)
            echo "  [$i] $backup $date"
        else
            echo "  [$i] $backup"
        fi
        ((i++))
    done
    
    echo ""
}

select_backup() {
    local backups=($(ls -1t "$BACKUP_BASE" 2>/dev/null))
    
    echo ""
    read -p "Select backup number to restore (or 'q' to quit): " choice
    
    if [[ "$choice" == "q" ]]; then
        print_warning "Revert cancelled"
        exit 0
    fi
    
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#backups[@]}" ]; then
        print_error "Invalid selection"
        exit 1
    fi
    
    local selected_backup="${backups[$((choice-1))]}"
    BACKUP_DIR="$BACKUP_BASE/$selected_backup"
    
    echo ""
    print_success "Selected: $selected_backup"
}

confirm_revert() {
    echo ""
    print_warning "This will restore aaPanel files from backup:"
    echo "  Source: $BACKUP_DIR"
    echo "  Target: $PANEL_PATH"
    echo ""
    print_warning "Current modifications will be LOST!"
    echo ""
    
    read -p "Continue with restore? (yes/NO): " -r
    if [[ ! $REPLY == "yes" ]]; then
        print_error "Revert cancelled"
        exit 1
    fi
}

create_pre_revert_backup() {
    print_step "Creating pre-revert backup (safety measure)..."
    
    local safety_backup="$BACKUP_BASE/pre_revert_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$safety_backup"
    
    cp -r "$PANEL_PATH/class" "$safety_backup/" 2>/dev/null || true
    cp -r "$PANEL_PATH/BTPanel" "$safety_backup/" 2>/dev/null || true
    
    print_success "Safety backup created: $safety_backup"
}

restore_from_backup() {
    print_step "Restoring files from backup..."
    
    # Restore class directory
    if [[ -d "$BACKUP_DIR/class" ]]; then
        print_step "Restoring class/ directory..."
        cp -r "$BACKUP_DIR/class"/* "$PANEL_PATH/class/" 2>/dev/null || true
        print_success "class/ restored"
    else
        print_warning "No class/ directory in backup"
    fi
    
    # Restore BTPanel directory
    if [[ -d "$BACKUP_DIR/BTPanel" ]]; then
        print_step "Restoring BTPanel/ directory..."
        cp -r "$BACKUP_DIR/BTPanel"/* "$PANEL_PATH/BTPanel/" 2>/dev/null || true
        print_success "BTPanel/ restored"
    else
        print_warning "No BTPanel/ directory in backup"
    fi
}

clear_python_cache() {
    print_step "Clearing Python cache..."
    
    find "$PANEL_PATH" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find "$PANEL_PATH" -type f -name "*.pyc" -delete 2>/dev/null || true
    
    print_success "Python cache cleared"
}

restart_panel() {
    print_step "Restarting aaPanel..."
    
    bt restart >/dev/null 2>&1 || systemctl restart bt >/dev/null 2>&1 || /etc/init.d/bt restart >/dev/null 2>&1
    
    sleep 3
    
    print_success "aaPanel restarted"
}

verify_revert() {
    print_step "Verifying restoration..."
    
    if bt status | grep -q "running\|active"; then
        print_success "aaPanel is running"
    else
        print_warning "aaPanel may not be running properly"
        print_warning "Try: bt restart"
    fi
    
    # Check if modifications are removed
    if ! grep -q "return True.*PRO" "$PANEL_PATH/class/panelPlugin.py" 2>/dev/null; then
        print_success "Modifications appear to be reverted"
    else
        print_warning "Some modifications may still be present"
    fi
}

show_completion() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║               Revert Completed Successfully                   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}aaPanel has been restored from backup${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Clear your browser cache"
    echo "2. Access aaPanel: http://YOUR_SERVER_IP:7800"
    echo "3. Verify panel is functioning normally"
    echo ""
    echo "If you experience issues:"
    echo "• Try restarting aaPanel: bt restart"
    echo "• Check panel logs: bt logs"
    echo "• Repair from official sources: bt 15"
    echo ""
}

repair_from_official() {
    echo ""
    print_warning "Alternative: Repair from Official aaPanel Sources"
    echo ""
    echo "If backup restoration doesn't work, you can repair from official sources:"
    echo ""
    echo "  bt 15"
    echo ""
    echo "This will download and restore original aaPanel files."
    echo "Your data and configurations will be preserved."
    echo ""
}

################################################################################
# Main Revert Process
################################################################################

main() {
    print_banner
    
    check_root
    
    # Show available backups
    list_backups
    
    # Let user select backup
    select_backup
    
    # Confirm action
    confirm_revert
    
    # Create safety backup
    create_pre_revert_backup
    
    # Restore files
    restore_from_backup
    
    # Clean up
    clear_python_cache
    
    # Restart panel
    restart_panel
    
    # Verify
    verify_revert
    
    # Show completion
    show_completion
    
    # Show alternative
    repair_from_official
}

# Run main function
main "$@"
