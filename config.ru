require_relative "lib/rack_mcp"
require_relative "lib/rack_mcp/mcp/server"

# Example config.ru for running the MCP server
# Run with: bundle exec rackup -p 9292
# MCP endpoint: POST /mcp/rpc

map "/mcp" do
  run RackMcp::MCP::Server.new
end

# Root path with usage info
map "/" do
  run lambda { |env|
    [
      200,
      {"content-type" => "text/html"},
      [<<~HTML
        <html>
        <head><title>RackMcp MCP Server</title></head>
        <body>
          <h1>RackMcp - Model Context Protocol Server</h1>
          <p>This server provides Ruby code execution capabilities via the Model Context Protocol (MCP).</p>
          
          <h2>MCP Endpoint</h2>
          <ul>
            <li><strong>POST /mcp/rpc</strong> - JSON-RPC endpoint for MCP communication</li>
          </ul>
          
          <h3>Test MCP Initialize:</h3>
          <pre>curl -X POST http://localhost:9292/mcp/rpc \\
  -H "Content-Type: application/json" \\
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {}
  }'</pre>

          <h3>List Available Tools:</h3>
          <pre>curl -X POST http://localhost:9292/mcp/rpc \\
  -H "Content-Type: application/json" \\
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/list",
    "params": {}
  }'</pre>

          <h3>Execute Ruby Code:</h3>
          <pre>curl -X POST http://localhost:9292/mcp/rpc \\
  -H "Content-Type: application/json" \\
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
  }'</pre>
        </body>
        </html>
      HTML
      ]
    ]
  }
end

