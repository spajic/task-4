desc 'Import data from json file to DB: rake reload_json[fixtures/small.json]'
task :reload_json, [:file_name] => :environment do |_task, args|
  DbImporter.new.call(source: args.file_name)
end
