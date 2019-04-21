# frozen_string_literal: true

# rake reload_json[fixtures/small.json]
task :reload_json, [:file_name] => :environment do |_task, args|
  ImportTripsService.load(args[:file_name])
end
