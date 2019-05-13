  require 'oj'

class JsonImporter
  attr_accessor :services_names_hash, :cities_names_hash, :buses_hash, :trips
  def initialize
    @services_names_hash = {}
    @cities_names_hash = {}
    @buses_hash = {}
    @trips = []
  end

  def import_json_to_db(file_path:)
    # byebug
    json = Oj.load_file(file_path)

    ActiveRecord::Base.transaction do
      delete_existing_records 
      create_cities_and_services(json)
      create_buses_with_services(json)  
      create_trips(json)
    end
  end

  def create_cities_and_services(json)
    json.each do |trip|
      cities_names_hash[trip['from']] ||= City.new(name: trip['from'])
      cities_names_hash[trip['to']] ||= City.new(name: trip['to'])
      trip['bus']['services'].each do |service|
        services_names_hash[service] = Service.new(name: service)
      end
    end 
    # byebug
    City.import cities_names_hash.values, syncronize: true, raise_error: true
    # byebug
    Service.import services_names_hash.values, syncronize: true, raise_error: true   
  end

  def create_buses_with_services(json)
    buses_numbers = []
    json.each do |trip|
      next if buses_numbers.include?(trip['bus']['number'])
        bus = Bus.new(
          number: trip['bus']['number'],
          model: trip['bus']['model']
        )
        bus.services = services_names_hash.values_at(*trip['bus']['services'])
        
        buses_hash[trip['bus']['number']] = bus
        buses_numbers << trip['bus']['number']
    end
    # byebug
    Bus.import buses_hash.values, recursive: true, syncronize: true,raise_error: true
  end

  def create_trips(json)
    json.each do |trip|
      from = cities_names_hash[trip['from']]
      to = cities_names_hash[trip['to']]
      bus = buses_hash[trip['bus']['number']]
      trips << Trip.new(
        from: from,
        to: to,
        bus: bus,
        start_time: trip['start_time'],
        duration_minutes: trip['duration_minutes'],
        price_cents: trip['price_cents']
      )
    end
    Trip.import trips, raise_error: true
  end

  def delete_existing_records
    City.delete_all
    Bus.delete_all
    Service.delete_all
    Trip.delete_all
    ActiveRecord::Base.connection.execute('delete from buses_services;')
  end
end
