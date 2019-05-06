# Наивная загрузка данных из json-файла в БД
# rake reload_json[fixtures/small.json]
task :reload_json, [:file_name] => :environment do |_task, args|
  json = JSON.parse(File.read(args.file_name))

  ActiveRecord::Base.transaction do
    migration = ActiveRecord::Migration

    # truncate tables
    migration.execute(<<-SQL)
    TRUNCATE cities, buses, services, trips, buses_services RESTART IDENTITY;
    SQL

    # drop primary keys and indicies
    migration.execute(<<-SQL.squish)
    ALTER TABLE cities DROP CONSTRAINT cities_pkey;
    ALTER TABLE buses DROP CONSTRAINT buses_pkey;
    ALTER TABLE services DROP CONSTRAINT services_pkey;
    ALTER TABLE trips DROP CONSTRAINT trips_pkey;
    ALTER TABLE buses_services DROP CONSTRAINT buses_services_pkey;
    DROP INDEX index_cities_on_name;
    DROP INDEX index_buses_on_number;
    DROP INDEX index_services_on_name
    SQL

    # create services; add primary key and index; load
    services = Service::SERVICES.map { |name| { name: name } }
    Service.import(services)
    migration.execute('ALTER TABLE services ADD PRIMARY KEY (id);')
    migration.add_index(:services, :name, unique: true)
    services = Service.pluck(:name, :id).to_h

    # create values to insert
    #values = json.reduce({ cities: [], buses: [], buses_services: [], trips: [] }) do |h, obj|
    #  h[:cities] += [{ name: obj['from'] }, { name: obj['to'] }]
    #  h[:buses] << { model: obj.dig('bus', 'model'), number: obj.dig('bus', 'number') }
    #  h[:buses_services] += obj.dig('bus', 'services').map do |serv_name|
    #    { bus_id: obj.dig('bus', 'number'), service_id: services[serv_name] }
    #  end
    #  h[:trips] << { from_id: obj['from'],
    #                 to_id: obj['to'],
    #                 bus_id: obj.dig('bus', 'number'),
    #                 start_time: obj['start_time'],
    #                 duration_minutes: obj['duration_minutes'],
    #                 price_cents: obj['price_cents'] }
    #  h
    #end

    # create cities; add primary key and index; load
    cities = json.reduce([]) { |arr, obj| arr += [obj['from'], obj['to']] }.uniq
    cities = cities.map { |name| { name: name } }
    City.import(cities)
    #City.import(values[:cities].uniq)
    migration.execute('ALTER TABLE cities ADD PRIMARY KEY (id);')
    migration.add_index(:cities, :name, unique: true)
    cities = City.pluck(:name, :id).to_h

    # create buses; add primary key and index; load
    buses = json.map do |obj|
      { model: obj.dig('bus', 'model'), number: obj.dig('bus', 'number') }
    end.uniq
    Bus.import(buses)
    #Bus.import(values[:buses].uniq)
    migration.execute('ALTER TABLE buses ADD PRIMARY KEY (id);')
    migration.add_index(:buses, :number, unique: true)
    buses = Bus.pluck(:number, :id).to_h

    # create buses_services; add primary key
    BusesService = Class.new(ActiveRecord::Base)
    BusesService.table_name = 'buses_services'
    buses_services = json.reduce([]) do |arr, obj|
      arr += obj.dig('bus', 'services').map do |serv_name|
        { bus_id: buses[obj.dig('bus', 'number')],
          service_id: services[serv_name] }
      end
    end
    #buses_services = values[:buses_services].uniq.map do |h|
    #  h[:bus_id] = buses[h[:bus_id]]
    #  h
    #end
    BusesService.import(buses_services)
    Object.send(:remove_const, :BusesService)
    migration.execute('ALTER TABLE buses_services ADD PRIMARY KEY (id);')

    # create trips; add primary key
    trips = json.map do |trip|
      { from_id: cities[trip['from']],
        to_id: cities[trip['to']],
        bus_id: buses[trip.dig('bus', 'number')],
        start_time: trip['start_time'],
        duration_minutes: trip['duration_minutes'],
        price_cents: trip['price_cents'] }
    end
    #trips = values[:trips].uniq.map do |h|
    #  h[:from_id] = cities[h[:from_id]]
    #  h[:to_id]   = cities[h[:to_id]]
    #  h[:bus_id]  = buses[h[:bus_id]]
    #  h
    #end
    Trip.import(trips)
    migration.execute('ALTER TABLE trips ADD PRIMARY KEY (id);')
  end
end
