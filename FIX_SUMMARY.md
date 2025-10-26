# Smart Connections MCP Server - Fix Summary

**Date:** 2025-10-25
**Issue:** Server timeout on connection
**Status:** ✅ RESOLVED

## Quick Summary

The Smart Connections MCP server was completely rewritten to fix three critical issues:

### 1️⃣ Broken MCP Protocol (Custom Implementation)
- **Problem:** Custom JSON-RPC implementation sent messages before handshake
- **Fix:** Rewrote using official `mcp` Python SDK
- **Impact:** Server now properly implements MCP specification

### 2️⃣ NumPy 2.x Incompatibility ⚠️ CRITICAL
- **Problem:** `numpy>=1.24.0` resolved to 2.3.4, breaking sentence-transformers
- **Fix:** Pinned to `numpy<2.0.0` in requirements.txt
- **Impact:** Server can now import ML dependencies without crashes

### 3️⃣ Missing Virtual Environment
- **Problem:** Using system Python with conflicting dependencies
- **Fix:** Created `.venv` with `uv`, updated config to use `.venv/bin/python`
- **Impact:** Isolated dependencies, reproducible environment

## Files Changed

| File | Changes | Lines |
|------|---------|-------|
| `server.py` | Complete rewrite with MCP SDK | 433→402 |
| `requirements.txt` | Fixed numpy constraint, added mcp | 4→5 |
| `~/.mcp.json` | Updated to use venv Python | - |

## Verification

```bash
$ claude mcp list
Checking MCP server health...

zen: ... - ✓ Connected
smart-connections: .venv/bin/python server.py - ✓ Connected  # ← FIXED!
```

## Key Dependencies

```
mcp==1.19.0              # Official MCP SDK
numpy==1.26.4            # Must be <2.0.0
sentence-transformers    # Requires numpy 1.x
```

## Before & After

### Before (Broken):
```python
# Custom protocol - violated JSON-RPC spec
def send_message(msg: dict):
    print(json.dumps(msg), flush=True)

send_message({"type": "log", "level": "info", ...})  # ← Breaks protocol!
```

### After (Working):
```python
# Official MCP SDK
from mcp.server import Server
from mcp.server.stdio import stdio_server

@server.list_tools()
async def handle_list_tools() -> list[types.Tool]:
    return [...]  # Proper async handler
```

## Lessons Learned

1. ✅ Use official SDKs - don't reinvent protocols
2. ✅ Pin ML dependencies - numpy/torch version conflicts are common
3. ✅ Always use virtual environments for Python projects
4. ✅ Test with `claude mcp list` before assuming server works
5. ✅ Check stderr for hidden errors (NumPy warning was critical)

## Documentation

- Full debugging guide: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- Updated installation: [README.md](README.md)

## Testing Checklist

- [x] Server starts without errors
- [x] `claude mcp list` shows connection
- [x] Can call `semantic_search` tool
- [x] Can call `find_related` tool
- [x] Can call `get_context_blocks` tool
- [x] NumPy imports work correctly
- [x] Virtual environment is isolated

## Next Steps for Users

If experiencing timeout issues:

1. Delete old installation
2. Follow updated README.md installation steps
3. Use virtual environment (`.venv/bin/python`)
4. Verify with `claude mcp list`
5. See TROUBLESHOOTING.md if issues persist
