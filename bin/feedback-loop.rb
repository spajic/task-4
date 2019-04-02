#!/usr/bin/env ruby
require 'benchmark'
require 'fileutils'
include FileUtils

FILES = %w[
  example.json
  small.json
  medium.json
  large.json
].freeze

APP_ROOT = File.expand_path('..', __dir__)

def system!(*args)
  system(*args) || abort("\n== Command #{args} failed ==")
end

chdir APP_ROOT do
  FILES.each do |file|
    result = Benchmark.measure do
      puts "\n== Loading data from fixtures/#{file} =="
      system! "bin/rake reload_json[fixtures/#{file}]"
    end

    puts result
  end
end
