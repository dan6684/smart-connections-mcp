#!/bin/bash
set -e

echo "📦 Smart Connections MCP - GitHub Setup"
echo "========================================"
echo ""

# Check if in correct directory
if [ ! -f "server.py" ]; then
    echo "❌ Error: Please run this from the smart-connections-mcp directory"
    exit 1
fi

# Step 1: Configure git user if needed
echo "Step 1: Git Configuration"
echo "-------------------------"

GIT_NAME=$(git config user.name 2>/dev/null || echo "")
GIT_EMAIL=$(git config user.email 2>/dev/null || echo "")

if [ -z "$GIT_NAME" ]; then
    read -p "Enter your name for git commits: " GIT_NAME
    git config --global user.name "$GIT_NAME"
    echo "✓ Set git user.name to: $GIT_NAME"
fi

if [ -z "$GIT_EMAIL" ]; then
    read -p "Enter your email for git commits: " GIT_EMAIL
    git config --global user.email "$GIT_EMAIL"
    echo "✓ Set git user.email to: $GIT_EMAIL"
fi

echo ""
echo "Git configured as:"
echo "  Name:  $(git config user.name)"
echo "  Email: $(git config user.email)"
echo ""

# Step 2: Add and commit files
echo "Step 2: Preparing files for commit"
echo "-----------------------------------"

# Show what will be committed
echo "Files to be committed:"
git add .
git status --short

echo ""
read -p "Proceed with commit? (y/N): " PROCEED
if [ "$PROCEED" != "y" ] && [ "$PROCEED" != "Y" ]; then
    echo "Aborted."
    exit 0
fi

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

echo "✓ Files committed locally"
echo ""

# Step 3: GitHub repository setup
echo "Step 3: GitHub Repository Setup"
echo "--------------------------------"
echo ""
echo "Please create a repository on GitHub:"
echo ""
echo "  1. Go to: https://github.com/new"
echo "  2. Repository name: smart-connections-mcp"
echo "  3. Description: MCP server that exposes Obsidian Smart Connections vector database to Claude Code via semantic search"
echo "  4. Visibility: Public (recommended)"
echo "  5. DO NOT initialize with README, .gitignore, or license"
echo "  6. Click 'Create repository'"
echo ""

read -p "Enter your GitHub username: " GITHUB_USER

if [ -z "$GITHUB_USER" ]; then
    echo "❌ Error: GitHub username required"
    exit 1
fi

REPO_URL="https://github.com/$GITHUB_USER/smart-connections-mcp.git"

echo ""
echo "Repository URL: $REPO_URL"
echo ""

read -p "Press Enter when repository is created on GitHub..."

# Step 4: Add remote and push
echo ""
echo "Step 4: Pushing to GitHub"
echo "-------------------------"

# Remove existing origin if present
git remote remove origin 2>/dev/null || true

# Add new origin
git remote add origin "$REPO_URL"
echo "✓ Added remote origin: $REPO_URL"

# Rename branch to main if needed
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    git branch -M main
    echo "✓ Renamed branch to 'main'"
fi

# Push
echo ""
echo "Pushing to GitHub..."
git push -u origin main

echo ""
echo "✅ Success! Repository pushed to GitHub"
echo ""
echo "🔗 View your repository at:"
echo "   https://github.com/$GITHUB_USER/smart-connections-mcp"
echo ""
echo "📝 Next steps:"
echo "   1. Add topics on GitHub: obsidian, mcp, claude-code, semantic-search"
echo "   2. Enable Issues for bug reports"
echo "   3. Update clone URL in documentation:"
echo "      - Edit QUICK_ANSWERS.md"
echo "      - Edit DEPLOYMENT.md"
echo "      - Replace placeholder URLs with:"
echo "        https://github.com/$GITHUB_USER/smart-connections-mcp.git"
echo ""
echo "🎉 Done!"
