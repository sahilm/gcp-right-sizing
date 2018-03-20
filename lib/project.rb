# frozen_string_literal: true

require 'googleauth'
require 'google/apis/cloudresourcemanager_v1'

class Project
  def initialize
    @service = Google::Apis::CloudresourcemanagerV1::CloudResourceManagerService.new
    @service.authorization = Google::Auth.get_application_default(['https://www.googleapis.com/auth/cloud-platform'])
  end

  def fetch_all
    @service.fetch_all(items: :projects) do |token|
      @service.list_projects(page_token: token)
    end
  end

  def fetch(project_id)
    @service.get_project(project_id)
  end
end
