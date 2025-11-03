#!/bin/bash
# MCP Server Test Script

BASE_URL="http://localhost:9292/mcp"

echo "=== Testing MCP Server ==="
echo ""

echo "1. Initialize Connection"
curl -X POST ${BASE_URL}/rpc \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {}
  }'
echo -e "\n"

echo "2. List Available Tools"
curl -X POST ${BASE_URL}/rpc \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/list",
    "params": {}
  }'
echo -e "\n"

echo "3. Execute Ruby Code (1 + 1)"
curl -X POST ${BASE_URL}/rpc \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 3,
    "method": "tools/call",
    "params": {
      "name": "evaluate_ruby_code",
      "arguments": {
        "code": "1 + 1"
      }
    }
  }'
echo -e "\n"

echo "4. Execute Ruby Code with Output"
curl -X POST ${BASE_URL}/rpc \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 4,
    "method": "tools/call",
    "params": {
      "name": "evaluate_ruby_code",
      "arguments": {
        "code": "puts \"Hello from MCP!\"; Time.now"
      }
    }
  }'
echo -e "\n"

echo "All responses are returned directly as JSON-RPC messages."

