# Quick Start Guide

## Installation Complete ✅

Your Smart Connections MCP server is installed and configured.

## What You Can Do Now

### 1. Restart Claude Code

The MCP server will auto-start when Claude Code launches.

### 2. Try Semantic Search

Ask Claude Code to search your vault semantically:

```
"Find notes related to self-compassion and transformation"
"What notes discuss recognizing inherent worth?"
"Show me content about peak experiences"
```

Claude will use `semantic_search` instead of Grep - finding notes by **meaning**, not keywords.

### 3. Find Related Notes

```
"What other notes relate to my Aug 29 daily note?"
"Find notes similar to the Ann Shulgin article"
```

Claude will use `find_related` - like the Smart Connections sidebar in Obsidian.

### 4. Build Context for Complex Questions

```
"Analyze themes across my transformation-related notes"
"Synthesize what I've learned about embodiment"
```

Claude will use `get_context_blocks` to gather actual text from most relevant notes.

## How to Know It's Working

When Claude searches your vault, watch for:
- **Semantic matches** that don't use exact keywords
- **Similarity scores** (0-1, higher = more related)
- **Unexpected connections** between notes

## Commands

### Test manually (optional):
```bash
export OBSIDIAN_VAULT_PATH="/Users/daedalus/Library/Mobile Documents/iCloud~md~obsidian/Documents/Daedalus"
python3 ~/smart-connections-mcp/server.py
```

Should load 3,249 embeddings and wait for input.

### Check configuration:
```bash
cat "/Users/daedalus/Library/Mobile Documents/iCloud~md~obsidian/Documents/Daedalus/.claude/mcp.json"
```

## Next Steps

1. **Restart Claude Code** to activate MCP server
2. **Try a semantic search** query
3. **Compare** results to traditional Grep
4. **Read the full docs:** `~/smart-connections-mcp/README.md`

## Troubleshooting

**If MCP server doesn't start:**
- Check Claude Code MCP logs
- Verify Python dependencies: `pip3 list | grep sentence-transformers`
- Test manually with command above

**If no results:**
- Lower similarity threshold in query
- Verify `.smart-env/multi/` has .ajson files
- Check Smart Connections is enabled in Obsidian

## Documentation

- Full usage guide: In your vault at `1-Projects/PKM-System/Smart-Connections-MCP-Usage.md`
- Technical docs: `~/smart-connections-mcp/README.md`
- Implementation plan: `1-Projects/PKM-System/Smart-Connections-Implementation.md`

---

**Status:** ✅ Ready to use (after Claude Code restart)

**Your vector database:** 3,249 embeddings loaded from Smart Connections

**Tools available:**
- `semantic_search` - Find notes by meaning
- `find_related` - Get related notes
- `get_context_blocks` - Build RAG context

Enjoy semantic search in Claude Code! 🎉
