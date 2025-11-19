# Modification v6.10.0 - DNS Blocking Research

## Overview

This modification blocks aaPanel's ability to communicate with licensing servers by intercepting DNS resolution attempts at the socket level.

## Target File

- **Path**: `/www/server/panel/class/public.py`
- **Purpose**: Common utilities used throughout aaPanel
- **Risk Level**: High

## How It Works

aaPanel makes outbound HTTPS connections to validate licenses, check for updates, and download plugins. These connections use DNS to resolve domain names.

Our modification:

1. Imports Python's `socket` module
2. Replaces `socket.getaddrinfo()` with a patched version
3. Intercepts DNS lookups for aaPanel domains
4. Raises a "Name or service not known" error for blocked domains
5. All other DNS lookups work normally

## Code Changes

### Injected Code
```python
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
    
    if any(blocked in str(host).lower() for blocked in blocked_domains):
        raise socket.gaierror(f"[Errno -2] Name or service not known")
    
    return _original_getaddrinfo(host, port, family, type, proto, flags)

socket.getaddrinfo = _patched_getaddrinfo
```

## Blocked Domains

- `www.bt.cn` - Main BT.cn website
- `api.bt.cn` - API endpoints for license validation
- `download.bt.cn` - Plugin download servers
- `node.aapanel.com` - aaPanel node servers
- `www.aapanel.com` - aaPanel official website

## Side Effects

### Expected Behavior
- ✅ Panel operates in "offline" mode
- ✅ License status cannot be re-validated remotely
- ✅ PRO features remain accessible (with v6.2.6)

### Known Limitations
- ❌ Panel cannot auto-update
- ❌ Plugin repository cannot refresh
- ❌ Plugin downloads will fail
- ❌ News/announcements don't load
- ❌ Cannot check for new aaPanel versions

## Security Considerations

This is the most aggressive modification:

1. **Updates Blocked**: Security patches cannot be applied automatically
2. **Manual Updates Required**: You must manually update aaPanel
3. **Isolation**: Panel cannot phone home for any reason

## Application

```bash
python3 apply.py /www/server/panel/class/public.py
```

## Reversion

Restore from the automatically created backup:

```bash
cp /www/server/panel/class/public.py.backup_* /www/server/panel/class/public.py
rm -rf /www/server/panel/class/__pycache__
bt restart
```

## Testing

After application:

1. Panel should start normally
2. Check panel logs for DNS errors (expected):
   ```bash
   tail -f /www/server/panel/logs/error.log
   ```
3. Verify blocked domains cannot be reached from panel
4. Other internet connectivity should work normally

## Alternative Approaches

Instead of DNS blocking in Python, you could also:

1. **Firewall blocking**:
   ```bash
   iptables -A OUTPUT -d api.bt.cn -j REJECT
   ```

2. **Hosts file**:
   ```bash
   echo "127.0.0.1 api.bt.cn" >> /etc/hosts
   ```

3. **DNS sinkhole**: Point domains to 127.0.0.1 in your DNS server

However, the Python-level blocking is more portable and doesn't require root access after initial installation.

## Compatibility

- aaPanel 6.8.x ✅
- aaPanel 6.9.x ✅
- aaPanel 6.10.x ✅
- aaPanel 6.11.x ✅
- aaPanel 6.12.x ✅
- aaPanel 6.13.x ✅
- aaPanel 6.14.x ✅
- aaPanel 6.15.x ✅

**Note**: This modification is stable but prevents updates. Use with caution.
