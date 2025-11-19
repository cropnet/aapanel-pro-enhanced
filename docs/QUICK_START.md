# Quick Start Guide

**aaPanel PRO Enhanced** - Get started in 5 minutes

---

## ⚡ For the Impatient

```bash
# On your aaPanel server (Ubuntu/Debian):
cd /root
git clone https://github.com/schema-cx/aapanel-pro-enhanced.git
cd aapanel-pro-enhanced
./scripts/install.sh
```

**That's it.** Clear your browser cache and reload aaPanel.

---

## 📋 Before You Start

### ✅ You Need
- aaPanel 6.8+ already installed
- Root SSH access to your server
- 5 minutes of your time

### ⚠️ You Should Know
- This is for **research and testing only**
- Plugin downloads **will NOT work** (server-side validation)
- Auto-updates **will be blocked** (by design)
- You accept **all risks**

---

## 🚀 Installation (Step by Step)

### Step 1: Connect to Your Server

```bash
ssh root@YOUR_SERVER_IP
```

### Step 2: Download the Repository

```bash
cd /root
git clone https://github.com/schema-cx/aapanel-pro-enhanced.git
cd aapanel-pro-enhanced
```

### Step 3: Review What You're Installing

```bash
# Read the README (recommended)
cat README.md | less

# Check the modifications
ls -la modifications/

# Review the installer
cat scripts/install.sh
```

### Step 4: Run the Installer

```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

**The installer will:**
1. Check if you're running as root ✓
2. Verify aaPanel is installed ✓
3. Show you the disclaimer (you must type "yes")
4. Create automatic backups ✓
5. Apply three modifications ✓
6. Clear Python cache ✓
7. Restart aaPanel ✓

### Step 5: Clear Browser Cache

**In your browser:**
- Chrome/Edge: `Ctrl+Shift+Delete`
- Firefox: `Ctrl+Shift+Delete`
- Safari: `Cmd+Option+E`

**Or use incognito mode**

### Step 6: Access aaPanel

```bash
# Get your panel URL and credentials
bt default
```

Navigate to `http://YOUR_SERVER_IP:7800` and login.

**PRO features should now be visible! 🎉**

---

## 🎯 What Works

- ✅ PRO feature UI access
- ✅ File manager advanced features
- ✅ Cron job management
- ✅ System monitoring tools
- ✅ Database management
- ✅ SSL certificate tools
- ✅ Security dashboard

## ❌ What Doesn't Work

- ❌ **Plugin downloads** (requires server licenses)
- ❌ Auto-updates (blocked by DNS modification)
- ❌ Plugin repository refresh

---

## 🔄 To Revert

If you want to undo everything:

```bash
cd /root/aapanel-pro-enhanced
./scripts/revert.sh
```

Or use aaPanel's built-in repair:

```bash
bt 15  # Repair from official sources
```

---

## 🐛 Troubleshooting

### PRO Features Not Showing?

```bash
# Clear Python cache
find /www/server/panel -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
bt restart

# Clear browser cache
# Ctrl+Shift+Delete
```

### Panel Won't Start?

```bash
# Check status
bt status

# Check logs
tail -f /www/server/panel/logs/error.log

# Revert if needed
./scripts/revert.sh
```

### Plugins Still Won't Download?

**This is expected.** Plugins require server-side license validation. You need a legitimate aaPanel PRO license for plugin downloads.

---

## 📚 Learn More

- [README.md](../README.md) - Full project documentation
- [TECHNICAL_DETAILS.md](TECHNICAL_DETAILS.md) - How it works
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Detailed problem solving
- [CHANGELOG.md](../CHANGELOG.md) - Research history

---

## ⚖️ Important Reminder

This is for **educational and research purposes only**.

For production environments:
👉 **Purchase a legitimate aaPanel PRO license**: https://www.aapanel.com/pricing.html

---

## 🤝 Need Help?

1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Search existing [GitHub Issues](https://github.com/schema-cx/aapanel-pro-enhanced/issues)
3. Open a new issue with details

---

*Quick, simple, transparent*
