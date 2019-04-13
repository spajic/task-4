require 'oj'

class DbImporter
  def call(source:)
    json = Oj.load_file(source)

    ActiveRecord::Base.transaction do
      clear_db!
      create_from_json!(json)
    end
  end

  def clear_db!
    City.delete_all
    Bus.delete_all
    Service.delete_all
    Trip.delete_all
    ActiveRecord::Base.connection.execute('delete from buses_services;')
  end

  def create_from_json!(json)
    cities = Set.new
    services = Set.new

    json.each do |trip|
      cities << trip['from']
      cities << trip['to']

      trip['bus']['services'].each do |service|
        services << service
      end
    end

    cities.each do |city|
      City.create(name: city)
    end

    services.each do |service|
      Service.create(name: service)
    end

    json.each do |trip|
      from = City.find_by(name: trip['from'])
      to = City.find_by(name: trip['to'])
      services = Service.where(name: trip['bus']['services'])
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
