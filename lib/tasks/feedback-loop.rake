namespace :feedback do
  FILES = %w[
    example.json
    small.json
    medium.json
    large.json
  ].freeze

  desc "Feedback loop"
  task loop: :environment do
    FILES.each do |file|
      result = Benchmark.measure do
        puts "\nLoading data from fixtures/#{file}"
        Rake::Task["reload_json"].execute({file_name: "fixtures/#{file}"})
      end

      puts result
    end
  end
end
