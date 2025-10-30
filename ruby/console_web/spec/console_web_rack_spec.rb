require "spec_helper"
require "rack/test"
require "json"
require "console_web"

RSpec.describe ConsoleWeb::RackApp do
  include Rack::Test::Methods
  def app = ConsoleWeb::RackApp.new

  it "rejects non-POST" do
    get "/execute"
    expect(last_response.status).to eq(405)
  end

  it "requires code" do
    post "/execute"
    expect(last_response.status).to eq(422)
  end

  it "evaluates code" do
    post "/execute", code: "1+1"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("=> 2")
  end

  it "evaluates code from JSON" do
    post "/execute", {code: "2*3"}.to_json, {"CONTENT_TYPE" => "application/json"}
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("=> 6")
  end

  it "handles evaluation errors" do
    post "/execute", code: "1/0"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("ZeroDivisionError")
  end

  it "handles syntax errors" do
    post "/execute", code: "def ("
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("SyntaxError")
  end

  it "captures stdout" do
    post "/execute", code: "puts 'hello'; 42"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("=> 42")
    expect(last_response.body).to include("hello")
  end

  it "captures stderr" do
    post "/execute", code: "$stderr.puts 'warning'; 99"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("=> 99")
    expect(last_response.body).to include("warning")
  end
end

