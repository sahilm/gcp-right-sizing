# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require_relative 'parse_json_with_hijacking_prevention'

class Recommendations
  def initialize(cookie, logger)
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
    @logger = logger
  end

  def for(project_id)
    resp = @conn.get '', cmd: 'LIST', pid: project_id
    resp.body[:items]
  rescue Faraday::ClientError => f
    if f.response[:status] == 403
      @logger.warn("got 403 for #{project_id}. Moving on...")
      []
    else
      raise f
    end
  end
end
