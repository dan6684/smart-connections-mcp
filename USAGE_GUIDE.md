# Smart Connections MCP - Usage Guide

## When to Use Semantic Search vs. Text Search

### Quick Decision Matrix

| Search Goal | Best Tool | Why |
|-------------|-----------|-----|
| Find exact code/syntax | `Grep` | Precise pattern matching |
| Find specific error message | `Grep` | Exact string match |
| Find file by name | `Glob` | File name patterns |
| Explore concepts/themes | `semantic_search` | Meaning-based discovery |
| Find related ideas | `semantic_search` | Conceptual similarity |
| Recall "something about X" | `semantic_search` | Fuzzy memory retrieval |
| Find similar notes to current | `find_related` | Contextual connections |
| Build context for AI response | `get_context_blocks` | RAG/grounding |

---

## Understanding the Tools

### Text Search (Grep) - Best For:

**✅ Use When You Need:**
- Exact keywords: `grep "OBSIDIAN_VAULT_PATH"`
- Code patterns: `grep "def.*search"`
- Error messages: `grep "Error: timeout"`
- Specific tags: `grep "#burning-man"`
- File names: `grep "filename: .*\.py"`
- URLs, IDs, specific strings

**Example Use Cases:**
```bash
# Find all Python files with "async def"
grep "async def" --glob "*.py"

# Find specific error
grep "NumPy 2.x incompatibility"

# Find tag usage
grep "#embodiment"
```

**Limitations:**
- ❌ Doesn't understand synonyms (search "car" won't find "automobile")
- ❌ Doesn't understand concepts (search "happy" won't find "joyful")
- ❌ Requires exact or regex patterns
- ❌ Case-sensitive by default

---

### Semantic Search - Best For:

**✅ Use When You Need:**
- **Conceptual exploration**: "What do I know about transformation?"
- **Fuzzy recall**: "That note about feeling valuable at a festival"
- **Theme discovery**: "Self-compassion and embodiment"
- **Synonym handling**: Search "vehicle" finds "car", "automobile", "truck"
- **Related ideas**: Search "meditation" might find "mindfulness", "presence", "breathing"
- **Cross-domain connections**: "Dancing" might surface therapy notes about embodiment

**Example Use Cases:**
```javascript
// Explore a theme
semantic_search({
  query: "personal transformation through challenging experiences",
  limit: 10
})

// Find something you remember vaguely
semantic_search({
  query: "feeling like a treasure or being valuable after intense experience",
  limit: 5
})

// Discover related concepts
semantic_search({
  query: "body wisdom somatic awareness movement",
  limit: 8,
  min_similarity: 0.4  // Higher threshold for more relevant results
})
```

**Limitations:**
- ❌ Slower than text search (requires model inference)
- ❌ Not precise for exact matches
- ❌ Depends on Smart Connections having indexed the vault
- ❌ May return conceptually similar but contextually wrong results

---

## How Claude Code Decides (Heuristics)

### Automatic Selection Criteria:

Claude Code can use these heuristics to choose automatically:

#### **Use Grep When:**
1. Query contains exact strings in quotes: `"OBSIDIAN_VAULT_PATH"`
2. Query contains regex patterns: `def.*\(.*\)`
3. Query is asking for "all files with X"
4. Query mentions specific error messages
5. Query contains code syntax: `import numpy`, `function foo()`
6. Query asks for tags: `#tag-name`

#### **Use Semantic Search When:**
1. Query is conceptual: "ideas about...", "notes on...", "what do I know about..."
2. Query describes theme/feeling: "transformation", "challenging experience"
3. Query is vague/fuzzy: "something I wrote about feeling valuable"
4. User says "related to", "similar to", "like"
5. Query is a question: "What did I learn about embodiment?"
6. Query uses natural language description

#### **Use Both (Hybrid Approach):**
1. Start with semantic search for discovery
2. Follow up with grep for precise details
3. Example: Find notes about "meditation" (semantic), then grep for specific technique names

---

## Practical Examples

### Example 1: Debugging Code Issue

**User:** "Find where we set the OBSIDIAN_VAULT_PATH environment variable"

**Best Tool:** `Grep`
```bash
grep "OBSIDIAN_VAULT_PATH" --glob "*.json" --glob "*.sh"
```

**Why:** Exact string match, looking for code/config

---

### Example 2: Exploring Personal Growth

**User:** "What have I written about personal transformation?"

**Best Tool:** `semantic_search`
```javascript
semantic_search({
  query: "personal transformation growth change",
  limit: 10,
  min_similarity: 0.3
})
```

**Why:** Conceptual exploration, fuzzy theme

---

### Example 3: Hybrid Search

**User:** "Find notes about Burning Man, especially the emotional/transformative aspects"

**Approach:**
1. **First:** Semantic search to discover relevant notes
   ```javascript
   semantic_search({
     query: "burning man transformation emotional experience",
     limit: 15
   })
   ```

2. **Then:** Grep to verify/refine
   ```bash
   grep "burning man|BRC|playa" --glob "*.md" -i
   ```

3. **Review both:** Semantic search finds conceptual matches, grep finds all mentions

---

## Tool Descriptions for Claude Code

When configuring MCP tools for Claude Code, use these descriptions to help it choose:

### semantic_search
```json
{
  "name": "semantic_search",
  "description": "Search vault using semantic similarity (not keyword matching). Finds notes related to query MEANING, not just exact words. Use for: exploring themes, finding related concepts, fuzzy recall ('something about...'), discovering connections. Example: 'transformation through embodiment' finds relevant notes even without those exact words."
}
```

### find_related
```json
{
  "name": "find_related",
  "description": "Find notes semantically related to a specific file. Like Smart Connections sidebar in Obsidian. Use when: working on a note and want to find related ideas, building context, discovering connections. Returns files ranked by conceptual similarity."
}
```

### get_context_blocks
```json
{
  "name": "get_context_blocks",
  "description": "Get best text blocks for a query (for RAG/context building). Returns actual TEXT CONTENT, not just paths. Use when: need to quote/reference specific passages, build grounded AI responses, find exact wording on a topic. Higher similarity threshold than semantic_search."
}
```

---

## Performance Considerations

### Semantic Search Performance:
- **First search:** ~20 seconds (loads model)
- **Subsequent searches:** ~100-500ms
- **Memory:** ~50MB (model + embeddings cached)

### When to Prefer Grep:
- Very large vaults (>10k notes) - grep is faster for exact matches
- Real-time search (as-you-type) - grep is instant
- Code repositories - syntax patterns need exact matching

### When to Prefer Semantic:
- Knowledge bases - concepts more important than exact words
- Personal notes - you remember themes, not exact wording
- Research - discovering connections across domains

---

## Tuning Search Parameters

### min_similarity Threshold Guide:

| Threshold | What You Get | Use Case |
|-----------|--------------|----------|
| **0.2** | Very broad, many results | Initial exploration, "show me everything related" |
| **0.3** | Default, good balance | General semantic search |
| **0.4** | More focused results | When you want higher relevance |
| **0.5** | Very specific matches | Finding near-duplicates or very similar content |
| **0.6+** | Almost identical content | Deduplication, finding exact semantic matches |

### limit Parameter:

| Limit | Use Case |
|-------|----------|
| **5** | Quick overview, top results only |
| **10** | Default, good for most searches |
| **20** | Comprehensive exploration |
| **50+** | Research, finding all related content |

---

## Best Practices for Claude Code Integration

### 1. **Start Semantic, Refine with Grep**

```javascript
// User: "Find my notes about meditation"

// Step 1: Semantic search for discovery
const results = semantic_search({
  query: "meditation mindfulness practice breathing",
  limit: 10
})

// Step 2: If user wants specifics, use grep
// "Which notes mention 'Vipassana'?"
grep "Vipassana" paths_from_semantic_results
```

### 2. **Use Context Blocks for AI Responses**

```javascript
// User: "What did I learn about embodiment?"

// Get actual text content
const blocks = get_context_blocks({
  query: "embodiment body awareness somatic",
  max_blocks: 5
})

// Use blocks.text in AI response for grounded answers
```

### 3. **Use find_related for Contextual Work**

```javascript
// User is reading: "DailyNotes/2025-10-25.md"

// Find related notes
const related = find_related({
  file_path: "DailyNotes/2025-10-25.md",
  limit: 10
})

// Shows: Ann Shulgin note, other BM notes, transformation themes
```

### 4. **Combine Tools for Power Users**

```javascript
// "Find all my Burning Man notes and tell me about common themes"

// 1. Grep for all BM files
const files = grep("burning man|BRC|playa", glob: "*.md")

// 2. Semantic search for themes
const themes = semantic_search({
  query: "burning man themes transformation community art",
  limit: 20
})

// 3. Get specific content
const content = get_context_blocks({
  query: "burning man personal insight",
  max_blocks: 10
})
```

---

## User Prompting Guide

### Good Semantic Search Prompts:

✅ **Natural language descriptions:**
- "What do I know about personal transformation?"
- "Find notes about feeling valuable or recognizing self-worth"
- "Show me ideas related to embodiment and dance"

✅ **Conceptual queries:**
- "Challenging experiences that led to growth"
- "Connections between psychedelics and self-discovery"
- "Body wisdom and somatic practices"

✅ **Fuzzy recall:**
- "That note where I felt like a treasure"
- "Something about dancing for 10 hours"
- "The experience at the festival where I felt beautiful"

### Good Grep Prompts:

✅ **Exact strings:**
- "Find all files mentioning 'OBSIDIAN_VAULT_PATH'"
- "Show me errors containing 'timeout'"
- "Files with tag #burning-man"

✅ **Code patterns:**
- "Find all Python async functions"
- "Show me where we import numpy"
- "Files with TODO comments"

---

## Troubleshooting

### "Semantic search returns irrelevant results"

**Solutions:**
1. Increase `min_similarity` threshold (try 0.4 or 0.5)
2. Make query more specific: "Burning Man playa dance 2025" vs just "dance"
3. Use `get_context_blocks` instead (higher threshold by default)

### "Semantic search is too slow"

**Solutions:**
1. First search is always slow (model loading) - subsequent searches are fast
2. Reduce `limit` parameter (10 instead of 50)
3. Consider using grep for initial filtering, then semantic search on subset

### "Can't find note I know exists"

**Possible Issues:**
1. Smart Connections hasn't indexed that file yet
   - **Fix:** Open Obsidian, let Smart Connections re-index
2. Note was created after last Smart Connections index
   - **Fix:** Trigger re-index in Obsidian
3. Using exact keywords that aren't in the note
   - **Fix:** Use semantic search with conceptual terms instead

### "Not sure which tool to use"

**Try both!**
```javascript
// Use semantic search first
const semantic = semantic_search({query: "your query", limit: 5})

// Then grep to verify
const exact = grep("keyword")

// Compare results
```

---

## Future Enhancements

Potential improvements to the decision logic:

1. **Hybrid search by default**
   - Run both semantic + grep in parallel
   - Merge/rank results by relevance

2. **Query analysis**
   - Automatically detect query type (conceptual vs. exact)
   - Route to appropriate tool

3. **Learning user preferences**
   - Track which tool works better for user's query patterns
   - Adapt routing over time

4. **Result re-ranking**
   - Combine semantic similarity + recency + user access patterns
   - Personalized relevance scoring

---

## Summary: Quick Reference

| I want to... | Use This | Example Query |
|--------------|----------|---------------|
| Find exact code/config | `grep` | `grep "VAULT_PATH"` |
| Explore a theme | `semantic_search` | `"transformation experiences"` |
| Find similar to current note | `find_related` | `file_path: "current.md"` |
| Get actual text for AI context | `get_context_blocks` | `"embodiment dance"` |
| Find file by name | `glob` | `glob "**/*burning*.md"` |
| Remember vague concept | `semantic_search` | `"feeling valuable treasure"` |
| Find all mentions | `grep` | `grep "burning man" -i` |
| Discover connections | `semantic_search` + `find_related` | Combined approach |

---

**The key insight:** Text search finds what you SAY, semantic search finds what you MEAN. Use both for maximum power! 🚀
