# ConsoleWeb

A simple, Rack-only Ruby gem that evaluates Ruby code sent via HTTP. Works with Rails, Sinatra, Hanami, Roda, and any other Rack-based framework.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "console_web",
    git: "https://github.com/raja-jamwal/rack-mcp.git",
    glob: "ruby/console_web/*.gemspec"
```

Or install locally for development:

```bash
cd ruby/console_web
bundle install
```

## Quick Start (Standalone)

Run the included `config.ru` for quick testing:

```bash
cd ruby/console_web
bundle exec rackup -p 9292
```

Then visit http://localhost:9292 in your browser or:

```bash
curl -X POST http://localhost:9292/execute -d "code=puts 'Hello!'"
```

## Usage

### Rails

Mount the Rack app in `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount ConsoleWeb::RackApp.new => "/console"
end
```

Now `POST /console/execute` with `code=1+1`.

### Plain Rack / config.ru

```ruby
require "console_web"

map "/console" do
  run ConsoleWeb::RackApp.new
end
```

### Sinatra / Roda / Hanami

Add it to `config.ru` exactly like the Rack example above (these frameworks boot via Rack).

## API

The gem exposes a single endpoint:

**POST /execute**

Parameters:
- `code` (required): Ruby code to evaluate

Accepts both form-encoded and JSON requests:

```bash
# Form-encoded
curl -X POST http://localhost:3000/console/execute -d "code=1+1"

# JSON
curl -X POST http://localhost:3000/console/execute \
  -H "Content-Type: application/json" \
  -d '{"code":"1+1"}'
```

Response:
- 200: Success with evaluation result (includes runtime errors with backtrace)
- 405: Method not allowed (non-POST)
- 422: No code provided
- 500: Internal server error (unexpected failures only)

**Note:** Ruby runtime errors (SyntaxError, ZeroDivisionError, etc.) return 200 with error details and backtrace for easier debugging.

## Testing

Run the test suite:

```bash
bundle exec rspec
```

## Security Warning

⚠️ **This gem executes arbitrary Ruby code.** Only use it in development environments or with proper authentication and authorization in place.

## Concurrency Note

This gem uses global `$stdout/$stderr` redirection during evaluation, which can clash in multi-threaded servers. For production use with concurrency, consider:
- Running in a single worker/thread
- Isolating evaluation per request (e.g., via `fork`)
- Using a job worker for code execution

## License

MIT License - see LICENSE file for details.

