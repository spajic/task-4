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
  task db_populator: :environment do |_task, args|
    test_correctness('spec/services/db_populator_spec.rb')

    evaluate_metric do |b|
      b.report('small.json') { DbPopulator.populate('fixtures/small.json') }
    end
  end

  <<~VALUES
    Initial value:
      0.105

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

    bundle exec rake "reload_json[fixtures/large.json]"  8.88s user 0.89s system 86% cpu 11.274 total
  VALUES
end
