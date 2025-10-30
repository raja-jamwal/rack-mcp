# typed: strict
require "stringio"

module ConsoleWeb
  class Executor
    # Evaluates Ruby code and captures stdout/stderr.
    def self.eval(code)
      code = code.to_s
      raise ArgumentError, "code can't be blank" if code.strip.empty?

      out, err = StringIO.new, StringIO.new
      old_out, old_err = $stdout, $stderr
      result = nil
      error = nil

      begin
        $stdout, $stderr = out, err
        result = TOPLEVEL_BINDING.eval(code)
      rescue SyntaxError, StandardError => e
        error = e
      ensure
        $stdout, $stderr = old_out, old_err
      end

      if error
        backtrace = error.backtrace&.first(3)&.join("\n  ")
        return "#{error.class}: #{error.message}\n#{backtrace ? "  #{backtrace}\n" : ""}"
      end

      parts = []
      parts << "=> #{result.inspect}\n" unless result.nil?
      parts << out.string unless out.string.empty?
      parts << err.string unless err.string.empty?
      parts.join
    end
  end
end

