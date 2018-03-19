# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require_relative 'parse_json_with_hijacking_prevention'

class Recommendations
  def initialize(cookie)
    @conn = Faraday.new(url: 'https://console.cloud.google.com/m/gce/recommendations',
                        headers: {
                          accept: 'application/json',
                          cookie: cookie,
                        }) do |faraday|
      faraday.response :parse_json_with_hijacking_prevention
      faraday.use FaradayMiddleware::FollowRedirects
      faraday.use FaradayMiddleware::Gzip
      faraday.use Faraday::Response::RaiseError
      faraday.adapter :typhoeus
    end
  end

  def for(project_id)
    @conn.get '', cmd: 'LIST', pid: project_id
  end
end
