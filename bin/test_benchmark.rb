#!/usr/bin/env ruby
#
require 'benchmark'
# require 'fileutils'

FILES = %w(
  small.json
  medium.json
  large.json
).freeze

APP_ROOT = File.expand_path('..', __dir__)

# FileUtils.chdir APP_ROOT do
FILES.each do |fname|
  result = Benchmark.measure do
    puts "----------Load data from #{fname}----------"
    `rake reload_json[#{APP_ROOT}/fixtures/#{fname}]`
  end
  puts result
end
# end

