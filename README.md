# aaPanel PRO Enhanced Research Project

```
 █████╗  █████╗ ██████╗  █████╗ ███╗   ██╗███████╗██╗     
██╔══██╗██╔══██╗██╔══██╗██╔══██╗████╗  ██║██╔════╝██║     
███████║███████║██████╔╝███████║██╔██╗ ██║█████╗  ██║     
██╔══██║██╔══██║██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝  ██║     
██║  ██║██║  ██║██║     ██║  ██║██║ ╚████║███████╗███████╗
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝
        PRO Research Edition - Schema Network Organisation
```

> *"Control is an illusion. But understanding the system? That's power."*

```
// Dear Future Me,
// If you're reading this and wondering why we did this,
// remember: We don't break things. We understand them.
// We don't exploit systems. We illuminate them.
// We don't hack for chaos. We code for knowledge.
// 
// Also, you're welcome for the documentation.
// - Past You (who actually remembered to document for once)
```

## 🎭 Project Origin

Hello, friend. Welcome to the personal research initiative.

This project emerged from a simple question: *What if we could understand the mechanisms that control software licensing?* Not to exploit them, but to study them. To learn. To teach.

We're not anarchists. We're researchers. System analysts. We believe in transparency, in understanding how things work beneath the surface. The aaPanel control panel uses licensing mechanisms to restrict features. We've documented those mechanisms. We've made them transparent.

---

## ⚠️ CRITICAL DISCLAIMER - READ THIS FIRST

```
┌─────────────────────────────────────────────────────────────┐
│  EDUCATIONAL AND SECURITY RESEARCH PURPOSES ONLY            │
│  ─────────────────────────────────────────────────────      │
│  This project is NOT a crack. It's NOT a bypass tool.      │
│  It's a RESEARCH PROJECT to understand licensing systems.   │
│                                                             │
│  ✗ DO NOT use this in production environments              │
│  ✗ DO NOT use this to avoid paying for software            │
│  ✓ DO use this to learn how licensing works                │
│  ✓ DO purchase legitimate licenses for production use      │
│                                                             │
│  We are NOT affiliated with aaPanel or BT.cn                │
│  We do NOT provide support, warranties, or guarantees       │
│  You accept ALL risks when using this research              │
└─────────────────────────────────────────────────────────────┘
```

### Legal & Ethical Notice

- ✅ **Intended Use**: Educational research, security testing, learning environments
- ✅ **Recommended**: Purchase [official aaPanel PRO licenses](https://www.aapanel.com/pricing.html) for production
- ❌ **Not Intended**: Commercial use, production deployments, license circumvention
- ⚖️ **Your Responsibility**: Ensure compliance with local laws and aaPanel's terms of service

---

## 🔍 What This Research Reveals

We've identified and documented three key control mechanisms in aaPanel's licensing system:

### Version 6.2.6 - PRO Feature Gate Bypass
**File Modified**: `/www/server/panel/class/panelPlugin.py`

The licensing check happens in a simple boolean function. When the system asks "Is this user a PRO subscriber?", the original code checks with aaPanel's servers. Our modification? It just says "Yes."

```python
# Original: Checks remote API
def get_plugin_list(self):
    if not self.is_pro_user():  # Calls API
        return restricted_features
        
# Modified: Always returns True
def get_plugin_list(self):
    if not True:  # Always passes
        return restricted_features
```

**Result**: PRO features become accessible in the UI. But here's the catch - plugin downloads still fail because aaPanel's API validates on the server side. The gate opens, but there's another gate behind it.

### Version 6.3.5 - UI Pricing Column Removal
**File Modified**: `/www/server/panel/BTPanel/static/app_store/index.html`

The interface constantly reminds you to upgrade by showing pricing columns. We remove those visual elements. It's cosmetic, but it's part of the user experience design pattern that drives conversions.

```html
<!-- Hidden pricing columns -->
<style>.price-column { display: none !important; }</style>
```

**Result**: Cleaner interface, less sales pressure. The functionality doesn't change - it just changes how the system communicates with you.

### Version 6.10.0 - DNS Blocking Analysis
**File Modified**: `/www/server/panel/class/public.py`

The system performs DNS-level blocking to prevent communication with aaPanel's licensing servers. This is the most aggressive control mechanism.

```python
# Blocks outbound connections to licensing endpoints
BLOCKED_DOMAINS = [
    'www.bt.cn',
    'api.bt.cn', 
    'download.bt.cn'
]
```

**Result**: The panel can't phone home. It can't validate. It can't update the license status. Local operation only.

---

## 🎯 What Works (and What Doesn't)

### ✅ Features Unlocked
- PRO feature UI access
- File manager advanced features
- Cron job management (PRO features)
- System monitoring tools
- Database management tools
- SSL certificate management
- Web server configuration tools
- Security monitoring dashboard
- Log analysis tools

### ❌ What Still Doesn't Work
**Plugin Downloads**: aaPanel's plugin distribution uses server-side license validation. When you try to download a plugin, their API checks if your license key is valid. Since we don't have a valid key, downloads fail.

```
Request: "Give me Nginx 1.22 plugin"
API: "Show me your license key"
You: "..."
API: "Access denied"
```

**The plugins require server licenses** - individual validation on aaPanel's infrastructure. This is a server-side control that can't be bypassed with client-side modifications.

### 🔐 Current Status
- **Version**: 6.15.0
- **Tested On**: Ubuntu 20.04 LTS, Debian 11
- **aaPanel Version**: 6.8.x - 6.15.x
- **Stability**: Production-stable (core modifications only)

---

## 📋 Prerequisites

Before you begin this research, ensure you have:

```bash
# Required
✓ Fresh aaPanel installation (6.8.x or higher)
✓ Root SSH access to your server
✓ Basic understanding of Linux system administration
✓ Python 3.7+ (comes with aaPanel)
✓ Backup strategy (CRITICAL)

# Recommended
✓ Snapshot/backup of your entire system
✓ Non-production test environment
✓ Understanding of the risks involved
```

### System Requirements
- **OS**: Ubuntu 18.04+, Debian 9+, CentOS 7+
- **RAM**: 1GB minimum (2GB+ recommended)
- **Disk**: 10GB free space for backups
- **Access**: Root/sudo privileges

---

## 🚀 Installation Instructions

### Step 1: Backup Everything

```bash
# Create backup directory
mkdir -p /root/aapanel_backups/$(date +%Y%m%d)

# Backup aaPanel files
cp -r /www/server/panel/class /root/aapanel_backups/$(date +%Y%m%d)/
cp -r /www/server/panel/BTPanel /root/aapanel_backups/$(date +%Y%m%d)/

# Backup aaPanel database
bt 14  # Backup panel data

echo "Backup completed: /root/aapanel_backups/$(date +%Y%m%d)"
```

### Step 2: Download This Repository

```bash
cd /root
git clone https://github.com/schema-cx/aapanel-pro-enhanced.git
cd aapanel-pro-enhanced
```

### Step 3: Review the Modifications

```bash
# Read what each modification does
cat docs/TECHNICAL_DETAILS.md

# Check the modification scripts
ls -la modifications/
```

### Step 4: Run the Installer

```bash
# Make the installer executable
chmod +x scripts/install.sh

# Run with safety checks
./scripts/install.sh

# The installer will:
# - Verify aaPanel version compatibility
# - Create automatic backups
# - Apply modifications in correct order
# - Clear Python cache
# - Restart aaPanel services
```

### Step 5: Verify Installation

```bash
# Check aaPanel status
bt status

# Access panel
# Navigate to: http://YOUR_SERVER_IP:7800
# Login and verify PRO features are visible
```

### Step 6: Clear Browser Cache

```bash
# Important: Clear your browser cache
# Or use incognito/private browsing mode
# aaPanel heavily caches the interface
```

---

## 🔧 Technical Deep Dive

### Architecture Analysis

aaPanel uses a three-tier licensing architecture:

```
┌─────────────────┐
│   Client UI     │  ← We modify this (HTML/CSS)
├─────────────────┤
│   Python Core   │  ← We modify this (panelPlugin.py)
├─────────────────┤
│   API Server    │  ← We can't modify this (server-side)
└─────────────────┘
```

**Tier 1 - UI Layer**: Controls what users see. Easy to modify, but cosmetic only.

**Tier 2 - Application Layer**: Controls feature gating. We modify the boolean checks here.

**Tier 3 - API Layer**: Controls actual plugin distribution. Server-side validation. Unmodifiable.

### Files Modified

| File | Purpose | Risk Level | Revertible |
|------|---------|-----------|------------|
| `/www/server/panel/class/panelPlugin.py` | PRO feature gates | Medium | Yes |
| `/www/server/panel/BTPanel/static/app_store/index.html` | UI pricing display | Low | Yes |
| `/www/server/panel/class/public.py` | DNS blocking | High | Yes |

### Python Cache Requirements

**Critical**: aaPanel uses Python bytecode caching. After modifications:

```bash
# Clear Python cache
find /www/server/panel -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
find /www/server/panel -type f -name "*.pyc" -delete

# Restart aaPanel
bt restart
```

Without cache clearing, the old code continues to execute.

---

## 🔄 How to Revert

If you want to return to the original state:

```bash
# Method 1: Use our revert script
./scripts/revert.sh

# Method 2: Manual restoration
cp -r /root/aapanel_backups/YYYYMMDD/class/* /www/server/panel/class/
cp -r /root/aapanel_backups/YYYYMMDD/BTPanel/* /www/server/panel/BTPanel/
find /www/server/panel -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
bt restart

# Method 3: Reinstall aaPanel (nuclear option)
bt 15  # Repair panel from official sources
```

---

## 🐛 Troubleshooting

### Problem: PRO features still not showing

```bash
# Solution 1: Clear Python cache
find /www/server/panel -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
bt restart

# Solution 2: Clear browser cache
# Use Ctrl+Shift+Delete or incognito mode

# Solution 3: Verify modifications applied
grep -n "return True" /www/server/panel/class/panelPlugin.py
```

### Problem: Panel shows errors after modification

```bash
# Check panel logs
tail -f /www/server/panel/logs/error.log

# Verify Python syntax
python3 -m py_compile /www/server/panel/class/panelPlugin.py

# If corrupted, restore from backup
./scripts/revert.sh
```

### Problem: Plugins still won't download

**Expected behavior**. Plugin downloads require server-side license validation. This cannot be bypassed with client-side modifications. The plugins require valid server licenses.

### Problem: aaPanel auto-updates and removes modifications

```bash
# Disable auto-updates
bt 16  # Turn off automatic updates

# Re-apply modifications after manual updates
./scripts/install.sh
```

---

## 🤝 Contributing

This is a research project. If you've discovered new licensing mechanisms, improved stability, or found better documentation approaches:

```bash
# Fork the repository
# Create a feature branch
# Document your research thoroughly
# Submit a pull request
```

**Guidelines**:
- All contributions must be for educational purposes
- Document the "why" and "how", not just the "what"
- Include rollback procedures for any modifications
- Test thoroughly before submitting
- Respect the ethical guidelines above

---

## 📖 Additional Resources

- [TECHNICAL_DETAILS.md](docs/TECHNICAL_DETAILS.md) - Deep dive into each modification
- [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Comprehensive problem-solving guide
- [CHANGELOG.md](CHANGELOG.md) - Complete version history
- [Official aaPanel Docs](https://forum.aapanel.com/)
- [aaPanel Pricing](https://www.aapanel.com/pricing.html) - Support the developers!

---

## 📜 License

This research project is released under the MIT License. See [LICENSE](LICENSE) for details.

**Important**: This license applies to our research documentation and scripts. It does NOT grant any rights to aaPanel's proprietary software. aaPanel remains the property of BT.cn, subject to their terms of service.

---

## 🙏 Credits & Acknowledgments

- **aaPanel Team (BT.cn)**: For creating an excellent control panel (please support them by purchasing licenses)
- **Schema Network**: Research, documentation, and maintenance
- **Security Research Community**: For teaching us to understand systems, not just use them
- **You**: For reading the disclaimer and understanding the ethical implications

---

## 🎯 Final Words

Hello, friend.

We built this not to destroy value, but to understand it. Not to steal, but to learn. The best way to understand security is to understand the systems that implement it.

If this research helped you learn something, consider:
1. **Purchase a legitimate license** for production use
2. **Contribute to the research** with your findings
3. **Share knowledge** responsibly and ethically

Remember: Control is an illusion. But understanding the system? That's power.

```
Stay curious. Stay ethical. Stay informed.

- schema.cx
```

---

## 🎭 For Developers & Curious Minds

*If you're exploring the codebase and enjoy developer humor, check out:*
- **`.underground`** - Poetry, mantras, and the Developer's Creed  
- **`backups/.DEV_NOTES`** - The unfiltered story of this project  
- **`docs/UNDERGROUND_GUIDE.md`** - Complete map to all Easter eggs  

*"The code is temporary. The lessons and laughter are forever."*

---

**schema.cx organisation**  
*Understanding systems to improve security*

Made with ☕, 🐍, and questionable life choices at 3 AM.


