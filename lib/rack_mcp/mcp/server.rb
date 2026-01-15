# frozen_string_literal: true
require "json"
require "rack"
require_relative "../version"
require_relative "../executor"

module RackMcp
  module MCP
    # Minimal MCP-over-HTTP (JSON-RPC) server.
    # Single-session, single-process demo: fine for local/dev usage.
    class Server
      def initialize
        @tools = [
          {
            "name" => "evaluate_ruby_code",
            "description" => "Evaluate the Ruby code in the context of the current application, returns the result of the code execution",
            "inputSchema" => {
              "type" => "object",
              "properties" => {
                "code" => {
                  "type" => "string",
                  "description" => "The Ruby code to evaluate, must be a valid Ruby expression or statement"
                }
              },
              "required" => ["code"]
            }
          }
        ]
      end

      def call(env)
        req = Rack::Request.new(env)
        
        # Check for token authentication
        unless authorized?(req)
          return [401, {"content-type" => "application/json"}, [JSON.generate({
            "error" => "Unauthorized: Invalid or missing token"
          })]]
        end
        
        case [req.request_method, req.path_info]
        when ["POST", "/rpc"] then handle_rpc(req)
        else
          [404, {"content-type" => "text/plain"}, ["Not Found\n"]]
        end
      end

      private

      def authorized?(req)
        expected_token = ENV["RACK_MCP_TOKEN"]
        
        # If no token is configured in ENV, consider it unauthorized
        return false if expected_token.nil? || expected_token.empty?
        
        # Token must be at least 8 characters long
        return false if expected_token.length < 8
        
        # Check if the token query parameter matches the expected token
        provided_token = req.params["token"]
        provided_token == expected_token
      end

      def handle_rpc(req)
        payload = JSON.parse(req.body.read)
        id      = payload["id"]
        method  = payload["method"]

        result =
          case method
          when "initialize"
            {
              "protocolVersion" => "2025-06-18",
              "serverInfo"      => { "name" => "rack_mcp", "version" => RackMcp::VERSION },
              "capabilities"    => { "tools" => {} }
            }

          when "tools/list"
            { "tools" => @tools }

          when "tools/call"
            name = payload.dig("params", "name")
            args = payload.dig("params", "arguments") || {}

            if name == "evaluate_ruby_code"
              out = RackMcp::Executor.eval(args["code"].to_s)
              { "content" => [{ "type" => "text", "text" => out }] }
            else
              raise "Unknown tool: #{name}"
            end

          else
            raise "Unknown method: #{method}"
          end

        # Return JSON-RPC response directly
        response = { "jsonrpc" => "2.0", "id" => id, "result" => result }
        [200, {"content-type" => "application/json"}, [JSON.generate(response)]]
      rescue => e
        response = { "jsonrpc" => "2.0", "id" => id, "error" => { "code" => -32601, "message" => e.message } }
        [200, {"content-type" => "application/json"}, [JSON.generate(response)]]
      end
    end
  end
end

