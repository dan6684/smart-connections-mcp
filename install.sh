#!/bin/bash
set -e

echo "🚀 Setting up Smart Connections MCP..."
echo ""

# 1. Install UV if needed
if ! command -v uv &> /dev/null; then
    echo "📦 Installing UV package manager..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
else
    echo "✓ UV already installed"
fi

# 2. Create virtual environment
if [ -d ".venv" ]; then
    echo "✓ Virtual environment exists"
else
    echo "📦 Creating virtual environment..."
    uv venv
fi

# 3. Install dependencies
echo "📦 Installing dependencies..."
uv pip install -r requirements.txt

echo ""
echo "✓ Python dependencies installed"
echo ""

# 4. Detect vault path
echo "🔍 Looking for Obsidian vault..."

# Try common locations
VAULT_CANDIDATES=(
    "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
    "$HOME/Documents/Obsidian"
    "$HOME/Obsidian"
)

VAULT_PATH=""
for candidate in "${VAULT_CANDIDATES[@]}"; do
    if [ -d "$candidate" ]; then
        # Find first directory with .obsidian folder
        FOUND=$(find "$candidate" -maxdepth 2 -name ".obsidian" -type d 2>/dev/null | head -1)
        if [ -n "$FOUND" ]; then
            VAULT_PATH=$(dirname "$FOUND")
            break
        fi
    fi
done

if [ -z "$VAULT_PATH" ]; then
    echo "⚠️  Could not auto-detect Obsidian vault"
    echo ""
    read -p "Enter full path to your Obsidian vault: " VAULT_PATH

    if [ ! -d "$VAULT_PATH" ]; then
        echo "❌ Error: Vault path does not exist: $VAULT_PATH"
        exit 1
    fi
fi

echo "✓ Found vault: $VAULT_PATH"

# Verify it's an Obsidian vault
if [ ! -d "$VAULT_PATH/.obsidian" ]; then
    echo "⚠️  Warning: $VAULT_PATH does not appear to be an Obsidian vault (.obsidian folder not found)"
    read -p "Continue anyway? (y/N): " CONFIRM
    if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
        echo "Aborted."
        exit 1
    fi
fi

# 5. Get current directory (absolute path)
MCP_DIR=$(pwd)
PYTHON_PATH="$MCP_DIR/.venv/bin/python"

# Verify Python exists
if [ ! -f "$PYTHON_PATH" ]; then
    echo "❌ Error: Python not found at $PYTHON_PATH"
    echo "   Virtual environment may not have been created correctly."
    exit 1
fi

echo ""
echo "📝 Configuration:"
echo "   MCP Server: $MCP_DIR"
echo "   Python:     $PYTHON_PATH"
echo "   Vault:      $VAULT_PATH"
echo ""

# 6. Create/update MCP config
MCP_CONFIG="$HOME/.mcp.json"

# Check if config exists
if [ -f "$MCP_CONFIG" ]; then
    echo "⚠️  Existing MCP config found at $MCP_CONFIG"
    echo "   Creating backup at $MCP_CONFIG.backup"
    cp "$MCP_CONFIG" "$MCP_CONFIG.backup"

    # Check if smart-connections already exists
    if grep -q '"smart-connections"' "$MCP_CONFIG"; then
        echo "⚠️  smart-connections server already configured"
        read -p "Overwrite existing configuration? (y/N): " OVERWRITE
        if [ "$OVERWRITE" != "y" ] && [ "$OVERWRITE" != "Y" ]; then
            echo ""
            echo "ℹ️  Skipping MCP config update."
            echo "   Manual configuration required. Add this to $MCP_CONFIG:"
            echo ""
            cat <<EOF
{
  "mcpServers": {
    "smart-connections": {
      "command": "$PYTHON_PATH",
      "args": ["$MCP_DIR/server.py"],
      "env": {
        "OBSIDIAN_VAULT_PATH": "$VAULT_PATH"
      }
    }
  }
}
EOF
            exit 0
        fi
    fi

    # TODO: Properly merge JSON (for now, just append)
    echo "⚠️  Note: Automatic config merging not yet implemented"
    echo "   You may need to manually merge configurations"
fi

# Create new config (simple version - overwrites existing)
echo "📝 Writing MCP configuration..."
cat > "$MCP_CONFIG" <<EOF
{
  "mcpServers": {
    "smart-connections": {
      "command": "$PYTHON_PATH",
      "args": ["$MCP_DIR/server.py"],
      "env": {
        "OBSIDIAN_VAULT_PATH": "$VAULT_PATH"
      }
    }
  }
}
EOF

echo "✓ MCP configuration written to $MCP_CONFIG"
echo ""

# 7. Verify installation
echo "🔍 Verifying installation..."
echo ""

if command -v claude &> /dev/null; then
    claude mcp list
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        echo ""
        echo "✅ Installation complete and verified!"
        echo ""
        echo "📚 Next steps:"
        echo "   1. Open Obsidian and ensure Smart Connections plugin is enabled"
        echo "   2. Let Smart Connections index your vault (may take a few minutes)"
        echo "   3. Try semantic search in Claude Code!"
        echo ""
        echo "📖 Documentation:"
        echo "   - README.md - Usage examples"
        echo "   - TROUBLESHOOTING.md - Debug guide"
        echo "   - DEPLOYMENT.md - Migration guide"
    else
        echo ""
        echo "⚠️  Installation complete but verification failed"
        echo "   Run 'claude mcp list' to check connection status"
        echo "   See TROUBLESHOOTING.md for help"
    fi
else
    echo "⚠️  'claude' command not found - cannot verify"
    echo "   Install Claude Code to verify the setup"
    echo ""
    echo "✅ Installation files configured successfully!"
fi

echo ""
