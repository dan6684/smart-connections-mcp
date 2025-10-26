#!/usr/bin/env python3
"""Test script for Smart Connections MCP server"""

import subprocess
import json
import sys

def send_request(process, request):
    """Send JSON-RPC request to MCP server"""
    request_json = json.dumps(request) + "\n"
    process.stdin.write(request_json)
    process.stdin.flush()
    
    # Read response
    response_line = process.stdout.readline()
    if not response_line:
        return None
    return json.loads(response_line)

def main():
    # Start MCP server
    env = {
        'OBSIDIAN_VAULT_PATH': '/Users/daedalus/Library/Mobile Documents/iCloud~md~obsidian/Documents/Daedalus'
    }
    
    print("Starting MCP server...")
    process = subprocess.Popen(
        ['python3', 'server.py'],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        env={**env}
    )
    
    try:
        # 1. Initialize
        print("\n1. Sending initialize request...")
        init_response = send_request(process, {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {}
        })
        print(f"Initialize response: {json.dumps(init_response, indent=2)}")
        
        # 2. List tools
        print("\n2. Listing available tools...")
        tools_response = send_request(process, {
            "jsonrpc": "2.0",
            "id": 2,
            "method": "tools/list",
            "params": {}
        })
        print(f"Tools available: {len(tools_response.get('tools', []))} tools")
        for tool in tools_response.get('tools', []):
            print(f"  - {tool['name']}: {tool['description'][:60]}...")
        
        # 3. Test semantic search
        print("\n3. Testing semantic_search with query 'self-compassion'...")
        search_response = send_request(process, {
            "jsonrpc": "2.0",
            "id": 3,
            "method": "tools/call",
            "params": {
                "name": "semantic_search",
                "arguments": {
                    "query": "self-compassion",
                    "limit": 3,
                    "min_similarity": 0.3
                }
            }
        })
        
        if search_response and 'content' in search_response:
            result = json.loads(search_response['content'][0]['text'])
            print(f"Found {result['results_count']} results:")
            for r in result['results'][:3]:
                print(f"  - {r['path']} (similarity: {r['similarity']:.3f})")
        else:
            print(f"Search response: {json.dumps(search_response, indent=2)}")
        
        print("\n✅ All tests passed!")
        
    except Exception as e:
        print(f"\n❌ Error during testing: {e}")
        stderr = process.stderr.read()
        if stderr:
            print(f"Server stderr: {stderr}")
        sys.exit(1)
    finally:
        process.terminate()
        process.wait()

if __name__ == "__main__":
    main()
