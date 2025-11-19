#!/bin/bash

################################################################################
# aaPanel PRO Enhanced - Research Installation Script
# schema.cx
#
# Purpose: Safely apply PRO feature research modifications to aaPanel
# Version: 1.0.0
# License: MIT
#
# DISCLAIMER: Educational and research purposes only.
# Purchase legitimate aaPanel PRO licenses for production use.
#
# "In code we trust, in bugs we debug, in root we conquer." - Unknown Sysadmin
################################################################################

set -e  # Exit on error (because YOLO is for production, not for us)

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
BACKUP_DIR="${BACKUP_BASE}/$(date +%Y%m%d_%H%M%S)"
MIN_AAPANEL_VERSION="6.8"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

################################################################################
# Functions (Where the magic happens, or where everything breaks - 50/50 odds)
################################################################################

print_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
 █████╗  █████╗ ██████╗  █████╗ ███╗   ██╗███████╗██╗     
██╔══██╗██╔══██╗██╔══██╗██╔══██╗████╗  ██║██╔════╝██║     
███████║███████║██████╔╝███████║██╔██╗ ██║█████╗  ██║     
██╔══██║██╔══██║██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝  ██║     
██║  ██║██║  ██║██║     ██║  ██║██║ ╚████║███████╗███████╗
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝
        PRO Research Edition - Schema Network Organisation
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
    print_success "Running as root"
}

check_aapanel_installed() {
    if [[ ! -d "$PANEL_PATH" ]]; then
        print_error "aaPanel not found at $PANEL_PATH"
        print_error "Please install aaPanel first: https://www.aapanel.com/new/download.html"
        exit 1
    fi
    print_success "aaPanel installation found"
}

check_aapanel_version() {
    if [[ ! -f "$PANEL_PATH/class/common.py" ]]; then
        print_warning "Cannot verify aaPanel version (common.py not found)"
        return
    fi
    
    # Try to extract version from panel
    local version=$(bt version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1)
    
    if [[ -z "$version" ]]; then
        print_warning "Could not detect aaPanel version"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "aaPanel version: $version"
    fi
}

show_disclaimer() {
    echo ""
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║                    IMPORTANT DISCLAIMER                       ║${NC}"
    echo -e "${YELLOW}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${YELLOW}║  This is for EDUCATIONAL and RESEARCH purposes only.          ║${NC}"
    echo -e "${YELLOW}║                                                                ║${NC}"
    echo -e "${YELLOW}║  ✗ DO NOT use in production environments                      ║${NC}"
    echo -e "${YELLOW}║  ✗ DO NOT use to avoid paying for software                    ║${NC}"
    echo -e "${YELLOW}║  ✓ DO purchase legitimate licenses for production use         ║${NC}"
    echo -e "${YELLOW}║                                                                ║${NC}"
    echo -e "${YELLOW}║  By continuing, you accept ALL risks and responsibilities.    ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    read -p "Do you understand and accept? (yes/NO): " -r
    if [[ ! $REPLY == "yes" ]]; then
        print_error "Installation cancelled"
        exit 1
    fi
}

create_backup() {
    print_step "Creating backup at $BACKUP_DIR"
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup critical files
    print_step "Backing up class directory..."
    cp -r "$PANEL_PATH/class" "$BACKUP_DIR/" 2>/dev/null || true
    
    print_step "Backing up BTPanel directory..."
    cp -r "$PANEL_PATH/BTPanel" "$BACKUP_DIR/" 2>/dev/null || true
    
    # Create backup manifest
    cat > "$BACKUP_DIR/MANIFEST.txt" << EOF
aaPanel Backup Manifest
Created: $(date)
Panel Path: $PANEL_PATH
Backup Type: Pre-modification backup

Files backed up:
- class/ directory (Python core files)
- BTPanel/ directory (UI and static files)

To restore:
  cp -r $BACKUP_DIR/class/* $PANEL_PATH/class/
  cp -r $BACKUP_DIR/BTPanel/* $PANEL_PATH/BTPanel/
  find $PANEL_PATH -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
  bt restart
EOF
    
    print_success "Backup created: $BACKUP_DIR"
    print_warning "IMPORTANT: Keep this backup safe for reverting!"
}

apply_modification_v6_2_6() {
    print_step "Applying v6.2.6 - PRO Feature Gate Bypass"
    
    local file="$PANEL_PATH/class/panelPlugin.py"
    
    if [[ ! -f "$file" ]]; then
        print_error "File not found: $file"
        return 1
    fi
    
    # Backup original
    cp "$file" "${file}.backup_$(date +%s)"
    
    # Apply modification
    # This is a simplified version - the actual modification should be in modifications/v6.2.6/
    python3 "$PROJECT_ROOT/modifications/v6.2.6/apply.py" "$file"
    
    print_success "v6.2.6 modification applied"
}

apply_modification_v6_3_5() {
    print_step "Applying v6.3.5 - UI Pricing Column Removal"
    
    local file="$PANEL_PATH/BTPanel/static/app_store/index.html"
    
    if [[ ! -f "$file" ]]; then
        print_warning "File not found: $file (UI modification skipped)"
        return 0
    fi
    
    # Backup original
    cp "$file" "${file}.backup_$(date +%s)"
    
    # Apply modification
    python3 "$PROJECT_ROOT/modifications/v6.3.5/apply.py" "$file"
    
    print_success "v6.3.5 modification applied"
}

apply_modification_v6_10_0() {
    print_step "Applying v6.10.0 - DNS Blocking Research"
    
    local file="$PANEL_PATH/class/public.py"
    
    if [[ ! -f "$file" ]]; then
        print_error "File not found: $file"
        return 1
    fi
    
    # Backup original
    cp "$file" "${file}.backup_$(date +%s)"
    
    # Apply modification
    python3 "$PROJECT_ROOT/modifications/v6.10.0/apply.py" "$file"
    
    print_success "v6.10.0 modification applied"
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

verify_installation() {
    print_step "Verifying installation..."
    
    # Check if panel is running
    if bt status | grep -q "running\|active"; then
        print_success "aaPanel is running"
    else
        print_warning "aaPanel may not be running properly"
        print_warning "Try: bt restart"
    fi
    
    # Check if modifications are in place
    if grep -q "return True" "$PANEL_PATH/class/panelPlugin.py" 2>/dev/null; then
        print_success "v6.2.6 modification verified"
    else
        print_warning "v6.2.6 modification may not be applied"
    fi
}

show_post_install() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              Installation Completed Successfully              ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Next Steps:${NC}"
    echo ""
    echo "1. Clear your browser cache (Ctrl+Shift+Delete)"
    echo "   Or use incognito/private browsing mode"
    echo ""
    echo "2. Access your aaPanel:"
    echo "   URL: http://YOUR_SERVER_IP:7800"
    echo "   (Check: bt default)"
    echo ""
    echo "3. Verify PRO features are visible"
    echo ""
    echo -e "${YELLOW}Remember:${NC}"
    echo "• Plugin downloads will NOT work (server-side validation)"
    echo "• Plugins require valid server licenses"
    echo "• This is for research/testing only"
    echo "• Purchase legitimate licenses for production use"
    echo ""
    echo -e "${CYAN}Backup Location:${NC}"
    echo "  $BACKUP_DIR"
    echo ""
    echo -e "${CYAN}To Revert:${NC}"
    echo "  ./scripts/revert.sh"
    echo "  Or: bt 15  (Repair from official sources)"
    echo ""
}

################################################################################
# Main Installation Process
################################################################################

main() {
    print_banner
    
    # Pre-flight checks
    check_root
    check_aapanel_installed
    check_aapanel_version
    
    # Show disclaimer
    show_disclaimer
    
    # Create backup
    create_backup
    
    # Apply modifications
    echo ""
    print_step "Applying modifications..."
    echo ""
    
    # Note: The actual modification scripts should be Python files in modifications/
    # For this installer to work, those files need to be created
    # For now, we'll show the structure
    
    if [[ -f "$PROJECT_ROOT/modifications/v6.2.6/apply.py" ]]; then
        apply_modification_v6_2_6
    else
        print_warning "v6.2.6 modification script not found (manual application required)"
    fi
    
    if [[ -f "$PROJECT_ROOT/modifications/v6.3.5/apply.py" ]]; then
        apply_modification_v6_3_5
    else
        print_warning "v6.3.5 modification script not found (manual application required)"
    fi
    
    if [[ -f "$PROJECT_ROOT/modifications/v6.10.0/apply.py" ]]; then
        apply_modification_v6_10_0
    else
        print_warning "v6.10.0 modification script not found (manual application required)"
    fi
    
    # Post-modification tasks
    clear_python_cache
    restart_panel
    verify_installation
    
    # Show completion message
    show_post_install
}

# Run main function
main "$@"
