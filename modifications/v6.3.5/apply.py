#!/usr/bin/env python3
"""
Modification v6.3.5 - UI Pricing Column Removal
schema.cx

    99 little bugs in the code,
    99 little bugs,
    Take one down, patch it around,
    127 little bugs in the code.

File Modified: /www/server/panel/BTPanel/static/app_store/index.html
Purpose: Remove pricing columns and upgrade prompts from UI
Risk: Low (unless your boss finds out)
"""

import sys
import shutil
from datetime import datetime
import re

def create_backup(file_path):
    """Create a timestamped backup of the file
    
    Pro tip: Backups are like parachutes. If you need one and don't have it,
    you'll probably never need one again.
    """
    backup_path = f"{file_path}.backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    shutil.copy2(file_path, backup_path)
    print(f"[✓] Backup created: {backup_path}")
    return backup_path  # Sleep insurance

def apply_modification(file_path):
    """Apply the UI modification to hide pricing columns"""
    
    print(f"[*] Reading {file_path}")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"[✗] File not found: {file_path}")
        return False
    
    # Check if already patched
    if 'PATCHED v6.3.5' in content or 'UI modification' in content:
        print("[!] File appears to be already patched")
        return False
    
    # CSS to hide pricing elements
    css_patch = """
<!-- PATCHED v6.3.5: Hide pricing columns -->
<style>
    /* Hide pricing columns */
    .price-column,
    .pricing-column,
    .app-price,
    .plugin-price,
    .upgrade-prompt,
    .pro-badge,
    .pro-tag,
    .upgrade-notice,
    .buy-now,
    .purchase-button,
    [class*="price"],
    [class*="upgrade"],
    [class*="pro-only"] {
        display: none !important;
        visibility: hidden !important;
    }
    
    /* Hide upgrade banners */
    .upgrade-banner,
    .pro-banner,
    .premium-banner {
        display: none !important;
    }
    
    /* Adjust layout after hiding pricing */
    .app-list-item,
    .plugin-item {
        width: 100% !important;
    }
</style>
<!-- End v6.3.5 patch -->
"""
    
    # Try to insert before </head> tag
    if '</head>' in content:
        modified_content = content.replace('</head>', f'{css_patch}\n</head>')
        print("[✓] Applied UI modification (before </head>)")
    # Try to insert after <head> tag
    elif '<head>' in content:
        modified_content = content.replace('<head>', f'<head>\n{css_patch}')
        print("[✓] Applied UI modification (after <head>)")
    # Try to insert at the beginning if no head tags
    else:
        modified_content = css_patch + '\n' + content
        print("[✓] Applied UI modification (at file start)")
    
    # Write the modified content
    print(f"[*] Writing modifications to {file_path}")
    
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(modified_content)
        print("[✓] Modification applied successfully")
        return True
    except Exception as e:
        print(f"[✗] Error writing file: {e}")
        return False

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 apply.py /path/to/index.html")
        sys.exit(1)
    
    file_path = sys.argv[1]
    
    print("=" * 70)
    print("v6.3.5 - UI Pricing Column Removal")
    print("=" * 70)
    print()
    
    # Create backup
    backup_path = create_backup(file_path)
    
    # Apply modification
    if not apply_modification(file_path):
        print("\n[✗] Modification failed")
        print(f"[*] Restoring from backup: {backup_path}")
        shutil.copy2(backup_path, file_path)
        sys.exit(1)
    
    print()
    print("[✓] v6.3.5 modification completed successfully")
    print(f"[*] Backup available at: {backup_path}")
    print()
    print("[!] Note: Clear browser cache to see changes")

if __name__ == '__main__':
    main()
