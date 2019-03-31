# Наивная загрузка данных из json-файла в БД
# rake reload_json[fixtures/small.json]
task :reload_json, [:file_name] => :environment do |_task, args|
  json = JSON.parse(File.read(args.file_name))

  ActiveRecord::Base.transaction do
    City.delete_all
    Bus.delete_all
    Service.delete_all
    Trip.delete_all
    ActiveRecord::Base.connection.execute('delete from buses_services;')

    cities = {}
    services = {}

    json.each do |trip|
      cities[trip['from']] = City.new(name: trip['from']) if trip['from']
      cities[trip['to']] = City.new(name: trip['to']) if trip['to']
      trip['bus']['services'].each { |s| services.merge!(s => Service.new(name: s)) }
    end

    City.import cities.values
    Service.import services.values

    buses = {}
    json.each do |trip|
      bus = Bus.new(number: trip['bus']['number'], model: trip['bus']['model'])
      buses.merge!(trip['bus']['number'] => [bus, services.values_at(*trip['bus']['services'])])
    end

    Bus.import buses.values.map(&:first)

    buses_services = []
    buses.values.each do |bus_with_service|
      bus_with_service.second.each { |s| buses_services << { bus_id: bus_with_service.first.id, service_id: s.id } }
    end
    BusesService.import buses_services

    trips = json.map! do |trip|
      {
        from_id: cities.fetch(trip['from']).id,
        to_id: cities.fetch(trip['to']).id,
        bus_id: buses.fetch(trip['bus']['number']).first.id,
        start_time: trip['start_time'],
        duration_minutes: trip['duration_minutes'],
        price_cents: trip['price_cents']
      }
    end

    Trip.import trips
  end
end
