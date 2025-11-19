#!/usr/bin/env python3
"""
Modification v6.2.6 - PRO Feature Gate Bypass
schema.cx

    "There's a crack in everything,
     That's how the light gets in."
     - Leonard Cohen (probably talking about software)

File Modified: /www/server/panel/class/panelPlugin.py
Purpose: Bypass PRO feature gate checks
Risk: Medium (or high, depending on your legal department)
"""

import sys
import re
import shutil
from datetime import datetime

def create_backup(file_path):
    """Create a timestamped backup of the file
    
    Because Murphy's Law states: Anything that can go wrong, will go wrong.
    And we're not testing Murphy today.
    """
    backup_path = f"{file_path}.backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    shutil.copy2(file_path, backup_path)
    print(f"[✓] Backup created: {backup_path}")
    return backup_path  # Your insurance policy against career-ending mistakes

def apply_modification(file_path):
    """Apply the PRO bypass modification"""
    
    print(f"[*] Reading {file_path}")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"[✗] File not found: {file_path}")
        return False
    
    # Check if already patched
    if 'PATCHED v6.2.6' in content:
        print("[!] File appears to be already patched")
        return False
    
    # Find the get_pro_user_info function or similar PRO check
    # This is a simplified example - adjust based on actual aaPanel code
    
    # Pattern 1: Look for PRO user validation function
    pattern1 = r'(def\s+get_pro_user_info\s*\([^)]*\):.*?)(return\s+[^}]+)'
    
    if re.search(pattern1, content, re.DOTALL):
        # Replace the return statement to always return True/PRO status
        modified_content = re.sub(
            r'(def\s+get_pro_user_info\s*\([^)]*\):.*?return\s+)([^}]+)',
            r'\1True  # PATCHED v6.2.6: Always return PRO status',
            content,
            flags=re.DOTALL
        )
        
        print("[✓] Applied PRO bypass modification")
    else:
        # Alternative pattern for different aaPanel versions
        # Look for license validation
        pattern2 = r'(if\s+not\s+self\.is_pro_user\(\):)'
        
        if re.search(pattern2, content):
            modified_content = re.sub(
                pattern2,
                r'if not True:  # PATCHED v6.2.6: Bypass PRO check',
                content
            )
            print("[✓] Applied alternative PRO bypass modification")
        else:
            print("[!] Could not find suitable modification point")
            print("[!] Manual modification may be required")
            return False
    
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

def verify_syntax(file_path):
    """Verify Python syntax is still valid"""
    import py_compile
    
    try:
        py_compile.compile(file_path, doraise=True)
        print("[✓] Python syntax verification passed")
        return True
    except py_compile.PyCompileError as e:
        print(f"[✗] Syntax error in modified file: {e}")
        return False

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 apply.py /path/to/panelPlugin.py")
        sys.exit(1)
    
    file_path = sys.argv[1]
    
    print("=" * 70)
    print("v6.2.6 - PRO Feature Gate Bypass")
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
    
    # Verify syntax
    if not verify_syntax(file_path):
        print("\n[✗] Syntax verification failed")
        print(f"[*] Restoring from backup: {backup_path}")
        shutil.copy2(backup_path, file_path)
        sys.exit(1)
    
    print()
    print("[✓] v6.2.6 modification completed successfully")
    print(f"[*] Backup available at: {backup_path}")

if __name__ == '__main__':
    main()
