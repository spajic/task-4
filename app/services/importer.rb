class Importer
  attr_reader :json

  def initialize(json)
    @json = json
  end

  def call
    ActiveRecord::Base.transaction do
      reset_db!
      import_cities
      import_services
      import_busses

      buses = Bus.pluck(:number, :id).to_h
      cities = City.pluck(:name, :id).to_h
      link_services(buses)
      import_trips(buses, cities)
    end
  end

  private

  def reset_db!
    City.delete_all
    Bus.delete_all
    Service.delete_all
    Trip.delete_all
    BusService.delete_all
  end

  def import_cities
    cities = Set.new
    json.each do |trip|
      cities << [trip['from']] << [trip['to']]
    end
    City.import! [:name], cities.to_a
  end

  def import_services
    services = Set.new
    json.each do |trip|
      services.merge trip['bus']['services'].map { |el| [el] }
    end
    Service.import! [:name], services.to_a
  end

  def import_busses
    buses = Set.new
    json.each do |trip|
      buses << [trip['bus']['number'], trip['bus']['model']]
    end
    Bus.import! [:number, :model], buses.to_a
  end

  def link_services(buses)
    services = Service.pluck(:name, :id).to_h
    joins = Set.new
    json.each do |trip|
      bid = buses[trip['bus']['number']]
      joins.merge(trip['bus']['services'].map { |service| [bid, services[service]] })
    end
    BusService.import! [:bus_id, :service_id], joins.to_a
  end

  def import_trips(buses, cities)
    trips = Set.new
    columns = [:from_id, :to_id, :bus_id, :start_time, :duration_minutes, :price_cents]
    json.each do |trip|
      from_id = cities[trip['from']]
      to_id = cities[trip['to']]
      bus_id = buses[trip['bus']['number']]
      trips.add [
        from_id,
        to_id,
        bus_id,
        trip['start_time'],
        trip['duration_minutes'],
        trip['price_cents'],
      ]
    end
    Trip.import! columns, trips.to_a
  end
end
