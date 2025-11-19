#!/usr/bin/env python3
"""
Modification v6.10.0 - DNS Blocking Research
schema.cx

    "To DNS or not to DNS, that is the question.
     Whether 'tis nobler to resolve the queries
     Or to block them at the socket layer."
     - Shakespeare, if he was a network admin

File Modified: /www/server/panel/class/public.py
Purpose: Block outbound connections to aaPanel licensing servers
Risk: High (nuclear option - use responsibly)
"""

import sys
import shutil
from datetime import datetime
import re

def create_backup(file_path):
    """Create a timestamped backup of the file
    
    WARNING: Not backing up is like skydiving without a parachute.
    It might work once, but the odds are not in your favor.
    """
    backup_path = f"{file_path}.backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    shutil.copy2(file_path, backup_path)  # Because we learn from other people's mistakes
    print(f"[✓] Backup created: {backup_path}")
    return backup_path

def apply_modification(file_path):
    """Apply DNS blocking modification"""
    
    print(f"[*] Reading {file_path}")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"[✗] File not found: {file_path}")
        return False
    
    # Check if already patched
    if 'PATCHED v6.10.0' in content or 'DNS BLOCKING' in content:
        print("[!] File appears to be already patched")
        return False
    
    # DNS blocking code to inject
    dns_blocking_code = '''
# PATCHED v6.10.0: DNS Blocking for aaPanel licensing servers (schema.cx)
import socket
_original_getaddrinfo = socket.getaddrinfo

def _patched_getaddrinfo(host, port, family=0, type=0, proto=0, flags=0):
    """Block connections to aaPanel licensing servers"""
    blocked_domains = [
        'www.bt.cn',
        'api.bt.cn',
        'download.bt.cn',
        'node.aapanel.com',
        'www.aapanel.com',
    ]
    
    # Check if host is in blocked list
    if any(blocked in str(host).lower() for blocked in blocked_domains):
        raise socket.gaierror(f"[Errno -2] Name or service not known (blocked by v6.10.0)")
    
    return _original_getaddrinfo(host, port, family, type, proto, flags)

socket.getaddrinfo = _patched_getaddrinfo
# End v6.10.0 DNS blocking patch
'''
    
    # Try to insert at the beginning of the file, after imports
    lines = content.split('\n')
    
    # Find the last import statement
    insert_position = 0
    for i, line in enumerate(lines):
        if line.strip().startswith('import ') or line.strip().startswith('from '):
            insert_position = i + 1
    
    # If no imports found, insert at the beginning
    if insert_position == 0:
        modified_content = dns_blocking_code + '\n' + content
        print("[✓] Applied DNS blocking (at file start)")
    else:
        lines.insert(insert_position, dns_blocking_code)
        modified_content = '\n'.join(lines)
        print(f"[✓] Applied DNS blocking (after line {insert_position})")
    
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
        print("Usage: python3 apply.py /path/to/public.py")
        sys.exit(1)
    
    file_path = sys.argv[1]
    
    print("=" * 70)
    print("v6.10.0 - DNS Blocking Research")
    print("=" * 70)
    print()
    print("[!] WARNING: This will block aaPanel from contacting licensing servers")
    print("[!] Panel will NOT be able to auto-update or validate licenses")
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
    print("[✓] v6.10.0 modification completed successfully")
    print(f"[*] Backup available at: {backup_path}")
    print()
    print("[!] Side effects:")
    print("    - Panel cannot auto-update")
    print("    - Plugin repository cannot refresh")
    print("    - News/announcements won't load")

if __name__ == '__main__':
    main()
