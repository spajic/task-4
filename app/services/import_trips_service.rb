# frozen_string_literal: true

# require 'oj'

class ImportTripsService
  def self.load(file_name)
    new(file_name).load
  end

  attr_reader :json, :sities, :buses

  def initialize(file_name)
    # @file_name = file_name
    @json = Oj.load(File.read(file_name))
    @sities = {}
    @buses = {}
  end

  def load
    ActiveRecord::Base.transaction do
      City.delete_all
      Bus.delete_all
      Service.delete_all
      Trip.delete_all
      ActiveRecord::Base.connection.execute('delete from buses_services;')

      load_cities
      load_buses

      json.each do |trip|
        # from = City.find_or_create_by(name: trip['from'])
        # to = City.find_or_create_by(name: trip['to'])
        # services = []
        # trip['bus']['services'].each do |service|
        #   s = Service.find_or_create_by(name: service)
        #   services << s
        # end
        # bus = Bus.find_or_create_by(number: trip['bus']['number'])
        # bus.update(model: trip['bus']['model'], services: services)
        # binding.pry
        Trip.create!(
          from_id: sities[trip['from']],
          to_id: sities[trip['to']],
          bus_id: buses[trip['bus']['number']],
          start_time: trip['start_time'],
          duration_minutes: trip['duration_minutes'],
          price_cents: trip['price_cents']
        )
      end
    end
  end

  def load_cities
    sities_data = []

    json.each do |trip|
      sities_data << [trip['from']]
      sities_data << [trip['to']]
    end

    sities_data.uniq!

    names = City.import([:name], sities_data, returning: :name)
    ids = names.ids
    names.results.each.with_index { |name, i| sities[name] = ids[i].to_i }
  end

  def load_buses
    buses_data = []
    # services = []
    json.each do |trip|
      bus = Bus.new(number: trip['bus']['number'], model: trip['bus']['model'])
      trip['bus']['services'].each do |service|
        bus.services.build(name: service)
      end
      buses_data << bus
    end
    binding.pry
    numbers = Bus.import buses_data, recursive: true, returning: :number, on_duplicate_key_ignore: true
    ids = numbers.ids
    numbers.results.each.with_index { |number, i| buses[number] = ids[i].to_i }
    #   trip['bus']['services'].each do |service|
    #     s = Service.find_or_create_by(name: service)
    #     services << s
    #   end
    # end

    # bus = Bus.find_or_create_by(number: trip['bus']['number'])
    # bus.update(model: trip['bus']['model'], services: services)
  end
end
