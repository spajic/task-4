class DbPopulator
  class << self
    def populate(file_name)
      json = JSON.parse(File.read(file_name))

      all_services = {}
      all_buses = {}
      all_cities = {}

      ActiveRecord::Base.transaction do
        City.delete_all
        BusService.delete_all
        Bus.delete_all
        Service.delete_all
        Trip.delete_all

        Trip.bulk_insert do |trip_worker|
          BusService.bulk_insert do |bus_service_worker|
            json.each do |trip|
              from = (all_cities[trip['from']] ||= City.create!(name: trip['from']))
              to = (all_cities[trip['to']] ||= City.create!(name: trip['to']))

              services = []
              trip['bus']['services'].each do |service|
                s = (all_services[service] ||= Service.create!(name: service))
                services << s
              end

              number = trip['bus']['number']
              bus = (all_buses[number] ||= begin
                Bus.create!(number: number, model: trip['bus']['model']).tap do |bus|
                  services.each do |service|
                    bus_service_worker.add(bus_id: bus.id, service_id: service.id)
                  end
                end
              end)

              trip_worker.add(
                from_id: from.id,
                to_id: to.id,
                bus_id: bus.id,
                start_time: trip['start_time'],
                duration_minutes: trip['duration_minutes'],
                price_cents: trip['price_cents'],
              )
            end
          end
        end
      end
    end
  end
end
