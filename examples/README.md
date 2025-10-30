# ConsoleWeb MCP Examples

This directory contains examples for using the ConsoleWeb MCP server.

## Quick Start

1. Start the server:
```bash
bundle exec rackup -p 9292
```

2. In another terminal, run the test script:
```bash
./examples/mcp_test.sh
```

## Manual Testing

### Initialize the MCP connection
```bash
curl -X POST http://localhost:9292/mcp/rpc \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {}
  }'
```

### List available tools
```bash
curl -X POST http://localhost:9292/mcp/rpc \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/list",
    "params": {}
  }'
```

### Execute Ruby code
```bash
curl -X POST http://localhost:9292/mcp/rpc \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 3,
    "method": "tools/call",
    "params": {
      "name": "evaluate_ruby_code",
      "arguments": {
        "code": "puts \"Hello, World!\"; 2 + 2"
      }
    }
  }'
```

## Direct JSON-RPC Usage

The MCP server supports direct JSON-RPC requests and responses:

1. Start your ConsoleWeb server:
```bash
bundle exec rackup -p 9292
```

2. Make JSON-RPC requests directly:
```bash
curl -X POST http://localhost:9292/mcp/rpc \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {}
  }'
```

## Notes

- All JSON-RPC responses are returned directly in the HTTP response body
- The server implements MCP protocol version `2025-06-18`

