require 'benchmark'

desc 'measure performance for optimization rake import_json_benchmark[fixtures/small.json]'
task :import_json_benchmark, [:file_name] => :environment do |_task, args|
  result = Benchmark.measure do
    puts "\n== Loading data from #{args.file_name} =="
    Benchmark.measure { Rake::Task['reload_json'].invoke(*args) }
  end

   puts result
end

# initial results
# 2.654352   0.956313  13.612620 ( 14.781368)

# add indicies to trips
# 12.471791   0.888674  13.360465 ( 14.467896)