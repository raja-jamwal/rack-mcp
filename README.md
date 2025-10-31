# RackMcp MCP Server

A Ruby gem that implements the Model Context Protocol (MCP) to provide AI assistants with Ruby code execution capabilities. Works with Rails, Sinatra, Hanami, Roda, and any other Rack-based framework. The code is executed in your application's context for debugging and investigation. Think of it giving AI assistant lighting-speed access to ruby console without the need to write script, reload or restart.

<img src="docs/assets/screen.gif" alt="rails console mcp in cursor" width="400"/>

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rack_mcp", git: "https://github.com/raja-jamwal/rack-mcp.git"
```

Or install locally for development:

```bash
bundle install
```

## Usage

### Mounting the MCP Server

**Rails** (`config/routes.rb`):
```ruby
require "rack_mcp/mcp/server"

Rails.application.routes.draw do
  mount RackMcp::MCP::Server.new => "/mcp"
end
```

**Rack** (`config.ru`):
```ruby
require "rack_mcp"
require "rack_mcp/mcp/server"

map "/mcp" do
  run RackMcp::MCP::Server.new
end
```

**Sinatra**:
```ruby
require "rack_mcp/mcp/server"

mount RackMcp::MCP::Server.new, at: "/mcp"
```

### Starting the Server

```bash
# Standalone with Rackup
bundle exec rackup -p 9292

# With Rails
bundle exec rails server
```

## MCP Protocol

### Endpoint

The MCP server exposes a single JSON-RPC endpoint:

- **POST /mcp/rpc** - JSON-RPC request and response

### Available Tools

**evaluate_ruby_code**
- Description: Evaluates Ruby code and returns the result with captured stdout/stderr
- Parameters:
  - `code` (string, required): Ruby code to execute

## Connecting AI Assistants

### Cursor/ Claude Desktop

Add to your MCP client (cusor, claude etc).

```json
{
  "mcpServers": {
    "rails-mcp": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "http://localhost:3001/mcp/rpc"
      ]
    }
  }
}
```

![MCP integration in Cursor](docs/assets/mcp-in-cursor.png)

### Other MCP Clients

Any MCP-compatible client can connect to the server by making JSON-RPC requests to the `/mcp/rpc` endpoint.

## Testing

Run the test suite:

```bash
bundle exec rspec
```

## Security Warning

⚠️ **This gem executes arbitrary Ruby code.** 

**Important security considerations:**
- Only use in development environments
- Never expose this endpoint to the public internet without authentication
- Implement proper authentication and authorization in production
- Consider running in a sandboxed or containerized environment
- Use network-level restrictions to limit access

## Concurrency Note

This gem uses global `$stdout/$stderr` redirection during evaluation, which can clash in multi-threaded servers. For production use with concurrency, consider:
- Running in a single worker/thread mode
- Isolating evaluation per request (e.g., via `fork`)
- Using a dedicated job worker for code execution

## License

MIT License - see LICENSE file for details.

