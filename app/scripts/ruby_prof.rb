# frozen_string_literal: true

require 'ruby-prof'
require_relative '../services/json_importer'

RubyProf.measure_mode = RubyProf::WALL_TIME

INITIAL_DATA_FILE = 'fixtures/small.json'
OUTPUT_DIR = 'tmp/data'


def flat_profile
  run_profiler do |result|
    printer = RubyProf::FlatPrinterWithLineNumbers.new(result)
    printer.print(File.open("#{OUTPUT_DIR}/ruby_prof_flat_demo.txt", 'w+'))   
  end
end

def graph_profile
  run_profiler do |result|
    printer = RubyProf::GraphHtmlPrinter.new(result)
    printer.print(File.open("#{OUTPUT_DIR}/ruby_prof_graph_demo.html", "w+"))
  end
end

def callstack_profile
  run_profiler do |result|
    printer = RubyProf::CallStackPrinter.new(result)
    printer.print(File.open("#{OUTPUT_DIR}/ruby_prof_callstack_demo.html", "w+"))
  end
end

def calltree_profile
  run_profiler do |result|
    printer = RubyProf::CallTreePrinter.new(result)
    printer.print(path: OUTPUT_DIR, profile: 'profile')
  end
end


def run_profiler
  RubyProf.measure_mode = RubyProf::WALL_TIME
  result = RubyProf.profile { JsonImporter.new.import_json_to_db(file_path: INITIAL_DATA_FILE) }
  yield result
end

# flat_profile
# graph_profile
# callstack_profile
# calltree_profile