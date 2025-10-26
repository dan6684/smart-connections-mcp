# Smart Connections MCP Server - Troubleshooting Guide

## Issue: MCP Server Timeout on Connection

**Date:** 2025-10-25
**Status:** RESOLVED

### Problem Description

The Smart Connections MCP server was timing out when `claude mcp list` attempted to connect. The server would hang indefinitely and never respond to initialization requests from the Claude Code MCP client.

### Symptoms

- `claude mcp list` command would timeout after 30+ seconds
- Server appeared in configuration but showed no connection status
- Only the `zen` MCP server would connect successfully
- No error messages visible to the user

### Root Causes

Three distinct issues were identified and resolved:

#### 1. Broken MCP Protocol Implementation

**Issue:** The original server implemented a custom, incomplete MCP protocol that violated the JSON-RPC 2.0 specification.

**Specific Problems:**
- Server sent log messages (`send_message()`) before the MCP initialize handshake (server.py:406-410)
- Arbitrary message formats with `{"type": "log", ...}` instead of proper JSON-RPC responses
- Error messages sent out-of-band breaking the protocol (server.py:56, 398-400)
- Incomplete JSON-RPC implementation missing proper error handling

**Evidence:**
```python
# BROKEN CODE (Original):
send_message({
    "type": "log",
    "level": "info",
    "message": f"Smart Connections MCP server ready. Vault: {vault_path}"
})
```

Messages sent before initialization violate MCP protocol requirements. The client expects the first message to be a response to the `initialize` request.

#### 2. NumPy Version Incompatibility (CRITICAL)

**Issue:** NumPy 2.x incompatibility with sentence-transformers library caused import failures.

**Error Output:**
```
A module that was compiled using NumPy 1.x cannot be run in
NumPy 2.3.4 as it may crash. To support both 1.x and 2.x
versions of NumPy, modules must be compiled with NumPy 2.0.
```

**Root Cause:**
- `requirements.txt` specified `numpy>=1.24.0`
- `uv pip install` resolved to NumPy 2.3.4
- `sentence-transformers` dependencies were compiled against NumPy 1.x
- Import of `SentenceTransformer` triggered the compatibility error

**Fix Applied:**
```diff
- numpy>=1.24.0
+ numpy<2.0.0
```

#### 3. Missing MCP SDK Dependency

**Issue:** The server attempted to implement MCP protocol manually instead of using the official SDK.

**Problems:**
- No dependency on `mcp` package in requirements.txt
- Manual JSON-RPC parsing prone to errors
- Incompatible with MCP protocol updates
- Missing proper async/await handling for stdio transport

### Solution Implementation

#### Step 1: Add MCP SDK Dependency

Updated `requirements.txt`:
```python
sentence-transformers>=2.2.0
numpy<2.0.0  # ← Fixed version constraint
transformers>=4.30.0
torch>=2.0.0
mcp>=1.0.0   # ← Added official SDK
```

#### Step 2: Create Virtual Environment with UV

```bash
cd /Users/daedalus/smart-connections-mcp
/Users/daedalus/.local/bin/uv venv
/Users/daedalus/.local/bin/uv pip install -r requirements.txt
```

This resolved to:
- `numpy==1.26.4` (compatible with sentence-transformers)
- `mcp==1.19.0` (latest MCP SDK)

#### Step 3: Rewrite Server Using Official MCP SDK

Complete rewrite of server.py to use proper MCP protocol:

**Key Changes:**

1. **Proper Imports:**
```python
from mcp.server.models import InitializationOptions
import mcp.types as types
from mcp.server import Server
from mcp.server.stdio import stdio_server
```

2. **Async Server Setup:**
```python
async def main():
    # Get vault path from environment
    vault_path = os.getenv('OBSIDIAN_VAULT_PATH')
    if not vault_path:
        raise ValueError("OBSIDIAN_VAULT_PATH environment variable not set")

    # Initialize database
    db = SmartConnectionsDatabase(vault_path)

    # Create MCP server
    server = Server("smart-connections-mcp")
```

3. **Tool Registration with Decorators:**
```python
@server.list_tools()
async def handle_list_tools() -> list[types.Tool]:
    """List available tools"""
    return [
        types.Tool(
            name="semantic_search",
            description="Search vault using semantic similarity...",
            inputSchema={...}
        ),
        # ... more tools
    ]

@server.call_tool()
async def handle_call_tool(
    name: str, arguments: dict | None
) -> list[types.TextContent | types.ImageContent | types.EmbeddedResource]:
    """Handle tool execution requests"""
    # Implementation
```

4. **Proper Server Lifecycle:**
```python
async with stdio_server() as (read_stream, write_stream):
    await server.run(
        read_stream,
        write_stream,
        InitializationOptions(
            server_name="smart-connections-mcp",
            server_version="0.1.0",
            capabilities=types.ServerCapabilities(
                tools=types.ToolsCapability(),
            ),
        ),
    )
```

#### Step 4: Update MCP Configuration

Updated `.mcp.json` to use virtual environment Python:

```json
{
  "mcpServers": {
    "smart-connections": {
      "command": "/Users/daedalus/smart-connections-mcp/.venv/bin/python",
      "args": ["/Users/daedalus/smart-connections-mcp/server.py"],
      "env": {
        "OBSIDIAN_VAULT_PATH": "/Users/daedalus/Library/Mobile Documents/iCloud~md~obsidian/Documents/Daedalus"
      }
    }
  }
}
```

### Verification Steps

#### Manual Testing:
```bash
# Test server responds to initialize request
(echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}'; sleep 2; echo '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'; sleep 1) | OBSIDIAN_VAULT_PATH="/Users/daedalus/Library/Mobile Documents/iCloud~md~obsidian/Documents/Daedalus" .venv/bin/python server.py
```

**Expected Output:**
```json
{"jsonrpc":"2.0","id":1,"result":{"protocolVersion":"2024-11-05","capabilities":{"tools":{}},"serverInfo":{"name":"smart-connections-mcp","version":"0.1.0"}}}
{"jsonrpc":"2.0","id":2,"result":{"tools":[...]}}
```

#### Claude Code Integration:
```bash
claude mcp list
```

**Expected Output:**
```
Checking MCP server health...

zen: ... - ✓ Connected
smart-connections: /Users/daedalus/smart-connections-mcp/.venv/bin/python ... - ✓ Connected
```

### Lessons Learned

1. **Always use official SDKs** - Custom protocol implementations are error-prone and hard to debug
2. **Pin critical dependencies** - Version conflicts in ML libraries (NumPy, PyTorch) can cause silent failures
3. **Test incrementally** - Breaking down the problem (imports → server start → protocol handshake) helped isolate issues
4. **Check stderr output** - The NumPy error was only visible in stderr, not in the timeout message
5. **Use virtual environments** - Isolating dependencies prevents system-wide conflicts

### Debugging Techniques Used

1. **Isolate the server** - Removed from config temporarily to confirm it was the issue
2. **Manual protocol testing** - Sent raw JSON-RPC messages to test server behavior
3. **Import testing** - Tested imports separately to find dependency issues
4. **Incremental startup** - Added debug logging at each initialization step
5. **Comparison with working server** - Examined zen-mcp-server for reference implementation

### Files Modified

1. `server.py` - Complete rewrite using MCP SDK (433 lines → 402 lines)
2. `requirements.txt` - Fixed numpy version constraint, added mcp dependency
3. `.mcp.json` - Updated to use virtual environment Python interpreter

### Performance Notes

- Server startup time: ~1 second (lazy loading of embeddings)
- First semantic search: ~20 seconds (one-time model download and loading)
- Subsequent searches: <1 second (model cached in memory)

### Future Improvements

1. **Pre-download model** - Include model in repository or document download process
2. **Connection pooling** - Keep server alive between requests to avoid reload overhead
3. **Progress feedback** - Add proper logging for model download/loading status
4. **Error handling** - Improve error messages for missing vault path or invalid configuration

### References

- MCP Python SDK: https://github.com/modelcontextprotocol/python-sdk
- MCP Specification: https://spec.modelcontextprotocol.io/
- NumPy Compatibility: https://numpy.org/devdocs/numpy_2_0_migration_guide.html
