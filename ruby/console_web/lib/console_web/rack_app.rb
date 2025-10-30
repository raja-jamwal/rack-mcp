# typed: strict
require "rack"
require "json"

module ConsoleWeb
  # POST /execute with form or JSON param `code`
  class RackApp
    def call(env)
      req = Rack::Request.new(env)
      return [405, {"Content-Type" => "text/plain"}, ["Method Not Allowed\n"]] unless req.post?

      code = (req.params["code"] || parse_json(req)["code"]).to_s
      return [422, {"Content-Type" => "text/plain"}, ["Error: No code provided\n"]] if code.empty?

      body = ConsoleWeb::Executor.eval(code)
      [200, {"Content-Type" => "text/plain", "Cache-Control" => "no-cache"}, [body]]
    rescue => e
      [500, {"Content-Type" => "text/plain"}, ["Error: #{e.message}\n"]]
    end

    private

    def parse_json(req)
      return {} unless req.media_type == "application/json"
      raw = req.body.read
      req.body.rewind
      JSON.parse(raw)
    rescue
      {}
    end
  end
end

