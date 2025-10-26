# Quick Answers - Migration & Setup

## Q: Should I keep the Smart Connections MCP in a different GitHub repository than my Obsidian Vault?

### A: YES - Keep them separate! ✅

**Recommended structure:**

```
~/
├── obsidian-vaults/
│   └── Daedalus/              # Git repo #1 - Your notes
│       └── .git/
│
└── mcp-servers/
    └── smart-connections-mcp/  # Git repo #2 - Infrastructure
        └── .git/
```

### Why Separate?

| Aspect | Vault Repo | MCP Repo |
|--------|------------|----------|
| **Purpose** | Personal notes (data) | Infrastructure (code) |
| **Change frequency** | Daily/hourly | Rarely |
| **Privacy** | Often private | Can be public |
| **Size** | Large (MB-GB) | Small (KB) |
| **Dependencies** | None | Python, venv, binaries |
| **Portability** | Sync everywhere | One-time setup per machine |

### Benefits:

1. **Clean separation of concerns** - Don't mix data with infrastructure
2. **Easier updates** - Update MCP code without touching your notes
3. **Better security** - Can share MCP code publicly without exposing notes
4. **Multi-vault support** - One MCP server can serve multiple vaults
5. **Smaller vault** - No Python code/dependencies cluttering your notes

---

## Q: How do I migrate my MCPs when I move to another machine?

### A: 5-Minute Migration Process

#### On NEW machine:

```bash
# 1. Clone MCP server repo
git clone https://github.com/yourusername/smart-connections-mcp.git ~/mcp-servers/smart-connections-mcp

# 2. Run installer
cd ~/mcp-servers/smart-connections-mcp
./install.sh

# 3. Done! ✅
```

The `install.sh` script handles:
- Installing UV
- Creating virtual environment
- Installing dependencies
- Auto-detecting your vault
- Configuring `~/.mcp.json`
- Verifying the setup

#### Your vault syncs separately:
- Use Obsidian Sync, or
- Git clone your vault repo, or
- Manual rsync/copy

**Total time:** ~5 minutes (most is dependency download)

---

## Q: What files should I commit to git?

### Smart Connections MCP Repo (Commit ✅)

```
smart-connections-mcp/
├── .git/                 ✅ Git metadata
├── .gitignore           ✅ Ignore rules
├── server.py            ✅ Server code
├── requirements.txt     ✅ Dependencies
├── install.sh           ✅ Setup script
├── README.md            ✅ Documentation
├── DEPLOYMENT.md        ✅ Migration guide
├── TROUBLESHOOTING.md   ✅ Debug help
└── LICENSE              ✅ License file
```

### Don't Commit (❌):

```
.venv/                   ❌ Virtual environment (recreate on each machine)
__pycache__/            ❌ Python cache
*.pyc                   ❌ Compiled Python
.DS_Store               ❌ macOS metadata
*.log                   ❌ Log files
```

### Obsidian Vault Repo (Separate)

**Commit:**
- ✅ Your notes (`.md` files)
- ✅ Attachments/images (optional)
- ✅ `.obsidian/` config (themes, plugins)

**Don't commit:**
- ❌ `.smart-env/` - Embeddings (large, machine-specific)
- ❌ `.obsidian/workspace.json` - Personal workspace state
- ❌ Private/sensitive notes (use `.gitignore`)

---

## Q: What about `~/.mcp.json` config?

### Option 1: Manual (Simple)

Each machine has its own `~/.mcp.json` with machine-specific paths.

**Migration:** Re-run `./install.sh` on new machine.

### Option 2: Dotfiles Repo (Advanced)

Keep `~/.mcp.json` in a dotfiles repository with templating:

```bash
# In dotfiles repo
~/dotfiles/
└── mcp.json.template   # Template with $HOME placeholders
```

**Migration:** Script replaces placeholders with actual paths.

### Recommendation:

For most users: **Option 1 (manual)** is simpler. The `install.sh` script handles it automatically.

---

## Q: Can I use one MCP server for multiple vaults?

### A: Yes! Configure multiple instances

In `~/.mcp.json`:

```json
{
  "mcpServers": {
    "smart-connections-personal": {
      "command": "/Users/you/mcp-servers/smart-connections-mcp/.venv/bin/python",
      "args": ["/Users/you/mcp-servers/smart-connections-mcp/server.py"],
      "env": {
        "OBSIDIAN_VAULT_PATH": "/Users/you/vaults/Personal"
      }
    },
    "smart-connections-work": {
      "command": "/Users/you/mcp-servers/smart-connections-mcp/.venv/bin/python",
      "args": ["/Users/you/mcp-servers/smart-connections-mcp/server.py"],
      "env": {
        "OBSIDIAN_VAULT_PATH": "/Users/you/vaults/Work"
      }
    }
  }
}
```

**Key insight:** Same code, different `OBSIDIAN_VAULT_PATH` environment variable.

---

## Q: What if I use multiple machines (MacBook + Desktop)?

### A: Standard workflow works great!

1. **MCP repo** - Clone once on each machine, run `./install.sh`
2. **Vault** - Syncs automatically via Obsidian Sync or git

**Example:**

```bash
# MacBook Pro
~/mcp-servers/smart-connections-mcp/  # Local clone
~/.mcp.json                           # Machine-specific config
~/vaults/Daedalus/                    # Synced via Obsidian

# Desktop
~/mcp-servers/smart-connections-mcp/  # Local clone (same repo)
~/.mcp.json                           # Machine-specific config
~/vaults/Daedalus/                    # Synced via Obsidian
```

**Smart Connections embeddings (`.smart-env/`):**
- ❌ Don't sync between machines (large, can differ)
- ✅ Smart Connections regenerates automatically on each machine

---

## Q: What about backing up?

### What to Backup:

| Item | Backup Priority | Method |
|------|----------------|--------|
| **Vault notes** | 🔴 CRITICAL | Git + Obsidian Sync |
| **MCP server code** | 🟡 Medium | Git (public repo) |
| **`~/.mcp.json`** | 🟡 Medium | Dotfiles or manual |
| **`.smart-env/`** | ⚪ Skip | Regenerate (too large) |
| **`.venv/`** | ⚪ Skip | Recreate from requirements.txt |

### Backup Strategy:

**Critical (daily):**
```bash
# Vault automatically backed up via Obsidian Sync + git
cd ~/vaults/Daedalus
git push origin main
```

**Medium (after changes):**
```bash
# MCP server - only when you modify code
cd ~/mcp-servers/smart-connections-mcp
git push origin main
```

**Optional:**
```bash
# Copy MCP config to Dropbox/cloud
cp ~/.mcp.json ~/Dropbox/backups/mcp.json.backup
```

---

## Q: How do I update the MCP server code?

```bash
cd ~/mcp-servers/smart-connections-mcp

# Pull latest changes
git pull origin main

# Reinstall dependencies (if requirements.txt changed)
uv pip install -r requirements.txt

# Restart Claude Code (to reload server)
# Or just start a new session
```

No need to update `~/.mcp.json` unless paths changed.

---

## Q: Can I share my MCP server publicly?

### YES! ✅

The MCP server code is infrastructure - safe to share publicly:

**Public repo can include:**
- ✅ `server.py` - Generic code
- ✅ `requirements.txt` - Dependencies
- ✅ Documentation
- ✅ Installation scripts

**Private repo (vault) should include:**
- 🔒 Your personal notes
- 🔒 Attachments
- 🔒 Any sensitive content

**Example public repos:**
- https://github.com/yourusername/smart-connections-mcp ← MCP server
- https://github.com/yourusername/my-vault (private) ← Your notes

---

## Full Documentation

- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Complete migration guide with all strategies
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Detailed debugging help
- **[README.md](README.md)** - Usage and installation

---

## TL;DR

1. ✅ **Separate repos** - MCP server ≠ Vault
2. ✅ **Use `./install.sh`** - Automates migration
3. ✅ **Keep `.venv/` local** - Don't commit to git
4. ✅ **One server, multiple vaults** - Use different env vars
5. ✅ **5-minute migration** - Clone + run install.sh

**Migration command:**
```bash
git clone <repo> ~/mcp-servers/smart-connections-mcp && cd ~/mcp-servers/smart-connections-mcp && ./install.sh
```

Done! 🎉
