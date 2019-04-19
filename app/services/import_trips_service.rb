# frozen_string_literal: true

# require 'oj'

class ImportTripsService
  def self.load(file_name)
    new(file_name).load
  end

  attr_reader :json

  def initialize(file_name)
    # @file_name = file_name
    @json = Oj.load(File.read(file_name))
  end

  def load
    # json = Oj.load(File.read(file_name))

    ActiveRecord::Base.transaction do
      City.delete_all
      Bus.delete_all
      Service.delete_all
      Trip.delete_all
      ActiveRecord::Base.connection.execute('delete from buses_services;')

      # def load_cities
      #   sities = []

      #   json.each do |trip|
      #     sities << trip['from']
      #     sities << trip['to']
      #   end

      #   sities.uniq!
      #   City.import
      # end

      json.each do |trip|
        from = City.find_or_create_by(name: trip['from'])
        to = City.find_or_create_by(name: trip['to'])
        services = []
        trip['bus']['services'].each do |service|
          s = Service.find_or_create_by(name: service)
          services << s
        end
        bus = Bus.find_or_create_by(number: trip['bus']['number'])
        bus.update(model: trip['bus']['model'], services: services)

        Trip.create!(
          from: from,
          to: to,
          bus: bus,
          start_time: trip['start_time'],
          duration_minutes: trip['duration_minutes'],
          price_cents: trip['price_cents']
        )
      end
    end
  end
end
