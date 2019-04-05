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

    Service::SERVICES.each do |name|
      Service.create!(name: name)
    end
    services_list = Service.pluck(:name, :id).to_h

    cities_names = []
    buses_hash = {}
    json.each do |trip|
      cities_names << trip['from'] << trip['to']
      buses_hash[trip['bus']['number']] = { model: trip['bus']['model'], services: trip['bus']['services'] }
    end

    cities_names.uniq!.map! { |a| "('#{a}')" }
    sql = "INSERT INTO cities (name) VALUES #{cities_names.join(', ')}"
    ActiveRecord::Base.connection.execute(sql)
    cities_list = City.pluck(:name, :id).to_h

    buses = []
    buses_hash.each do |number, attrs|
      buses << Bus.new(number: number, model: attrs[:model])
    end
    Bus.import buses
    buses_list = Bus.pluck(:number, :id).to_h

    trips = []
    buses_services = {}
    json.each do |trip|
      bus_id = buses_list[trip['bus']['number']]
      services_ids = services_list.slice(*trip['bus']['services']).values
      buses_services[bus_id] = services_ids.map { |s_id| { bus_id: bus_id, service_id: s_id } } unless buses_services.key?(bus_id)

      trip = Trip.new(from_id: cities_list[trip['from']],
                      to_id: cities_list[trip['to']],
                      bus_id: buses_list[trip['bus']['number']],
                      start_time: trip['start_time'],
                      duration_minutes: trip['duration_minutes'],
                      price_cents: trip['price_cents'])
      trips << trip
    end
    Trip.import trips

    BusesService.import buses_services.values.flatten
  end
end
