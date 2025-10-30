# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = "console_web"
  s.version     = "0.1.0"
  s.summary     = "Simple web console executor (Rack-only)"
  s.description = "A Rack app that evaluates Ruby code sent via HTTP."
  s.license     = "MIT"
  s.authors     = ["Raja Jamwal"]
  s.email       = ["linux.experi@gmail.com"]
  s.homepage    = "https://github.com/raja-jamwal/rack-mcp"

  s.files = Dir["lib/**/*", "LICENSE", "README.md"]
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.7.0"

  s.add_dependency "rack", ">= 2.2"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "rackup"
end

