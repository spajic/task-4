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
end
