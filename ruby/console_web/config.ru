require_relative "lib/console_web"

# Example config.ru for running the console web app standalone
# Run with: bundle exec rackup -p 9292
# Then POST to: http://localhost:9292/execute

map "/execute" do
  run ConsoleWeb::RackApp.new
end

# Optionally add a root path with usage info
map "/" do
  run lambda { |env|
    [
      200,
      {"Content-Type" => "text/html"},
      [<<~HTML
        <html>
        <head><title>ConsoleWeb</title></head>
        <body>
          <h1>ConsoleWeb Console</h1>
          <p>POST Ruby code to <code>/execute</code> with a <code>code</code> parameter.</p>
          
          <h2>Try it:</h2>
          <form method="POST" action="/execute">
            <textarea name="code" rows="10" cols="60" placeholder="Enter Ruby code...">puts 'Hello, World!'
1 + 1</textarea>
            <br>
            <button type="submit">Execute</button>
          </form>
          
          <h3>cURL Example:</h3>
          <pre>curl -X POST http://localhost:9292/execute -d "code=1+1"</pre>
          
          <h3>JSON Example:</h3>
          <pre>curl -X POST http://localhost:9292/execute \\
  -H "Content-Type: application/json" \\
  -d '{"code":"puts Time.now"}'</pre>
        </body>
        </html>
      HTML
      ]
    ]
  }
end

