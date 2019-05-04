def time_profiler(name, &block)
  time = Benchmark.realtime do
    block.call
  end

  puts "Time: #{name}: #{time}"
end

def set_ar_logging(out = STDOUT)
  ActiveRecord::Base.logger = Logger.new(out)
end

class BusForInsert < ActiveRecord::Base
  self.table_name = 'buses'
end
