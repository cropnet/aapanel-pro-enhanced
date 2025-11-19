# Technical Deep Dive - aaPanel PRO Enhanced

*A comprehensive analysis of aaPanel's licensing architecture*

**Schema - Security Research Division**

```python
# WARNING: Reading this document may cause existential questions about
# software licensing, the nature of ownership in digital space,
# and why we're all here writing Python at 2 AM.
# Proceed with caffeinated caution.
```

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Licensing System Analysis](#licensing-system-analysis)
3. [File Structure](#file-structure)
4. [Modification Technical Details](#modification-technical-details)
5. [Security Implications](#security-implications)
6. [Limitations & Boundaries](#limitations--boundaries)

---

## Architecture Overview

aaPanel uses a three-tier architecture for license validation:

```
┌─────────────────────────────────────────────────┐
│            CLIENT (Browser)                     │
│  - JavaScript UI                                │
│  - HTML templates                               │
│  - CSS styling                                  │
│  └─ Can be modified (Tier 1) ────────────┐     │
└────────────────────────────────────────────┼────┘
                                             │
                                             ▼
┌─────────────────────────────────────────────────┐
│      APPLICATION SERVER (Python/Flask)          │
│  - panelPlugin.py (PRO checks)                  │
│  - public.py (utilities)                        │
│  - ajax.py (API handlers)                       │
│  └─ Can be modified (Tier 2) ────────────┐     │
└────────────────────────────────────────────┼────┘
                                             │
                                             ▼
┌─────────────────────────────────────────────────┐
│         API SERVERS (BT.cn/aapanel.com)         │
│  - License validation                           │
│  - Plugin distribution                          │
│  - Update servers                               │
│  └─ CANNOT be modified (Tier 3) ────────┘      │
└─────────────────────────────────────────────────┘
```

### Tier 1: Client-Side (UI)
- **Files**: HTML, CSS, JavaScript in `/www/server/panel/BTPanel/`
- **Modifiable**: Yes
- **Impact**: Visual only
- **Example**: v6.3.5 - Hiding pricing columns

### Tier 2: Application-Side (Python)
- **Files**: Python modules in `/www/server/panel/class/`
- **Modifiable**: Yes
- **Impact**: Feature gating, logic flow
- **Example**: v6.2.6 - PRO bypass, v6.10.0 - DNS blocking

### Tier 3: Server-Side (Remote API)
- **Files**: None (remote servers)
- **Modifiable**: No
- **Impact**: Plugin downloads, license validation
- **Boundary**: Cannot be bypassed with client modifications

---

## Licensing System Analysis

### How aaPanel Validates PRO Status

1. **Initial Check** (panelPlugin.py)
   ```python
   def get_pro_user_info(self):
       # Makes HTTPS request to api.bt.cn
       response = requests.get('https://api.bt.cn/check_license', 
                               params={'key': self.license_key})
       return response.json()
   ```

2. **Result Caching** (data/userInfo.json)
   ```json
   {
       "pro": false,
       "ltd": -1,
       "endtime": 0
   }
   ```

3. **UI Rendering** (BTPanel templates)
   ```javascript
   if (userInfo.pro) {
       showPROFeatures();
   } else {
       showUpgradePrompt();
   }
   ```

### What We Can Modify

| Component | Location | Modifiable | Impact |
|-----------|----------|------------|--------|
| API request | panelPlugin.py | ✅ Yes | Return fake PRO status |
| Cached data | userInfo.json | ✅ Yes | Temporary (overwritten) |
| UI checks | JavaScript | ✅ Yes | Visual only |
| API response | BT.cn servers | ❌ No | Real validation |

### What We Cannot Modify

- **Server-side plugin validation**
- **License key cryptographic signatures**
- **API endpoint authentication**
- **Plugin file integrity checks**

---

## File Structure

### Critical aaPanel Files

```
/www/server/panel/
├── class/
│   ├── panelPlugin.py          ← v6.2.6 modifies this
│   ├── public.py                ← v6.10.0 modifies this
│   ├── ajax.py
│   ├── common.py
│   └── __pycache__/            ← Must clear after modifications
├── BTPanel/
│   ├── static/
│   │   ├── app_store/
│   │   │   └── index.html      ← v6.3.5 modifies this
│   │   ├── js/
│   │   └── css/
│   └── templates/
├── data/
│   ├── userInfo.json           ← PRO status cache
│   └── plugin.json             ← Plugin list cache
└── logs/
    └── error.log                ← Check for errors here
```

### Backup Strategy

Each modification creates:
```bash
/www/server/panel/class/panelPlugin.py
/www/server/panel/class/panelPlugin.py.backup_20241119_143022
```

Our installer also creates:
```bash
/root/aapanel_backups/20241119_143022/
├── class/
├── BTPanel/
└── MANIFEST.txt
```

---

## Modification Technical Details

### v6.2.6 - PRO Feature Gate Bypass

**Objective**: Make the application believe the user has PRO status

**Method**: Function return value manipulation

**Original Flow**:
```python
def is_pro_user(self):
    try:
        api_result = self.check_api_license()
        return api_result.get('pro', False)
    except:
        return False
```

**Modified Flow**:
```python
def is_pro_user(self):
    return True  # Always PRO
```

**Impact**:
- ✅ UI shows PRO features
- ✅ Feature gates pass
- ❌ Plugin downloads still fail (API-side check)

**Why It Works**:
- Boolean logic is simple to override
- No cryptographic validation at this tier
- Application trusts its own state

**Why It Fails for Plugins**:
```
[Client] Request plugin X
    ↓
[App] Check is_pro_user() → True ✓
    ↓
[App] Request download from API
    ↓
[API] Validate license key → Invalid ✗
    ↓
[API] Return 403 Forbidden
```

### v6.3.5 - UI Pricing Column Removal

**Objective**: Remove visual sales pressure from UI

**Method**: CSS injection

**Injected Code**:
```html
<style>
.price-column,
.upgrade-prompt,
.pro-badge {
    display: none !important;
}
</style>
```

**Impact**:
- ✅ Cleaner interface
- ✅ No functionality change
- ✅ No stability impact

**Why It Works**:
- Pure CSS (no JavaScript required)
- `!important` overrides inline styles
- Hidden elements don't execute

### v6.10.0 - DNS Blocking

**Objective**: Prevent aaPanel from validating licenses remotely

**Method**: Socket-level DNS interception

**Implementation**:
```python
import socket

_original_getaddrinfo = socket.getaddrinfo

def _patched_getaddrinfo(host, port, *args, **kwargs):
    blocked_domains = ['api.bt.cn', 'download.bt.cn']
    
    if any(blocked in str(host) for blocked in blocked_domains):
        raise socket.gaierror("Name or service not known")
    
    return _original_getaddrinfo(host, port, *args, **kwargs)

socket.getaddrinfo = _patched_getaddrinfo
```

**How It Works**:
1. Python's `requests` library uses `socket.getaddrinfo()` for DNS
2. We replace this function with our patched version
3. Our version checks the hostname being resolved
4. If it matches a blocked domain, we raise an error
5. Otherwise, we pass through to the original function

**Impact**:
- ✅ License validation fails silently
- ✅ Panel operates offline
- ❌ Cannot update automatically
- ❌ Cannot download plugins

**Side Effects**:
```
[Panel] Try to validate license
    ↓
[DNS] Look up api.bt.cn
    ↓
[Patch] Blocked! Raise error
    ↓
[Panel] Connection failed → Continue with cached status
```

---

## Security Implications

### What This Research Reveals

1. **Client-Side Trust**: aaPanel trusts its own Python code
2. **No Code Signing**: Python files are not cryptographically signed
3. **Weak Validation**: Boolean checks without challenge-response
4. **API Dependency**: Core security relies on API availability

### What aaPanel Does Right

1. **Server-Side Validation**: Plugin downloads validate remotely
2. **Cryptographic Signing**: Plugins have MD5/SHA256 checksums
3. **HTTPS**: All API communication is encrypted
4. **License Keys**: Cannot be generated (server-side secret)

### Attack Surface

```
┌─────────────────────────────────────────┐
│ Vulnerable to Client Modification       │
├─────────────────────────────────────────┤
│ • UI feature gates                      │
│ • Boolean PRO checks                    │
│ • DNS resolution                        │
│ • Python code execution                 │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ Protected by Server-Side Validation     │
├─────────────────────────────────────────┤
│ • Plugin file downloads                 │
│ • License key validation                │
│ • Cryptographic signatures              │
│ • API authentication                    │
└─────────────────────────────────────────┘
```

---

## Limitations & Boundaries

### What We Can Do

- ✅ Modify UI appearance
- ✅ Bypass local feature checks
- ✅ Block network connections
- ✅ Modify application logic
- ✅ Access PRO UI features

### What We Cannot Do

- ❌ Download plugins (API validates)
- ❌ Generate valid license keys
- ❌ Bypass plugin signature checks
- ❌ Access truly server-side features
- ❌ Modify API responses

### Why Plugin Downloads Fail

Even with all modifications applied:

```
1. User clicks "Install Nginx"
2. UI allows the click (v6.2.6 ✓)
3. Application sends API request
4. API request includes license key
5. API validates key → INVALID
6. API returns 403 Forbidden
7. Download fails ✗
```

The API doesn't care about our local modifications. It validates independently.

### The Fundamental Limitation

**Client-side modifications cannot bypass server-side validation.**

This is a fundamental principle of software security:
- Never trust the client
- Always validate on the server
- Cryptographic signatures cannot be forged

Our modifications work because aaPanel made a design choice:
- PRO features are UI-gated locally (modifiable)
- Plugin downloads are API-gated remotely (not modifiable)

---

## Conclusion

This research demonstrates:

1. **Local control systems are modifiable** - UI and application logic
2. **Remote validation is effective** - Plugin downloads remain protected
3. **Defense in depth works** - Multiple validation layers prevent full bypass
4. **Transparency improves security** - Understanding systems makes them better

The aaPanel team did a reasonably good job:
- Critical functions (plugin distribution) are server-validated ✓
- Local features use simple checks (convenient but modifiable) ~
- The hybrid approach balances UX and security ~

For true security:
- All validation should happen server-side
- Client code should be considered untrusted
- Cryptographic signatures should verify all operations

---

**Research conducted by schema.cx organisation**  
*Understanding systems to improve security*

Last Updated: November 2024
