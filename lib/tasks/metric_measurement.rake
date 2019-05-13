require 'benchmark'

desc 'measure performance for optimization rake import_json_benchmark[fixtures/small.json]'
task :import_json_benchmark, [:file_name] => :environment do |_task, args|
  result = Benchmark.measure do
    puts "\n== Loading data from #{args.file_name} =="
    Benchmark.measure { Rake::Task['reload_json'].invoke(*args) }
  end

   puts result
end

#  CPU time, system CPU time, the sum of the user and system CPU times, and the elapsed real time. The unit of time is seconds.

# initial results
# 2.654352   0.956313  13.612620 ( 14.781368)

# add indicies to trips
# 12.471791   0.888674  13.360465 ( 14.467896)

# add indicies to cities, services and buses
# 11.874181   0.867256  12.743072 ( 13.819131)

# == Loading data from fixtures/small.json ==
# Reload complete!
#  14.654087   0.681433  15.337232 ( 16.270607)

# add Oj and activerecord-import
# == Loading data from fixtures/small.json ==
# Reload complete!
#   1.585816   0.067304   1.655319 (  1.651922)