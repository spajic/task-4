# Наивная загрузка данных из json-файла в БД
# rake reload_json[fixtures/small.json]
require 'benchmark'
require 'oj'

task :reload_json, [:file_name] => :environment do |_task, args|
  json = Oj.load(File.read(args.file_name))
  p 'Start'
  time = Benchmark.realtime do
    Importer.new(json).call
  end
  p 'Done'
  p time
end
