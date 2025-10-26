# Setting Up GitHub Repository for Smart Connections MCP

## Prerequisites

You need:
1. GitHub account
2. Git configured locally
3. GitHub CLI (`gh`) or personal access token

## Option 1: Using GitHub CLI (Recommended)

### Install GitHub CLI

```bash
# macOS (using Homebrew)
brew install gh

# Or download from https://cli.github.com/
```

### Authenticate

```bash
gh auth login
```

Follow the prompts to authenticate with GitHub.

### Create Repository and Push

```bash
cd /Users/daedalus/smart-connections-mcp

# Configure git user (if not already set)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Create repository on GitHub and push
gh repo create smart-connections-mcp \
  --public \
  --description "MCP server that exposes Obsidian Smart Connections vector database to Claude Code via semantic search" \
  --source=. \
  --remote=origin \
  --push
```

This will:
- ✅ Create the repository on GitHub
- ✅ Add remote origin
- ✅ Push all files

## Option 2: Manual Setup (No GitHub CLI)

### Step 1: Configure Git

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Step 2: Create Repository on GitHub

1. Go to https://github.com/new
2. Repository name: `smart-connections-mcp`
3. Description: `MCP server that exposes Obsidian Smart Connections vector database to Claude Code via semantic search`
4. Visibility: **Public** (recommended - it's infrastructure code)
5. **DO NOT** initialize with README (we already have files)
6. Click "Create repository"

### Step 3: Add Files and Push

```bash
cd /Users/daedalus/smart-connections-mcp

# Stage all files
git add .

# Review what will be committed
git status

# Commit
git commit -m "Initial commit: Smart Connections MCP server

- Complete MCP server implementation using official SDK
- Semantic search, find_related, and context_blocks tools
- Fixed NumPy compatibility issues
- Automated install script
- Comprehensive documentation

🤖 Generated with [Claude Code](https://claude.com/claude-code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"

# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/smart-connections-mcp.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 4: Verify

Visit: https://github.com/YOUR_USERNAME/smart-connections-mcp

You should see all your files!

## What Gets Pushed

The following files will be committed (`.gitignore` excludes the rest):

```
✅ server.py                 - MCP server implementation
✅ requirements.txt          - Python dependencies
✅ install.sh                - Automated setup script
✅ .gitignore               - Git exclusions
✅ README.md                - Main documentation
✅ QUICK_ANSWERS.md         - Migration FAQ
✅ DEPLOYMENT.md            - Detailed deployment guide
✅ TROUBLESHOOTING.md       - Debug guide
✅ FIX_SUMMARY.md           - Fix documentation
✅ QUICKSTART.md            - Quick start guide (if exists)
✅ LICENSE                  - License file (if exists)
```

**Not pushed (excluded by .gitignore):**
```
❌ .venv/                   - Virtual environment (recreate on each machine)
❌ __pycache__/            - Python cache
❌ *.pyc                   - Compiled Python files
❌ .DS_Store               - macOS metadata
❌ *.log                   - Log files
```

## Updating the Repository Later

```bash
cd /Users/daedalus/smart-connections-mcp

# Make your changes to files
# ...

# Stage changes
git add .

# Commit
git commit -m "Description of changes"

# Push
git push origin main
```

## Troubleshooting

### "Permission denied (publickey)"

You need to set up SSH keys or use HTTPS with token:

**Option A: Use HTTPS with token**
```bash
git remote set-url origin https://github.com/YOUR_USERNAME/smart-connections-mcp.git
# Git will prompt for username and token when you push
```

**Option B: Set up SSH key**
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add to SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key
cat ~/.ssh/id_ed25519.pub
# Add to GitHub: Settings → SSH and GPG keys → New SSH key
```

### "fatal: remote origin already exists"

```bash
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/smart-connections-mcp.git
```

### "refusing to merge unrelated histories"

This happens if you initialized the repo on GitHub with README:

```bash
git pull origin main --allow-unrelated-histories
git push origin main
```

## License Recommendation

Consider adding a LICENSE file. For this type of infrastructure code, MIT is common:

```bash
cat > LICENSE <<'EOF'
MIT License

Copyright (c) 2025 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

git add LICENSE
git commit -m "Add MIT License"
git push origin main
```

## Next Steps

After pushing:

1. ✅ Add topics/tags on GitHub: `obsidian`, `mcp`, `claude-code`, `semantic-search`
2. ✅ Enable Issues for bug reports
3. ✅ Add repository to your README: Update QUICK_ANSWERS.md and DEPLOYMENT.md with actual repo URL
4. ✅ Share with others!

## Clone URL Format

Once created, your repository will be cloneable via:

**HTTPS:**
```bash
git clone https://github.com/YOUR_USERNAME/smart-connections-mcp.git
```

**SSH:**
```bash
git clone git@github.com:YOUR_USERNAME/smart-connections-mcp.git
```

Update the DEPLOYMENT.md and QUICK_ANSWERS.md documentation with your actual repository URL!
