# frozen_string_literal: true

require 'benchmark/ips'
require 'ruby-prof'
require 'memory_profiler'
require 'active_record'
require './app/models/application_record'
require './app/services/trips_service'
require './app/models/city'
require './app/models/bus'
require './app/models/service'
require './app/models/trip'

config = YAML.load_file('config/database.yml')['development']
ActiveRecord::Base.establish_connection(config)

GC.enable_stats
RubyProf.measure_mode = RubyProf::WALL_TIME

def reevaluate_metric
  Benchmark.ips do |bench|
    bench.report('small') { TripsService.load('fixtures/small.json') }
    # bench.report('medium') { TripsService.load('fixtures/medium.json') }
    # bench.report('large') { TripsService.load('fixtures/large.json') }
    bench.compare!
  end
end

def test_correctness
  # File.write('result.json', '')
  # work('fixtures/data_fixture.txt')
  # expected_result = File.read('fixtures/expected_result_fixture.json')
  # passed = expected_result == File.read('result.json')
  # passed ? puts('PASSED') : puts('!!! TEST FAILED !!!')
end

def cpu_profile
  result = RubyProf.profile do
    TripsService.load('fixtures/small.json')
  end

  # File.open './cpu-time-call-stack.html', 'w' do |file|
  #   RubyProf::CallStackPrinter.new(result).print(file)
  # end

  File.open './wall-time-cal-tree.txt', 'w' do |_file|
    RubyProf::CallTreePrinter.new(result).print(path: '.', profile: 'profile')
  end
end

def memory_profile
  report = MemoryProfiler.report do
    TripsService.load('fixtures/small.json')
  end

  report.pretty_print(scale_bytes: true)
end

# reevaluate_metric
test_correctness
# cpu_profile
memory_profile
