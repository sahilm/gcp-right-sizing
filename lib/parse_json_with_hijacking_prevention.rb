# frozen_string_literal: true

require 'faraday'

class ParseJsonWithHijackingPrevention
  attr_reader :options

  def initialize(app, options = {})
    @app = app
    @options = options
  end

  def call(env)
    @app.call(env).on_complete do |response_env|
      if json_response?(env) && !response_env[:body].strip.empty?
        response_env[:body] = JSON.parse(response_env[:body].lines.to_a[1..-1].join, symbolize_names: true)
      end
    end
  end

  def json_response?(env)
    env[:response_headers].key?('Content-Type') &&
      env[:response_headers]['Content-Type'].start_with?('application/json')
  end
end

Faraday::Response.register_middleware parse_json_with_hijacking_prevention: ParseJsonWithHijackingPrevention
