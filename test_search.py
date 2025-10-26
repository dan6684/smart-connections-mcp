#!/usr/bin/env python3
"""Direct test of Smart Connections semantic search"""

import sys
import os
sys.path.insert(0, '/Users/daedalus/smart-connections-mcp')

# Set environment
os.environ['OBSIDIAN_VAULT_PATH'] = '/Users/daedalus/Library/Mobile Documents/iCloud~md~obsidian/Documents/Daedalus'

from server import SmartConnectionsDatabase

print("Initializing Smart Connections database...")
db = SmartConnectionsDatabase('/Users/daedalus/Library/Mobile Documents/iCloud~md~obsidian/Documents/Daedalus')

print("\n1. Testing semantic_search with query: 'self-compassion'")
results = db.semantic_search(query="self-compassion", limit=5, min_similarity=0.3)

print(f"\nFound {len(results)} results:")
for i, r in enumerate(results, 1):
    print(f"\n{i}. {r['path']}")
    print(f"   Similarity: {r['similarity']:.3f}")
    print(f"   Preview: {r['text_preview'][:100]}...")
    if r.get('metadata'):
        print(f"   Metadata: {r['metadata']}")

print("\n\n2. Testing find_related for a daily note")
related = db.find_related(file_path="DailyNotes/2025-10-25.md", limit=5)

print(f"\nFound {len(related)} related notes to DailyNotes/2025-10-25.md:")
for i, r in enumerate(related, 1):
    print(f"\n{i}. {r['path']}")
    print(f"   Similarity: {r['similarity']:.3f}")

print("\n\n3. Testing get_context_blocks")
blocks = db.get_context_blocks(query="transformation through embodiment", max_blocks=3)

print(f"\nFound {len(blocks)} context blocks:")
for i, b in enumerate(blocks, 1):
    print(f"\n{i}. {b['path']} (lines {b.get('lines', 'N/A')})")
    print(f"   Similarity: {b['similarity']:.3f}")
    print(f"   Text: {b['text'][:150]}...")

print("\n\n✅ All semantic search tests completed successfully!")
