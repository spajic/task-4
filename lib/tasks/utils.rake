# Наивная загрузка данных из json-файла в БД
# rake reload_json[fixtures/small.json]

task :reload_json, [:file_name] => :environment do |_task, args|
  json = JSON.parse(File.read(args.file_name))

  ActiveRecord::Base.transaction do

    ActiveRecord::Base.connection.execute <<-SQL
        delete from cities;
        delete from buses;
        delete from services;
        delete from trips;
        delete from buses_services;
    SQL

    cities = Set.new
    services = Set.new
    buses = Set.new
    buses_services = Set.new
    trips = Set.new

    json.each do |trip|
      cities << { name: trip['from'] }
      cities << { name: trip['to'] }
      buses << { number: trip['bus']['number'], model: trip['bus']['model'] }
      trip['bus']['services'].each do |service_name|
        services << { name: service_name }
        buses_services << { bus_number: trip['bus']['number'], service_name: service_name }
      end
      trips << {
        from_name: trip['from'],
        to_name: trip['to'],
        bus_number: trip['bus']['number'],
        start_time: trip['start_time'],
        duration_minutes: trip['duration_minutes'],
        price_cents: trip['price_cents']
      }
    end

    City.bulk_insert do |worker|
      cities.each do |city_attrs|
        worker.add(city_attrs)
      end
    end

    Service.bulk_insert do |worker|
      services.each do |service_attrs|
        worker.add(service_attrs)
      end
    end

    Bus.bulk_insert do |worker|
      buses.each do |bus_attrs|
        worker.add(bus_attrs)
      end
    end

    cities_objects = City.pluck(:name, :id).to_h
    services_objects = Service.all.index_by(&:name)
    buses_objects = Bus.all.index_by(&:number)

    BusService.bulk_insert do |worker|
      buses_services.each do |bs|
        bus_id = buses_objects[bs[:bus_number]].id
        service_id = services_objects[bs[:service_name]].id
        worker.add(bus_id: bus_id, service_id: service_id)
      end
    end

    Trip.bulk_insert do |worker|
      trips.each do |trip|
        from_id = cities_objects[trip[:from_name]]
        to_id = cities_objects[trip[:to_name]]
        bus_id = buses_objects[trip[:bus_number]].id

        worker.add(
          from_id: from_id,
          to_id: to_id,
          bus_id: bus_id,
          start_time: trip[:start_time],
          duration_minutes: trip[:duration_minutes],
          price_cents: trip[:duration_minutes]
        )
      end
    end
  end
end
