# Наивная загрузка данных из json-файла в БД
# rake reload_json[fixtures/small.json]
require 'benchmark'

def create_services
  new_services = []
  all_services = Service.const_get('SERVICES').each_with_object({}) do |name, result|
     new_services << result[name] = Service.new(name: name)
  end
  Service.import(new_services)
  all_services
end

def create_cities(data)
  uniq_cities = data.each_with_object([]) do |trip, result|
    result << trip['from']
    result << trip['to']
  end.uniq
  new_cities = []
  all_cities = uniq_cities.each_with_object({}) do |name, result|
    new_cities << result[name] = City.new(name: name)
  end
  City.import(new_cities)
  all_cities
end

def create_buses(data, all_services)
  new_buses = []
  all_buses = data.each_with_object({}) do |trip, result|
    next if result[trip['bus']['number']]

    services = trip['bus']['services'].map {|service| all_services[service] }
    new_buses << result[trip['bus']['number']] = Bus.new(
      number: trip['bus']['number'],
      model: trip['bus']['model'],
      services: services
    )
  end
  #Bus.import(new_buses)
  new_buses.each(&:save!)
  all_buses
end

task :reload_json, [:file_name] => :environment do |_task, args|
  time = Benchmark.realtime do
    json = JSON.parse(File.read(args.file_name))

    ActiveRecord::Base.transaction do
      City.delete_all
      Bus.delete_all
      Service.delete_all
      Trip.delete_all
      ActiveRecord::Base.connection.execute('delete from buses_services;')

      all_services = create_services
      all_cities = create_cities(json)
      all_buses = create_buses(json, all_services)

      new_records = json.map do |trip|
        from = all_cities[trip['from']]
        to = all_cities[trip['to']]
        bus = all_buses[trip['bus']['number']]

        Trip.new(
          from: from,
          to: to,
          bus: bus,
          start_time: trip['start_time'],
          duration_minutes: trip['duration_minutes'],
          price_cents: trip['price_cents'],
        )
      end
      Trip.import(new_records)
    end
  end
  puts "Finish in #{time.round(2)}"
end
