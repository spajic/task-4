require 'oj'

task :reload_json, [:file_name] => :environment do |_task, args|
  json = Oj.load(File.read(args.file_name))

  ActiveRecord::Base.transaction do
    City.delete_all
    Bus.delete_all
    Service.delete_all
    Trip.delete_all
    ActiveRecord::Base.connection.execute('delete from buses_services;')

    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end

    cities = []
    bus_array = []

    json.each do |trip|
      cities.push("('#{trip['from']}')")
      cities.push("('#{trip['to']}')")
      bus_array.push(trip['bus'])
    end

    sql = "INSERT INTO cities (name) VALUES #{cities.uniq.join(', ')}"
    ActiveRecord::Base.connection.execute(sql)
    cities = City.pluck(:name, :id).to_h

    buses = []
    services = []

    bus_array.each do |obj|
      buses.push("(#{obj['number']}, '#{obj['model']}')")
      obj['services'].each { |service| services.push("('#{service}')") }
    end

    sql = "INSERT INTO buses (number, model) VALUES #{buses.uniq.join(', ')}"
    ActiveRecord::Base.connection.execute(sql)
    buses = Bus.pluck(:id, :number, :model)

    sql = "INSERT INTO services (name) VALUES #{services.uniq.join(', ')}"
    ActiveRecord::Base.connection.execute(sql)

    list_services = Service.pluck(:name, :id).to_h
    buses_services = []
    trips = []

    json.each do |trip|
      bus = buses.detect do |obj|
        obj[1] == trip['bus']['number'] &&
          obj[2] == trip['bus']['model']
      end
      list_services.slice(*trip['bus']['services'])
                   .each_value do |service_id|
        buses_services.push("(#{bus[0]}, #{service_id})")
      end
      trips.push(
        "(
        #{cities[trip['from']]},
        #{cities[trip['to']]},
        #{bus[0]},
        '#{trip['start_time']}',
        #{trip['duration_minutes']},
        #{trip['price_cents']}
        )"
      )
    end

    sql = "INSERT INTO buses_services (bus_id, service_id) VALUES #{buses_services.uniq.join(', ')}"
    ActiveRecord::Base.connection.execute(sql)

    sql = "INSERT INTO trips (from_id, to_id, bus_id, start_time, duration_minutes, price_cents) VALUES #{trips.join(', ')}"
    ActiveRecord::Base.connection.execute(sql)
  end
end
