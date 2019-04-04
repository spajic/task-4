def test_correctness(spec_file)
  puts `bundle exec rspec #{spec_file}`

  if !$?.success?
    raise 'code broken!'
  end
end

def evaluate_metric
  GC.disable

  Benchmark.ips do |b|
    b.stats = :bootstrap
    b.confidence = 99

    yield(b)
  end
end


namespace :optimization do
  task trips_controller: :environment do |_task, args|
    test_correctness('spec/controllers/trips_controller_spec.rb')

    class TripsControllerExecutor
      include Rack::Test::Methods

      def app
        Rails.application
      end

      def run
        get URI.escape('/автобусы/Самара/Москва')
      end
    end

    evaluate_metric do |b|
      DbPopulator.populate('fixtures/small.json')
      executor = TripsControllerExecutor.new

      b.report('large.json') { executor.run }
    end

    <<~RESULTS
      bundle exec rake optimization:trips_controller

      Initial value:
        13.137 ips

    RESULTS
  end

  task db_populator: :environment do |_task, args|
    test_correctness('spec/services/db_populator_spec.rb')

    evaluate_metric do |b|
      b.report('small.json') { DbPopulator.populate('fixtures/small.json') }
    end

    <<~RESULTS
      Initial value:
        0.105 ips

      Cache services creating:
        0.125

      Cache buses creating:
        0.152

      Cache cities creating:
        0.232

      Bulk inserting trips:
        0.301

      Bulk inserting bus services:
        1.156

      Final:
        bundle exec rake "reload_json[fixtures/large.json]"  8.88s user 0.89s system 86% cpu 11.274 total
    RESULTS
  end

end
