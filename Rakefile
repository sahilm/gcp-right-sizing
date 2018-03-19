# frozen_string_literal: true

require 'oj'
Oj.mimic_JSON

require_relative 'lib/recommendations'

desc 'Generate right sizing data in JSON'
task :generate_right_sizing_data, [:file_path] do |_, args|
  args.with_defaults(file_path: 'data/right_sizing_data.json')
  recommendations = Recommendations.new(ENV['GCP_COOKIE'])
  recommendations.for('')
end
