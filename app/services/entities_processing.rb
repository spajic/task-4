class EntitiesProcessing
  class << self
    def call(file_name:, with_gc: true)
      GC.disabled unless with_gc

      json = Oj.load(File.read file_name)

      ActiveRecord::Base.transaction do
        City.delete_all
        Bus.delete_all
        Service.delete_all
        Trip.delete_all
        BusesService.delete_all

        create_cities(json)
        create_services
        create_buses(json)
        create_trips(json)
      end

      clear_entities
    end

    private

    def create_buses(json)
      @buses =
        json.each_with_object({}) do |trip, memo|
          bus_number = trip['bus']['number']
          next if memo.has_key?(bus_number)

          memo[bus_number] = Bus.new(
            number: bus_number,
            model: trip['bus']['model'],
            services: @services.
              values_at(*trip['bus']['services'])
          )
        end

      Bus.import(@buses.values, recursive: true, raise_error: true)
    end

    def create_cities(json)
      @cities =
        json.each_with_object({}) do |trip, memo|
          from = trip['from']
          to = trip['to']

          next if memo.has_key?(from) && memo.has_key?(to)
          name = memo.has_key?(from) ? to : from

          memo[name] = City.new(name: name)
        end

      City.import(@cities.values, recursive: true, raise_error: true)
    end

    def create_services
      @services =
        Service::SERVICES.sort.each_with_object({}) do |name, memo|
          memo[name] = Service.new(name: name)
        end

      Service.import(@services.values, recursive: true, raise_error: true)
    end

    def create_trips(json)
      @trips =
        json.each_with_object({}) do |trip, memo|
          from = @cities[trip['from']]
          to = @cities[trip['to']]
          bus = @buses[trip['bus']['number']]
          start_time = trip['start_time']


          memo[start_time] =
            Trip.new(
              from: from,
              to: to,
              bus: bus,
              start_time: start_time,
              duration_minutes: trip['duration_minutes'],
              price_cents: trip['price_cents'],
            )
        end

      Trip.import(@trips.values, recursive: true, raise_error: true)
    end

    def clear_entities
      @trips.clear
      @buses.clear
      @cities.clear
      @services.clear
    end
  end
end
