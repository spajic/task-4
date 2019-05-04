# Первая часть задания

**Начальная загрузка:**
small.json - 9.94s
medium.json - 83.75s
large.json - предположительно 9 x 83.75s

**Гипотезы:** 
В большом файле:
Городов - небольшое количество (мало)
Сервисов - небольшое количество (мало)
Автобусов - среднее количество
Путешествий - много
Сервисов в автобусах  - много

Включил логирование запросов

На 1 вставку происходит:
2 - 6 запросов на получение / вставку городов 
0 - > 10 запросов на получение / вставку сервисов
4 - > 10 запросов на получение / вставку автобусов

Проверил гипотезу о количестве:
    городов в большом файле: их 10 шт.
    сервисов в большом файле: их 10 шт.
    автобусов в большом файле: их 1 000 шт.

**После загрузки small.json**
buses: 613
cities: 10
services: 10
trips: 1 000
buses_services: 2 632

**После загрузки medium.json**
buses: 1 000
cities: 10
services: 10
trips: 10 000
buses_services: 4 685


1) Оптимизировать количество запросов закешировав города и сервисы для вставки
    **Первая оптимизация**
    small.json - 6.83(1.45X)
    medium.json - 42.50s (1.9X)
    
2) Оптимизировать количество запросов при добавлении автобуса
    автобус один и набор сервисов в нем одинаков, нет нужды все время его пересоздавать
     
3) Сделаем вставку buses_services большими кусками.
    Для этого сформируем один большой кусок данных для вставки и вставим их после обработки всех данных.
    Буду использовать гем activerecord-import
     
    **Третья оптимизация**
    small.json - 1.34s (7.41X)
    medium.json - 7.51s (11.15X)
    large.json - 63.71s

4) У нас до сих пор происходят множественные отдельные вставки трипов (и это бэд трип), поэтому оптимизируем этот момент
    Для этого так же сформируем кусок данных для вставки и вставим одним запросом (как настоящие хакеры).
    
    **Четвертая оптимизация**
    small.json - 0.61s (16.29X)
    medium.json - 1.43s (58.56X)
    large.json - 5.74s

5) Все еще есть проблема с отдельными вставками автобусов.
    Решим ее тем же способом - сформируем данные и импортируем одним запросом.
    Для этого потребуется импортировать все сущности таким способом.
    Так же для ускорения вставки отключил валидации.
    
    Перекладываю валидацию уникальности номера на БД -> добавим ключ на уникальность.
    Так же сразу добавил индексы для поиска.
    
    Идеально создать отдельные валидаторы для валидации данных и прогонять их по вставляемым данным.
    Но будем считать что они консистентны )     
    
    **Пятая оптимизация**
    small.json - 0.23s (43.21X)
    medium.json - 0.83s (100.9X)
    large.json - 7.47s

Итого есть два варианта вставки: 
    полностью батчами (utils.rake) и 
    частично батчами (utils_0.rake), частичный вариант немного быстрее (!)


# Вторая часть задания

Делаю по фен шую - установил rack-mini-profiler, meta-request, strong-migrations, bullet, pghero (бомба)

Загрузил данные из файла large.json
На странице рендерится 1004 рейсов 

Первичный взгляд на профайлинг показал:
 - Присутствует рендеринг в цикле
 - Есть N + 1 запрос: 650 запросов при рендеринге trips/index
 
Оптимизируем количество запросов
Рендеринг занимал: 29.419s

**Первая оптимизация**
Убрал N + 1 запрос
9.456s (3.11X)

Оптимизируем шаблоны
**Вторая оптимизация**
5.411s (5.43X)

**Третья оптимизация**
Еще сильнее оптимизируем шаблоны - избегаем лишних включений.
Благо у нас шаблоны - очень простые )
0.629s (15X)

### Далее нужно добавить кеширование, пейджер - и будет просто космос )









  



# TODO тесты на регрессию оптимизации вставки


Города:
6 2 4  6 6 2  4  4 4  2 2
Автобусы:
4 4 11 4 7 13 10 5 10 8 10
Сервисы:
    14   4 11 6  1 6  4 6



Нужны ли ключи в БД?
Использовать вставку большими частями

### TODO Добавить профайлеров
### TODO RSPEC
### TODO Нужно сделать тест на правильную вставку
### TODO Так же сделать тест на деградацию


-----------


# Наивная загрузка данных из json-файла в БД
# rake reload_json[fixtures/small.json]

def time
  st = Time.now
  yield
  Time.now - st
end

def time_profiler(name, &block)
  time = Benchmark.realtime do
    block.call
  end

  puts "Time: #{name}: #{time}"
end

def set_ar_logging(out = STDOUT)
  ActiveRecord::Base.logger = Logger.new(out)
end

class TripForInsert < ActiveRecord::Base
  self.table_name = 'trips'
end

class BusesService < ActiveRecord::Base
end

class BusForInsert < ActiveRecord::Base
  self.table_name = 'buses'
end

task :reload_json, [:file_name] => :environment do |_task, args|
  json = ""
  time_profiler("JSON PARSED") do
    json = JSON.parse(File.read(args.file_name))
  end



  set_ar_logging




  # time_profiler("CREATE UNIQ") do
  #   uniq_buses = Set.new
  #   uniq_cities = Set.new
  #   uniq_services = Set.new
  #
  #   json.each do |trip|
  #     uniq_buses << trip['bus']['number']
  #     uniq_cities << trip['from']
  #     uniq_cities << trip['to']
  #     trip['bus']['services'].each do |s|
  #       uniq_services << s
  #     end
  #   end
  #
  #   pp uniq_buses.count
  #   pp uniq_cities.count
  #   pp uniq_cities
  #   pp uniq_services.count
  #   pp uniq_services
  # end

  # cities_hash = Hash.new { |hash, key| hash[key] = City.create(name: key) }
  # services_hash = Hash.new { |hash, key| hash[key] = Service.create(name: key) }
  # buses_number_to_id = {}
  # buses_services = []
  trips = []
  buses = []
  buses_services_map = {}

  service_names = Set.new
  cities_names = Set.new

  # service_name_to_id = {}

  time_profiler("Loading data") do
    ActiveRecord::Base.transaction do
      time_profiler("DELETE DATA") do
        City.delete_all
        Bus.delete_all
        Service.delete_all
        Trip.delete_all
        ActiveRecord::Base.connection.execute('delete from buses_services;')
      end

      json.each_with_index do |trip, i|
        # from = cities_hash[trip['from']]
        # to = cities_hash[trip['to']]


        cities_names << trip['from'] << trip['to']
        trip['bus']['services'].map { |service| service_names << service }

        bus_number = trip['bus']['number']
        bus_model = trip['bus']['model']

        buses << { number: bus_number, model: bus_model }

        # TODO здесь проверка на то что такого автобуса еще не было


        unless buses_services_map[bus_number]
          buses_services_map[bus_number] = []
          buses_services_map[bus_number] = *trip['bus']['services']
        end

        # pp buses_services_map






        # services = trip['bus']['services'].map { |service| services_hash[service] }



        # bus_id = buses_number_to_id.fetch(bus_number) do |key|
        #   bus_id = BusForInsert.create!(number: bus_number, model: bus_model).id
        #
        #   # buses_services.push(*services.map do |service|
        #   #   { bus_id: bus_id, service_id: service.id }
        #   # end)
        #
        #   buses_number_to_id[key] = bus_id
        # end



        trips << {
          from_id: trip['from'],
          to_id: trip['to'],
          bus_number: bus_number,
          start_time: trip['start_time'],
          duration_minutes: trip['duration_minutes'],
          price_cents: trip['price_cents']
        }

        # trips << {
        #   from_id: from.id,
        #   to_id: to.id,
        #   bus_id: bus_id,
        #   start_time: trip['start_time'],
        #   duration_minutes: trip['duration_minutes'],
        #   price_cents: trip['price_cents']
        # }
      end

      pp "START INSERTING " * 10

      prepared_services = service_names.map { |name| { name: name } }
      ids = Service.import(prepared_services).ids
      services_to_id = service_names.zip(ids).reduce({}) do |result, (name, id)|
        result[name] = id
        result
      end

      pp "SERVICES DONE " * 10

      prepared_cities = cities_names.map { |name| { name: name } }
      ids = City.import(prepared_cities).ids
      cities_to_ids = cities_names.zip(ids).reduce({}) do |result, (name, id)|
        result[name] = id
        result
      end

      pp "CITIES DONE " * 10
      ids = Bus.import(buses).ids
      buses_number_to_ids = buses.zip(ids).reduce({}) do |result, (bus_data, id)|
        result[bus_data[:number]] = id
        result
      end

      pp "BUSES DONE " * 10
      # number, model

      # pp services_to_id
      # pp cities_to_ids
      # pp buses_number_to_ids
      # pp buses_services_map

      prepared_buses_services = buses_services_map.reduce([]) do |result, (bus_number, services)|
        bus_id = buses_number_to_ids[bus_number]

        services.each do |service|
          service_id = services_to_id[service]
          result << { bus_id: bus_id, service_id: service_id }
        end

        result
      end

      # pp prepared_buses_services

      BusesService.import(prepared_buses_services)

      pp "BUSES SERVICES DONE " * 10
      # pp "XXX" * 100
      # { bus_id: bus_id, service_id: service.id }


      prepared_trips = trips.map do |trip|
        # pp trip

        {
          from_id: cities_to_ids[trip[:from]],
          to_id: cities_to_ids[trip[:to]],
          bus_id: buses_number_to_ids[trip[:bus_number]],
          start_time: trip[:start_time],
          duration_minutes: trip[:duration_minutes],
          price_cents: trip[:price_cents]
        }
      end

      # BusesService.import(buses_services)

      # TODO здесь преобразование
      res = Trip.import(prepared_trips)
      # res = Trip.import(trips)
      # pp res.ids


    end
  end
end
