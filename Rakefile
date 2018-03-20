# frozen_string_literal: true

require 'oj'
Oj.mimic_JSON

require_relative 'lib/recommendations'
require_relative 'lib/project'
require_relative 'lib/record'
require_relative 'lib/vm'

desc 'Generate right sizing data in JSON'
task :generate_right_sizing_data, [:file_path] do |_, args|
  args.with_defaults(file_path: 'data/right_sizing_data.json')

  recommendations = Recommendations.new(ENV['GCP_COOKIE'])
  vm = VM.new
  Project.new.fetch_all.each do |project|
    reco = recommendations.for(project.project_id)
    next if reco.empty?
    instances_to_fetch = reco.map do |r|
      {
        project: project.project_id,
        zone: r[:zone],
        name: r[:name],
        fields: 'labels,name,zone',
      }
    end
    instances = vm.fetch(instances_to_fetch, :name)
    reco.each do |r|
      if instances.key?(r[:name])
        record = Record.new(project, r, instances[r[:name]])
        puts record.build.to_json
      else
        STDERR.puts("could not find instance #{r[:name]}")
      end
    end
  end
end
