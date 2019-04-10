namespace :feedback do
  desc "Feedback loop"
  task start: :environment do
    result = Benchmark.measure do
      puts "\nLoading data from fixtures/small.json"
      Rake::Task["reload_json"].execute({file_name: "fixtures/small.json"})
    end

    puts result
  end
end
