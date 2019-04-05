#!/usr/bin/env ruby
require 'fileutils'
include FileUtils
require 'benchmark'

# path to your application root.
APP_ROOT = File.expand_path('..', __dir__)

def system!(*args)
  system(*args) || abort("\n== Command #{args} failed ==")
end



chdir APP_ROOT do
  result = Benchmark.measure do
    puts "\n== Loading data from fixtures/small.json =="
    system! 'bin/rake reload_json[fixtures/small.json]'
  end

  puts result
end
