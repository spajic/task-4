# frozen_string_literal: true

require 'benchmark/ips'
require 'ruby-prof'
require 'memory_profiler'
require 'active_record'
require './app/models/application_record'
require './app/services/import_trips_service'
require './app/models/city'
require './app/models/bus'
require './app/models/service'
require './app/models/trip'
require './app/models/buses_service'
require 'oj'
require 'progress_bar'
require 'activerecord-import'

config = YAML.load_file('config/database.yml')['development']
ActiveRecord::Base.establish_connection(config)

def reevaluate_metric
  Benchmark.ips do |bench|
    bench.report('small') { ImportTripsService.load('fixtures/small.json') }
    bench.report('medium') { ImportTripsService.load('fixtures/medium.json') }
    bench.report('large') { ImportTripsService.load('fixtures/large.json') }
    bench.compare!
  end
end

reevaluate_metric
