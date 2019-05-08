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

    # add temp columns to trips and import data
    migration.add_column(:trips, :bus, :jsonb)
    migration.add_column(:trips, :from, :varchar)
    migration.add_column(:trips, :to, :varchar)
    Trip.reset_column_information
    Trip.import(json, validate: false, no_returning: true)

    # create services; add primary key and index
    services = Service::SERVICES.map { |name| { name: name } }
    Service.import(services)
    migration.execute('ALTER TABLE services ADD PRIMARY KEY (id);')
    Service.primary_key = :id
    migration.add_index(:services, :name, unique: true)

    # create cities; add primary key and index
    cities = (Trip.distinct.pluck(:from) | Trip.distinct.pluck(:to)).map(&Array.method(:wrap))
    City.import([:name], cities)
    City.primary_key = :id
    migration.execute('ALTER TABLE cities ADD PRIMARY KEY (id);')
    migration.add_index(:cities, :name, unique: true)

    # create buses; add primary key and index
    buses = Trip.select("DISTINCT data")
                .from("(SELECT (bus - 'services') AS data FROM trips) AS subquery")
                .map(&:data)
    Bus.import(buses)
    migration.execute('ALTER TABLE buses ADD PRIMARY KEY (id);')
    Bus.primary_key = :id
    migration.add_index(:buses, :number, unique: true)

    # create buses_services; add primary key
    BusesService = Class.new(ActiveRecord::Base)
    buses_services =
      Trip.unscoped
          .joins("join buses on trips.bus->>'number' = buses.number")
          .joins("join services on services.name =
                 ANY(select jsonb_array_elements_text((trips.bus->>'services')::jsonb))")
          .group('buses.id, services.id')
          .pluck('buses.id, services.id')
    BusesService.import([:bus_id, :service_id], buses_services)
    Object.send(:remove_const, :BusesService)
    migration.execute('ALTER TABLE buses_services ADD PRIMARY KEY (id);')

    # update trips; remove temp columns; add primary key
    Trip.where("trips.bus->>'model' = buses.model")
        .where("trips.bus->>'number' = buses.number")
        .update_all('bus_id = buses.id FROM buses')
    Trip.where("trips.from = services.name")
        .update_all('from_id = services.id FROM services')
    Trip.where("trips.to = services.name")
        .update_all('to_id = services.id FROM services')
    migration.remove_column(:trips, :bus)
    migration.remove_column(:trips, :from)
    migration.remove_column(:trips, :to)
    migration.execute('ALTER TABLE trips ADD PRIMARY KEY (id);')
    Trip.primary_key = :id
  end
end
