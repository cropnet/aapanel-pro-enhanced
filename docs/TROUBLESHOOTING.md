# Troubleshooting Guide

**aaPanel PRO Enhanced Research Project**  

---

## Table of Contents

1. [Pre-Installation Issues](#pre-installation-issues)
2. [Installation Failures](#installation-failures)
3. [Post-Installation Problems](#post-installation-problems)
4. [Feature-Specific Issues](#feature-specific-issues)
5. [Recovery Procedures](#recovery-procedures)
6. [Diagnostic Commands](#diagnostic-commands)

---

## Pre-Installation Issues

### Issue: "aaPanel not found"

**Symptom**: Installer reports aaPanel is not installed

**Diagnosis**:
```bash
ls -la /www/server/panel
```

**Solution**:
```bash
# If directory doesn't exist, install aaPanel first
wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh
bash install.sh aapanel
```

**Verification**:
```bash
bt version
```

---

### Issue: "Not running as root"

**Symptom**: `[✗] This script must be run as root`

**Diagnosis**:
```bash
whoami  # Should show "root"
id -u   # Should show "0"
```

**Solution**:
```bash
# Switch to root
sudo su -

# Or run with sudo
sudo ./scripts/install.sh
```

---

### Issue: "Cannot detect aaPanel version"

**Symptom**: Version detection fails during installation

**Diagnosis**:
```bash
bt version
bt 1  # Check panel status
```

**Solution**:
- This is usually safe to ignore
- Press 'y' to continue when prompted
- If panel is working, version is likely compatible

---

## Installation Failures

### Issue: "Modification script not found"

**Symptom**: `v6.2.6 modification script not found (manual application required)`

**Cause**: Git clone incomplete or files missing

**Solution**:
```bash
# Re-clone the repository
cd /root
rm -rf aapanel-pro-enhanced
git clone https://github.com/schema-cx/aapanel-pro-enhanced.git
cd aapanel-pro-enhanced

# Verify all files exist
ls -la modifications/v6.2.6/apply.py
ls -la modifications/v6.3.5/apply.py
ls -la modifications/v6.10.0/apply.py

# Try installation again
./scripts/install.sh
```

---

### Issue: "Python syntax error"

**Symptom**: `[✗] Syntax error in modified file`

**Cause**: Modification script incompatible with your aaPanel version

**Solution**:
```bash
# Automatic restoration from backup
# (installer should do this automatically)

# Manual restoration if needed
BACKUP=$(ls -t /www/server/panel/class/panelPlugin.py.backup_* | head -1)
cp "$BACKUP" /www/server/panel/class/panelPlugin.py

# Clear cache and restart
find /www/server/panel -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
bt restart
```

**Alternative**: Report the issue with your aaPanel version number

---

### Issue: "Panel won't restart after modification"

**Symptom**: `bt restart` fails or panel doesn't come back online

**Diagnosis**:
```bash
# Check panel status
bt status

# Check error logs
tail -n 50 /www/server/panel/logs/error.log

# Check system logs
journalctl -u bt -n 50
```

**Solution**:
```bash
# Method 1: Use revert script
./scripts/revert.sh

# Method 2: Repair from official sources
bt 15

# Method 3: Manual restart
systemctl restart bt
# or
/etc/init.d/bt restart
```

---

## Post-Installation Problems

### Issue: "PRO features still not showing"

**Symptom**: After installation, UI still shows free version

**Diagnosis**:
```bash
# Check if modification applied
grep -n "PATCHED v6.2.6" /www/server/panel/class/panelPlugin.py
grep -n "return True" /www/server/panel/class/panelPlugin.py

# Check Python cache
find /www/server/panel/class -name "*.pyc" -o -name "__pycache__"
```

**Solution 1 - Clear Python Cache**:
```bash
# Delete all Python cache files
find /www/server/panel -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
find /www/server/panel -type f -name "*.pyc" -delete

# Restart panel
bt restart

# Wait 10 seconds
sleep 10

# Verify panel is running
bt status
```

**Solution 2 - Clear Browser Cache**:
```bash
# In your browser:
# Chrome/Edge: Ctrl+Shift+Delete
# Firefox: Ctrl+Shift+Delete
# Safari: Cmd+Option+E

# Or use incognito/private mode
```

**Solution 3 - Hard Refresh**:
```
# On the aaPanel page:
Ctrl+F5  (Windows/Linux)
Cmd+Shift+R  (Mac)
```

---

### Issue: "Some features show, others don't"

**Symptom**: Inconsistent PRO feature visibility

**Cause**: Partial cache clear or mixed versions

**Solution**:
```bash
# Nuclear cache clear
cd /www/server/panel

# Clear all caches
rm -rf class/__pycache__
rm -rf class/*/__pycache__
rm -rf BTPanel/__pycache__
find . -type f -name "*.pyc" -delete

# Clear user session
rm -rf data/session/*

# Restart panel
bt restart

# In browser: Full cache clear + cookies
```

---

### Issue: "Panel is slow after modification"

**Symptom**: aaPanel UI loads slowly or is unresponsive

**Diagnosis**:
```bash
# Check CPU usage
top -bn1 | grep python

# Check memory
free -h

# Check error logs
tail -f /www/server/panel/logs/error.log
```

**Cause**: Usually DNS blocking (v6.10.0) causing timeout errors

**Solution**:
```bash
# Check if DNS blocking is the issue
tail /www/server/panel/logs/error.log | grep "Name or service not known"

# If you see many DNS errors, this is expected
# The panel will eventually timeout and continue
# Performance should stabilize after a few minutes

# If it doesn't improve, revert v6.10.0 only
cp /www/server/panel/class/public.py.backup_* /www/server/panel/class/public.py
bt restart
```

---

## Feature-Specific Issues

### Issue: "Plugins still won't download"

**Symptom**: Click "Install" on a plugin → Error or "License required"

**Status**: ⚠️ **THIS IS EXPECTED BEHAVIOR**

**Explanation**:
```
Our modifications only affect CLIENT-SIDE checks.
Plugin downloads require SERVER-SIDE license validation.
This cannot be bypassed with client modifications.
```

**What You Can Do**:
1. Use manually downloaded plugins (if available elsewhere)
2. Purchase a legitimate aaPanel PRO license
3. Use alternative software

**What You Cannot Do**:
- Bypass API-level plugin validation
- Download PRO plugins without a valid license
- Generate valid license keys

---

### Issue: "Pricing columns reappear"

**Symptom**: After some time, pricing columns show again

**Cause**: aaPanel updated the UI files

**Solution**:
```bash
# Re-apply v6.3.5 modification
cd /root/aapanel-pro-enhanced
python3 modifications/v6.3.5/apply.py /www/server/panel/BTPanel/static/app_store/index.html

# Clear browser cache
# Ctrl+Shift+Delete
```

---

### Issue: "Panel auto-updated and broke modifications"

**Symptom**: aaPanel updated itself and removed all modifications

**Cause**: Auto-updates overwrite modified files

**Prevention**:
```bash
# Disable auto-updates
bt 16  # Then select "off"
```

**Solution (After Update)**:
```bash
# Re-run installer
cd /root/aapanel-pro-enhanced
./scripts/install.sh

# Or apply modifications manually
python3 modifications/v6.2.6/apply.py /www/server/panel/class/panelPlugin.py
python3 modifications/v6.3.5/apply.py /www/server/panel/BTPanel/static/app_store/index.html
python3 modifications/v6.10.0/apply.py /www/server/panel/class/public.py

# Clear cache and restart
find /www/server/panel -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
bt restart
```

---

### Issue: "DNS blocking broke internet connectivity"

**Symptom**: After v6.10.0, panel cannot access anything

**Diagnosis**:
```bash
# From inside the panel's Python environment
/www/server/panel/pyenv/bin/python3 << 'EOF'
import socket
try:
    socket.getaddrinfo('google.com', 80)
    print("✓ DNS works for Google")
except Exception as e:
    print(f"✗ DNS failed: {e}")
    
try:
    socket.getaddrinfo('api.bt.cn', 443)
    print("✓ DNS works for BT.cn (SHOULD BE BLOCKED)")
except Exception as e:
    print(f"✓ DNS blocked for BT.cn: {e}")
EOF
```

**Solution**:
If general internet is broken (not just BT.cn):

```bash
# Revert v6.10.0
cp /www/server/panel/class/public.py.backup_* /www/server/panel/class/public.py
rm -rf /www/server/panel/class/__pycache__
bt restart
```

---

## Recovery Procedures

### Full Revert to Original State

```bash
# Method 1: Use revert script
cd /root/aapanel-pro-enhanced
./scripts/revert.sh

# Method 2: Manual restoration
BACKUP_DATE="20241119_143022"  # Replace with your backup
cp -r /root/aapanel_backups/$BACKUP_DATE/class/* /www/server/panel/class/
cp -r /root/aapanel_backups/$BACKUP_DATE/BTPanel/* /www/server/panel/BTPanel/
find /www/server/panel -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
bt restart

# Method 3: Official repair
bt 15  # Repair panel from official sources
```

---

### Selective Revert (One Modification)

**Revert v6.2.6 only**:
```bash
cp /www/server/panel/class/panelPlugin.py.backup_* /www/server/panel/class/panelPlugin.py
rm -rf /www/server/panel/class/__pycache__
bt restart
```

**Revert v6.3.5 only**:
```bash
cp /www/server/panel/BTPanel/static/app_store/index.html.backup_* \
   /www/server/panel/BTPanel/static/app_store/index.html
# No restart needed (just clear browser cache)
```

**Revert v6.10.0 only**:
```bash
cp /www/server/panel/class/public.py.backup_* /www/server/panel/class/public.py
rm -rf /www/server/panel/class/__pycache__
bt restart
```

---

### Emergency Recovery

**If panel is completely broken**:

```bash
# Stop panel
bt stop

# Full backup of current state
cp -r /www/server/panel /root/panel_broken_backup

# Restore from earliest backup
OLDEST_BACKUP=$(ls -t /root/aapanel_backups/ | tail -1)
cp -r /root/aapanel_backups/$OLDEST_BACKUP/class/* /www/server/panel/class/
cp -r /root/aapanel_backups/$OLDEST_BACKUP/BTPanel/* /www/server/panel/BTPanel/

# Clear all caches
find /www/server/panel -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
find /www/server/panel -type f -name "*.pyc" -delete

# Start panel
bt start

# If still broken, repair from official
bt 15
```

---

## Diagnostic Commands

### Quick Health Check

```bash
#!/bin/bash
echo "=== aaPanel Health Check ==="
echo ""

# Panel status
echo "Panel Status:"
bt status
echo ""

# Version
echo "Panel Version:"
bt version
echo ""

# Check modifications
echo "Modifications Applied:"
grep -q "PATCHED v6.2.6" /www/server/panel/class/panelPlugin.py && echo "✓ v6.2.6" || echo "✗ v6.2.6"
grep -q "PATCHED v6.3.5" /www/server/panel/BTPanel/static/app_store/index.html && echo "✓ v6.3.5" || echo "✗ v6.3.5"
grep -q "PATCHED v6.10.0" /www/server/panel/class/public.py && echo "✓ v6.10.0" || echo "✗ v6.10.0"
echo ""

# Check for Python errors
echo "Recent Errors:"
tail -n 10 /www/server/panel/logs/error.log | grep -i error || echo "(No errors)"
echo ""

# Check cache
echo "Python Cache Files:"
find /www/server/panel/class -name "*.pyc" -o -name "__pycache__" | wc -l
echo ""

echo "=== End Health Check ==="
```

### Performance Check

```bash
#!/bin/bash
echo "=== Performance Diagnostic ==="

# CPU
echo "CPU Usage:"
top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}'

# Memory
echo ""
echo "Memory Usage:"
free -h | grep "Mem:"

# Disk
echo ""
echo "Disk Usage:"
df -h | grep "/www"

# Panel processes
echo ""
echo "Panel Processes:"
ps aux | grep -E "BT-Panel|BT-Task" | grep -v grep

# Network
echo ""
echo "Network Connections:"
netstat -an | grep ":7800" | head -5

echo ""
echo "=== End Performance Check ==="
```

### Log Analysis

```bash
# View recent errors
tail -f /www/server/panel/logs/error.log

# Search for specific errors
grep -i "license" /www/server/panel/logs/error.log
grep -i "plugin" /www/server/panel/logs/error.log
grep -i "pro" /www/server/panel/logs/error.log

# Check access logs
tail -f /www/server/panel/logs/request.log

# System logs
journalctl -u bt -f
```

---

## Getting Help

If you're still stuck:

1. **Check the logs**: `/www/server/panel/logs/error.log`
2. **Try a full revert**: `./scripts/revert.sh`
3. **Repair from official**: `bt 15`
4. **Open an issue**: https://github.com/schema-cx/aapanel-pro-enhanced/issues

Include in your report:
- aaPanel version (`bt version`)
- OS version (`cat /etc/os-release`)
- Error logs (last 50 lines)
- Steps to reproduce

---
 
*Helping you understand and fix system issues*

Last Updated: November 2024
