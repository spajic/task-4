def ruby_prof_wall(*args)
  # GC.disable

  # require 'memory_profiler'
  # report = MemoryProfiler.report do
  #   work('data_medium.txt')
  # end
  # report.pretty_print(color_output: true, scale_bytes: true)

  # require 'ruby-prof'
  # RubyProf.measure_mode = RubyProf::MEMORY
  RubyProf.measure_mode = RubyProf::WALL_TIME
  result = RubyProf.profile do
    yield
  end

  printer = RubyProf::FlatPrinter.new(result)
  printer.print(STDOUT)

  # printer = RubyProf::GraphPrinter.new(result)
  # printer.print(STDOUT, {})

  # printer = RubyProf::CallStackPrinter.new(result)
  # File.open('ruby-prof-call-stack.html', "w") do |f|
  #   printer.print(f, threshold: 0, min_percent: 0, title: "ruby_prof WALL_TIME")
  # end

  # printer = RubyProf::CallTreePrinter.new(result)
  # printer.print()
end

def stack_prof_wall(method)
  StackProf.run(mode: :wall, out: 'tmp/stackprof.dump', raw: true) do
    yield
  end

  puts `stackprof tmp/stackprof.dump --method #{method}`
end

namespace :profiling do
  task :db_populator, [:profiler] => :environment do |_task, args|
    send(args.profiler, 'DbPopulator.populate') do
      DbPopulator.populate('fixtures/small.json')
    end
  end
end
