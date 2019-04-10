namespace :asymptotics do
  FILES = %w[
    small.json
    medium.json
    large.json
  ].freeze

  desc "Asymptotics"
  task start: :environment do
    FILES.each do |file|
      result = Benchmark.measure do
        puts "\nLoading data from fixtures/#{file}"
        Rake::Task["reload_json"].execute({file_name: "fixtures/#{file}"})
      end

      puts result
    end
  end
end
