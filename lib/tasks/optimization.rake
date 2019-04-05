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
      file = 'large.json'
      DbPopulator.populate("fixtures/#{file}")
      executor = TripsControllerExecutor.new

      b.report(file) { executor.run }
    end

    # Session 2 (for large.json)

    <<~RESULTS
      Original version:
        ab -n 10 -c 1 http://localhost:3000/автобусы/Самара/Москва
          In dev mode mean = 20504 ms


      Optimized after session 1:
        ab -n 20 -c 1 http://localhost:3000/автобусы/Самара/Москва
          In dev mode mean = 388 ms

      RAILS_ENV=test ENABLE_CACHE=true bundle exec rake optimization:trips_controller

      Initial value:
        3.373 IPS

      SQL optimization: eager_load instead preload + all required indexes
        4.928

      Enable caching:
        6.404

      ab -n 100 -c 1 http://localhost:3000/автобусы/Самара/Москва
        Concurrency Level:      1
        Time taken for tests:   17.733 seconds
        Complete requests:      100
        Failed requests:        0
        Total transferred:      70281278 bytes
        HTML transferred:       70211500 bytes
        Requests per second:    5.64 [#/sec] (mean)
        Time per request:       177.326 [ms] (mean)
        Time per request:       177.326 [ms] (mean, across all concurrent requests)
        Transfer rate:          3870.50 [Kbytes/sec] received

        Connection Times (ms)
                      min  mean[+/-sd] median   max
        Connect:        0    0   0.0      0       0
        Processing:   145  177  48.0    172     545
        Waiting:      144  177  48.0    172     545
        Total:        145  177  48.0    172     545

      20504/177 = 115.84x
    RESULTS

    # Session 1 (for small.json)

    <<~RESULTS
      bundle exec rake optimization:trips_controller

      Initial value:
        7.187 ips

      Render trips as a collection:
        7.583

      Render services as a collection:
        9.880

      Replace delimiter with view helper:
        11.110

      Fix n+1
        18.567

      Replace rendering of services with view helper:
        25.831

      ab -n 100 -c 1 http://localhost:3000/автобусы/Самара/Москва
        With enabled meta_request:
          Concurrency Level:      1
          Time taken for tests:   4.692 seconds
          Complete requests:      100
          Failed requests:        0
          Total transferred:      1087890 bytes
          HTML transferred:       1014900 bytes
          Requests per second:    21.31 [#/sec] (mean)
          Time per request:       46.917 [ms] (mean)
          Time per request:       46.917 [ms] (mean, across all concurrent requests)
          Transfer rate:          226.44 [Kbytes/sec] received

          Connection Times (ms)
                        min  mean[+/-sd] median   max
          Connect:        0    0   0.0      0       0
          Processing:    38   47  11.8     41     100
          Waiting:       38   47  11.8     41     100
          Total:         38   47  11.8     41     101

        With disabled meta_request:
          Concurrency Level:      1
          Time taken for tests:   3.201 seconds
          Complete requests:      100
          Failed requests:        0
          Total transferred:      1084760 bytes
          HTML transferred:       1014900 bytes
          Requests per second:    31.24 [#/sec] (mean)
          Time per request:       32.010 [ms] (mean)
          Time per request:       32.010 [ms] (mean, across all concurrent requests)
          Transfer rate:          330.94 [Kbytes/sec] received

          Connection Times (ms)
                        min  mean[+/-sd] median   max
          Connect:        0    0   0.0      0       0
          Processing:    27   32   6.7     29      60
          Waiting:       27   32   6.7     29      60
          Total:         27   32   6.7     29      60

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
