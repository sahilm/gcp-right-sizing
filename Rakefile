# frozen_string_literal: true

require 'oj'
Oj.mimic_JSON
require 'logger'
require 'ruby-progressbar'
require 'google/cloud/bigquery'

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
    projects = Project.new.fetch_all

    progress_bar = ProgressBar.create(format: '%a |%b>>%i| %p%% %t',
                                      starting_at: 0,
                                      total: projects.count)

    projects.each do |project|
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
    ensure
      progress_bar.increment
    end
  end
end

desc 'Initializes BigQuery dataset to load right sizing data'
task :initialize_bigquery_dataset, [:project_id] do |_, args|
  creds = Google::Auth.get_application_default(['https://www.googleapis.com/auth/cloud-platform'])
  bigquery = Google::Cloud::Bigquery.new(project_id: args.project_id,
                                         credentials: creds)

  dataset = bigquery.create_dataset 'right_sizing'

  dataset.create_table 'vm_info' do |t|
    t.name = 'VM Info'
    t.description = 'Information about VMs that can be right sized to save cost and increase performance.'
    t.schema do |s|
      s.record 'project', mode: :required do |ns|
        ns.string 'name', mode: :required
        ns.string 'id', mode: :required
      end
      s.record 'vm', mode: :required do |ns|
        ns.string 'name', mode: :required
        ns.string 'zone', mode: :required
        ns.record 'bosh', mode: :required do |bs|
          bs.string 'name'
          bs.string 'job'
          bs.string 'deployment'
          bs.string 'instance_group'
        end
      end
      s.integer 'estimated_cost_difference_per_month_in_cents_of_usd', mode: :required
      s.record 'current_machine_type', mode: :required do |ns|
        ns.integer 'cpu_milli_vcores', mode: :required
        ns.integer 'memory_bytes', mode: :required
        ns.string 'name', mode: :required
        ns.integer 'reserved_cpu_milli_cores', mode: :required
      end
      s.record 'recommended_machine_type', mode: :required do |ns|
        ns.integer 'cpu_milli_vcores', mode: :required
        ns.integer 'memory_bytes', mode: :required
        ns.string 'name', mode: :required
        ns.integer 'reserved_cpu_milli_cores', mode: :required
      end
      s.record 'prediction', mode: :required do |ns|
        ns.integer 'cpu_milli_vcores', mode: :required
        ns.integer 'memory_bytes', mode: :required
      end
    end
  end
end
