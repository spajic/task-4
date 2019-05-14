
# Наивная загрузка данных из json-файла в БД
# rake reload_json[fixtures/small.json]
desc 'Import data from json file into database rake reload_json[fixtures/small.json]'
task :reload_json, [:file_name] => :environment do |_task, args|
  JsonImporter.new.import_json_to_db(file_path: args.file_name)
  puts 'Reload complete!'
end