# frozen_string_literal: true

require "spec_helper"
require "rack_mcp/mcp/server"
require "rack/test"
require "json"

RSpec.describe RackMcp::MCP::Server do
  include Rack::Test::Methods

  let(:app) { described_class.new }

  describe "routing" do
    it "returns 404 for unknown paths" do
      get "/unknown"
      expect(last_response.status).to eq(404)
    end
  end

  describe "POST /rpc" do
    context "initialize method" do
      it "returns protocol version and server info" do
        payload = {
          "jsonrpc" => "2.0",
          "id" => 1,
          "method" => "initialize",
          "params" => {}
        }

        post "/rpc", JSON.generate(payload), { "CONTENT_TYPE" => "application/json" }

        expect(last_response.status).to eq(200)
        response = JSON.parse(last_response.body)
        expect(response["jsonrpc"]).to eq("2.0")
        expect(response["id"]).to eq(1)
        expect(response["result"]).to be_a(Hash)
        expect(response["result"]["protocolVersion"]).to eq("2025-06-18")
        expect(response["result"]["serverInfo"]["name"]).to eq("rack_mcp")
      end
    end

    context "tools/list method" do
      it "returns available tools" do
        payload = {
          "jsonrpc" => "2.0",
          "id" => 2,
          "method" => "tools/list",
          "params" => {}
        }

        post "/rpc", JSON.generate(payload), { "CONTENT_TYPE" => "application/json" }

        expect(last_response.status).to eq(200)
        response = JSON.parse(last_response.body)
        expect(response["jsonrpc"]).to eq("2.0")
        expect(response["id"]).to eq(2)
        expect(response["result"]["tools"]).to be_an(Array)
        expect(response["result"]["tools"].first["name"]).to eq("evaluate_ruby_code")
      end
    end

    context "tools/call method" do
      it "evaluates Ruby code successfully" do
        payload = {
          "jsonrpc" => "2.0",
          "id" => 3,
          "method" => "tools/call",
          "params" => {
            "name" => "evaluate_ruby_code",
            "arguments" => { "code" => "1 + 1" }
          }
        }

        post "/rpc", JSON.generate(payload), { "CONTENT_TYPE" => "application/json" }

        expect(last_response.status).to eq(200)
        response = JSON.parse(last_response.body)
        expect(response["jsonrpc"]).to eq("2.0")
        expect(response["id"]).to eq(3)
        expect(response["result"]["content"]).to be_an(Array)
        expect(response["result"]["content"].first["type"]).to eq("text")
      end

      it "handles unknown tools" do
        payload = {
          "jsonrpc" => "2.0",
          "id" => 4,
          "method" => "tools/call",
          "params" => {
            "name" => "unknown_tool",
            "arguments" => {}
          }
        }

        post "/rpc", JSON.generate(payload), { "CONTENT_TYPE" => "application/json" }

        expect(last_response.status).to eq(200)
        response = JSON.parse(last_response.body)
        expect(response["jsonrpc"]).to eq("2.0")
        expect(response["id"]).to eq(4)
        expect(response["error"]).to be_a(Hash)
        expect(response["error"]["message"]).to include("Unknown tool")
      end
    end

    context "unknown method" do
      it "returns error for unknown JSON-RPC method" do
        payload = {
          "jsonrpc" => "2.0",
          "id" => 5,
          "method" => "unknown/method",
          "params" => {}
        }

        post "/rpc", JSON.generate(payload), { "CONTENT_TYPE" => "application/json" }

        expect(last_response.status).to eq(200)
        response = JSON.parse(last_response.body)
        expect(response["jsonrpc"]).to eq("2.0")
        expect(response["id"]).to eq(5)
        expect(response["error"]).to be_a(Hash)
        expect(response["error"]["message"]).to include("Unknown method")
      end
    end

    context "malformed JSON" do
      it "handles parse errors gracefully" do
        post "/rpc", "not valid json", { "CONTENT_TYPE" => "application/json" }

        expect(last_response.status).to eq(200)
        response = JSON.parse(last_response.body)
        expect(response["jsonrpc"]).to eq("2.0")
        expect(response["error"]).to be_a(Hash)
      end
    end
  end

  describe "end-to-end MCP flow" do
    it "completes initialize -> tools/list -> tools/call sequence" do
      # Step 1: Initialize
      init_payload = {
        "jsonrpc" => "2.0",
        "id" => 1,
        "method" => "initialize",
        "params" => {}
      }
      post "/rpc", JSON.generate(init_payload), { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(200)
      init_response = JSON.parse(last_response.body)
      expect(init_response["result"]["protocolVersion"]).to eq("2025-06-18")

      # Step 2: List tools
      list_payload = {
        "jsonrpc" => "2.0",
        "id" => 2,
        "method" => "tools/list",
        "params" => {}
      }
      post "/rpc", JSON.generate(list_payload), { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(200)
      list_response = JSON.parse(last_response.body)
      expect(list_response["result"]["tools"]).to be_an(Array)

      # Step 3: Call evaluate_ruby_code tool
      call_payload = {
        "jsonrpc" => "2.0",
        "id" => 3,
        "method" => "tools/call",
        "params" => {
          "name" => "evaluate_ruby_code",
          "arguments" => { "code" => "puts 'Hello, MCP!'; 42" }
        }
      }
      post "/rpc", JSON.generate(call_payload), { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(200)
      call_response = JSON.parse(last_response.body)
      expect(call_response["result"]["content"]).to be_an(Array)
    end
  end
end

