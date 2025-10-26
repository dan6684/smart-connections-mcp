# Smart Connections MCP - Deployment & Migration Guide

## Repository Structure Recommendations

### ✅ RECOMMENDED: Separate Repository

**Keep Smart Connections MCP in its own repository, NOT in your Obsidian vault.**

#### Rationale:

1. **Different concerns:**
   - Vault = Your notes (data)
   - MCP = Infrastructure/tooling (code)

2. **Version control:**
   - Vault changes frequently (daily notes)
   - MCP changes rarely (only when fixing/updating server)

3. **Portability:**
   - MCP can serve multiple vaults
   - Easier to update without touching vault

4. **Security:**
   - Vault may contain sensitive personal notes
   - MCP is generic infrastructure (safe to share publicly)

5. **Dependencies:**
   - MCP has Python dependencies, virtual env, compiled binaries
   - Vault should be lightweight and portable

### 📁 Recommended Structure

```
~/
├── obsidian-vaults/
│   └── Daedalus/               # Your vault (its own git repo)
│       ├── DailyNotes/
│       ├── .obsidian/
│       └── .smart-env/         # Smart Connections data (gitignored)
│
└── mcp-servers/                # All your MCP servers
    ├── smart-connections-mcp/  # This repo
    │   ├── .git/
    │   ├── .venv/             # Gitignored
    │   ├── server.py
    │   ├── requirements.txt
    │   └── README.md
    │
    └── zen-mcp-server/        # Zen MCP
        └── ...
```

## Migration Checklist

### When Moving to a New Machine

#### Step 1: Clone MCP Server Repository

```bash
# On new machine
cd ~/mcp-servers
git clone https://github.com/dan6684/smart-connections-mcp.git
cd smart-connections-mcp
```

#### Step 2: Set Up Virtual Environment

```bash
# Install UV if needed
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create venv and install dependencies
uv venv
uv pip install -r requirements.txt
```

#### Step 3: Update MCP Configuration

Edit `~/.mcp.json` on new machine:

```json
{
  "mcpServers": {
    "smart-connections": {
      "command": "/Users/NEW_USERNAME/mcp-servers/smart-connections-mcp/.venv/bin/python",
      "args": ["/Users/NEW_USERNAME/mcp-servers/smart-connections-mcp/server.py"],
      "env": {
        "OBSIDIAN_VAULT_PATH": "/Users/NEW_USERNAME/obsidian-vaults/Daedalus"
      }
    }
  }
}
```

**Key changes needed:**
- Update username in paths
- Update vault path if different
- Ensure `.venv/bin/python` path is correct

#### Step 4: Verify Installation

```bash
claude mcp list
```

Expected:
```
smart-connections: .venv/bin/python server.py - ✓ Connected
```

#### Step 5: Sync Your Vault

```bash
# Option A: Clone from git
cd ~/obsidian-vaults
git clone https://github.com/yourusername/obsidian-vault-daedalus.git Daedalus

# Option B: Use Obsidian Sync
# Let Obsidian sync the vault automatically

# Option C: Copy manually
rsync -av old-machine:~/obsidian-vaults/Daedalus/ ~/obsidian-vaults/Daedalus/
```

**Important:** The `.smart-env/` folder contains your embeddings:
- It's machine-specific (can be regenerated)
- May be large (gitignore it)
- Smart Connections will rebuild it on first run

## Git Repository Setup

### For smart-connections-mcp Repository

Create `.gitignore`:

```gitignore
# Virtual environment
.venv/
__pycache__/
*.pyc

# OS files
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/

# Logs
*.log

# Model cache (if you download models locally)
models/
.cache/
```

### For Obsidian Vault Repository (Separate)

Create `.gitignore` in vault:

```gitignore
# Obsidian
.obsidian/workspace.json
.obsidian/workspace-mobile.json

# Smart Connections embeddings (regenerate on each machine)
.smart-env/

# OS files
.DS_Store
.trash/

# Private/sensitive notes (optional)
Private/
Journal/therapy-notes/
```

## Configuration Management Strategies

### Strategy 1: Hardcoded Paths (Simple)

**In `~/.mcp.json`:**
```json
{
  "mcpServers": {
    "smart-connections": {
      "command": "/Users/daedalus/mcp-servers/smart-connections-mcp/.venv/bin/python",
      "args": ["/Users/daedalus/mcp-servers/smart-connections-mcp/server.py"],
      "env": {
        "OBSIDIAN_VAULT_PATH": "/Users/daedalus/obsidian-vaults/Daedalus"
      }
    }
  }
}
```

**Pros:** Simple, direct
**Cons:** Must update paths on each machine

### Strategy 2: Environment Variables (Flexible)

**Create `~/.mcp_env`:**
```bash
export MCP_HOME="$HOME/mcp-servers"
export OBSIDIAN_VAULT="$HOME/obsidian-vaults/Daedalus"
```

**In `~/.mcp.json`:**
```json
{
  "mcpServers": {
    "smart-connections": {
      "command": "$MCP_HOME/smart-connections-mcp/.venv/bin/python",
      "args": ["$MCP_HOME/smart-connections-mcp/server.py"],
      "env": {
        "OBSIDIAN_VAULT_PATH": "$OBSIDIAN_VAULT"
      }
    }
  }
}
```

**Note:** Check if Claude Code supports env var expansion in config.

### Strategy 3: Relative Paths (Portable)

**If you always use same structure:**
```json
{
  "mcpServers": {
    "smart-connections": {
      "command": "python3",
      "args": ["$HOME/mcp-servers/smart-connections-mcp/server.py"],
      "env": {
        "OBSIDIAN_VAULT_PATH": "$HOME/obsidian-vaults/Daedalus"
      }
    }
  }
}
```

### Strategy 4: Per-Machine Config (Explicit)

**Keep machine-specific configs in git:**

```
smart-connections-mcp/
├── configs/
│   ├── macbook-pro.json      # Your MacBook
│   ├── desktop.json          # Desktop machine
│   └── work-laptop.json      # Work machine
├── server.py
└── README.md
```

**Migration script:**
```bash
#!/bin/bash
# setup.sh

MACHINE_NAME=$(hostname)
cp configs/${MACHINE_NAME}.json ~/.mcp.json

echo "MCP configured for $MACHINE_NAME"
claude mcp list
```

## Multi-Vault Support

### Scenario: Multiple Obsidian Vaults

You can run **separate MCP servers** for each vault:

```json
{
  "mcpServers": {
    "smart-connections-personal": {
      "command": "/Users/daedalus/mcp-servers/smart-connections-mcp/.venv/bin/python",
      "args": ["/Users/daedalus/mcp-servers/smart-connections-mcp/server.py"],
      "env": {
        "OBSIDIAN_VAULT_PATH": "/Users/daedalus/obsidian-vaults/Personal"
      }
    },
    "smart-connections-work": {
      "command": "/Users/daedalus/mcp-servers/smart-connections-mcp/.venv/bin/python",
      "args": ["/Users/daedalus/mcp-servers/smart-connections-mcp/server.py"],
      "env": {
        "OBSIDIAN_VAULT_PATH": "/Users/daedalus/obsidian-vaults/Work"
      }
    }
  }
}
```

**Key insight:** Same server code, different OBSIDIAN_VAULT_PATH env var.

## Backup & Sync Recommendations

### What to Back Up

| Item | Location | Backup Method | Priority |
|------|----------|---------------|----------|
| **Vault notes** | `~/obsidian-vaults/Daedalus/` | Git + Obsidian Sync | 🔴 CRITICAL |
| **MCP server code** | `~/mcp-servers/smart-connections-mcp/` | Git | 🟡 MEDIUM |
| **MCP config** | `~/.mcp.json` | Manual copy or dotfiles repo | 🟡 MEDIUM |
| **Smart Connections embeddings** | `.smart-env/` | ⚠️ Don't backup (regenerate) | ⚪ SKIP |
| **Virtual environment** | `.venv/` | ⚠️ Don't backup (recreate) | ⚪ SKIP |

### Backup Script Example

```bash
#!/bin/bash
# backup-mcp-setup.sh

# Backup MCP configuration
cp ~/.mcp.json ~/Dropbox/backups/mcp.json.backup

# Backup server code (if not in git)
tar -czf ~/Dropbox/backups/mcp-servers-$(date +%Y%m%d).tar.gz \
  ~/mcp-servers/ \
  --exclude=.venv \
  --exclude=__pycache__

echo "MCP setup backed up to Dropbox"
```

## Migration Automation

### Quick Setup Script

Create `smart-connections-mcp/install.sh`:

```bash
#!/bin/bash
set -e

echo "🚀 Setting up Smart Connections MCP..."

# 1. Install UV if needed
if ! command -v uv &> /dev/null; then
    echo "Installing UV..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# 2. Create virtual environment
echo "Creating virtual environment..."
uv venv

# 3. Install dependencies
echo "Installing dependencies..."
uv pip install -r requirements.txt

# 4. Detect vault path
VAULT_PATH=$(find ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents -maxdepth 1 -type d | head -1)

if [ -z "$VAULT_PATH" ]; then
    echo "⚠️  Could not auto-detect Obsidian vault"
    read -p "Enter vault path: " VAULT_PATH
fi

# 5. Get current directory
MCP_DIR=$(pwd)

# 6. Create/update MCP config
echo "Configuring MCP..."
cat > ~/.mcp.json.new <<EOF
{
  "mcpServers": {
    "smart-connections": {
      "command": "$MCP_DIR/.venv/bin/python",
      "args": ["$MCP_DIR/server.py"],
      "env": {
        "OBSIDIAN_VAULT_PATH": "$VAULT_PATH"
      }
    }
  }
}
EOF

# Merge with existing config if present
if [ -f ~/.mcp.json ]; then
    echo "⚠️  Existing MCP config found. Backup created at ~/.mcp.json.backup"
    cp ~/.mcp.json ~/.mcp.json.backup
    # TODO: Merge JSON properly
fi

mv ~/.mcp.json.new ~/.mcp.json

# 7. Verify
echo ""
echo "✅ Installation complete!"
echo ""
echo "Verifying..."
claude mcp list

echo ""
echo "📝 Configuration:"
echo "   MCP Server: $MCP_DIR"
echo "   Vault Path: $VAULT_PATH"
echo "   Python: $MCP_DIR/.venv/bin/python"
```

Make executable:
```bash
chmod +x install.sh
```

## Platform-Specific Notes

### macOS
- Vault typically at: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/`
- Use full paths (no `~` in MCP config)

### Linux
- Vault typically at: `~/Documents/Obsidian/`
- May need to adjust Python path

### Windows (WSL)
- Vault may be at: `/mnt/c/Users/USERNAME/Documents/Obsidian/`
- Use WSL paths, not Windows paths
- Ensure `python3` is available in WSL

## Troubleshooting Migration Issues

### Issue: "Server won't connect on new machine"

**Checklist:**
- [ ] Virtual environment created? (`ls .venv/bin/python`)
- [ ] Dependencies installed? (`uv pip list`)
- [ ] Correct Python path in config? (use absolute path)
- [ ] Vault path exists? (`ls "$OBSIDIAN_VAULT_PATH"`)
- [ ] Permissions correct? (`chmod +x server.py`)

### Issue: "Can't find vault on new machine"

```bash
# Find all Obsidian vaults
find ~ -name ".obsidian" -type d 2>/dev/null

# Check iCloud sync status (macOS)
ls -la ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/
```

### Issue: "Different username on new machine"

Use a setup script with dynamic username:

```bash
#!/bin/bash
USERNAME=$(whoami)
sed "s/REPLACE_USERNAME/$USERNAME/g" configs/template.json > ~/.mcp.json
```

## Best Practices Summary

✅ **DO:**
- Keep MCP server in separate git repository
- Use virtual environments (`.venv/`)
- Document machine-specific paths
- Create setup/install scripts
- Test migration on a VM first

❌ **DON'T:**
- Commit `.venv/` to git
- Commit `.smart-env/` to git
- Hardcode absolute paths without documentation
- Mix vault data with MCP infrastructure
- Forget to backup `~/.mcp.json`

## Example: Complete Migration (macOS → macOS)

```bash
# On NEW machine:

# 1. Clone MCP server
cd ~/
mkdir -p mcp-servers
cd mcp-servers
git clone https://github.com/dan6684/smart-connections-mcp.git
cd smart-connections-mcp

# 2. Run setup
./install.sh

# 3. Verify
claude mcp list

# 4. Sync vault (Obsidian will handle this automatically)
# Open Obsidian, let it sync

# 5. Done! Smart Connections will rebuild embeddings automatically
```

Total time: ~5 minutes

## Questions?

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed debugging help.
