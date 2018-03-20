# frozen_string_literal: true

require 'googleauth'
require 'google/apis/compute_v1'

class VM
  def initialize
    @service = Google::Apis::ComputeV1::ComputeService.new
    @service.authorization = Google::Auth.get_application_default(['https://www.googleapis.com/auth/cloud-platform'])
  end

  def fetch(instances)
    response = []
    @service.batch do |service|
      instances.each do |i|
        service.get_instance(i[:project], i[:zone], i[:name], fields: i[:fields]) do |res, err|
          raise err if err
          response << res
        end
      end
    end
    response
  end
end
