# frozen_string_literal: true

require 'oj'
Oj.mimic_JSON
require 'logger'

require_relative 'lib/recommendations'
require_relative 'lib/project'
require_relative 'lib/record'
require_relative 'lib/vm'

desc 'Generate right sizing data in JSON'
task :generate_right_sizing_data, [:output_file_path, :error_file_path] do |_, args|
  args.with_defaults(output_file_path: 'data/right_sizing_data.jsonlines', error_file_path: 'data/errors')

  FileUtils.mkdir_p([File.dirname(args.output_file_path), File.dirname(args.error_file_path)])

  puts "results -> #{args.output_file_path}"
  puts "errors -> #{args.error_file_path}"

  err_logger = Logger.new(args.error_file_path)
  err_logger.datetime_format = '%Y-%m-%d %H:%M:%S'
  err_logger.formatter = proc do |severity, datetime, _progname, msg|
    "#{datetime} #{severity} -- #{msg}\n"
  end

  File.open(args.output_file_path, 'w') do |file|
    recommendations = Recommendations.new(ENV['GCP_COOKIE'], err_logger)
    vm = VM.new(err_logger)
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
          file.puts record.build.to_json
        else
          err_logger.error("could not find instance #{r[:name]}")
        end
      end
    end
  end
end
