# frozen_string_literal: true

class ImportTripsService
  BATCH_SIZE = 1000

  def self.load(file_name)
    new(file_name).load
  end

  attr_accessor :json, :sities, :buses, :services

  def initialize(file_name)
    @json = Oj.load(File.read(file_name))
    @sities = {}
    @buses = {}
    @services = {}
  end

  def load
    ActiveRecord::Base.transaction do
      clean_db!
      load_cities
      load_buses
      load_services
      load_buses_services
      load_trips
    end
  end

  def clean_db!
    BusesService.delete_all
    Trip.delete_all
    City.delete_all
    Bus.delete_all
    Service.delete_all
  end

  def load_cities
    sities_data = []
    # bar = ProgressBar.new(json.length)
    json.each do |trip|
      sities_data << { name: trip['from'] }
      sities_data << { name: trip['to'] }
      # bar.increment!
    end

    sities_data.uniq!
    result = City.import([:name], sities_data, returning: :name, **options)
    processing_result result, sities
  end

  def load_buses
    buses_data = []
    json.each do |trip|
      buses_data << {
        number: trip['bus']['number'],
        model: trip['bus']['model']
      }
    end
    buses_data.uniq!
    result = Bus.import(buses_data, returning: :number, **options)
    processing_result result, buses
  end

  def load_services
    services_data = []
    json.each do |trip|
      trip['bus']['services'].each do |service|
        services_data << { name: service }
      end
    end
    services_data.uniq!
    result = Service.import(services_data, returning: :name, **options)
    processing_result result, services
  end

  def load_buses_services
    buses_services = []
    json.each do |trip|
      trip['bus']['services'].each do |service|
        buses_services << {
          bus_id: buses[trip['bus']['number']],
          service_id: services[service]
        }
      end
    end
    buses_services.uniq!
    BusesService.import(buses_services, options)
  end

  def load_trips
    trips = []
    json.each do |trip|
      trips << {
        from_id: sities[trip['from']],
        to_id: sities[trip['to']],
        bus_id: buses[trip['bus']['number']],
        start_time: trip['start_time'],
        duration_minutes: trip['duration_minutes'],
        price_cents: trip['price_cents']
      }
    end

    Trip.import(trips, options)
  end

  def options
    {
      batch_size: BATCH_SIZE
    }
  end

  def processing_result(selection, collection = {})
    ids = selection.ids
    selection.results.each.with_index { |attr, i| collection[attr] = ids[i].to_i }
  end
end
