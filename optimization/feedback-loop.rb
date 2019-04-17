# frozen_string_literal: true

require 'benchmark/ips'
require 'rake'
require 'bundler'
require_relative '../config/application'
Rails.application.load_tasks

def reevaluate_metric
  Benchmark.ips do |bench|
    bench.report('Process large.json') do
      Rake::Task['reload_json'].invoke('fixtures/large.json')
    end
  end
end

def test_correctness
  # File.write('result.json', '')
  # work('fixtures/data_fixture.txt')
  # expected_result = File.read('fixtures/expected_result_fixture.json')
  # passed = expected_result == File.read('result.json')
  # passed ? puts('PASSED') : puts('!!! TEST FAILED !!!')
end

reevaluate_metric
test_correctness
