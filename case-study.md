При изучении utils.rake первым делом в глаза бросается обилие find_or_create_by

Решил посмотреть с помощью Benchmark.ips как они выполняются последовательно
```
ActiveRecord::Base.transaction do
  City.delete_all
  Bus.delete_all
  Service.delete_all
  Trip.delete_all
  ActiveRecord::Base.connection.execute('delete from buses_services;')

  Benchmark.ips do |x|
    x.report('find_or_create_by City') do
      json.each { |trip| City.find_or_create_by(name: trip['from']) }
    end

    x.report('Find find_or_create_by services') do
      json.each do |trip|
        trip['bus']['services'].each do |service|
          Service.find_or_create_by(name: service)
        end
      end
    end

    x.report('find_or_create_by Bus') do
      json.each { |trip| Bus.find_or_create_by(number: trip['bus']['number']) }
    end
  end
end
```

Получается так
```
Warming up --------------------------------------
find_or_create_by City
                         1.000  i/100ms
Find find_or_create_by services
                         1.000  i/100ms
find_or_create_by Bus
                         1.000  i/100ms
Calculating -------------------------------------
find_or_create_by City
                          2.134  (± 0.0%) i/s -     11.000  in   5.167181s
Find find_or_create_by services
                          0.491  (± 0.0%) i/s -      3.000  in   6.109831s
find_or_create_by Bus
                          0.497  (± 0.0%) i/s -      3.000  in   6.090513s
```

при этом общее время импорта small.json
11.723580999998376

Окей, пробуем добавить индексы
Показатель времени стал хуже
13.188413999974728

Показатели бенчмарка не "взлетели в небеса"
```
Warming up --------------------------------------
find_or_create_by City
                         1.000  i/100ms
Find find_or_create_by services
                         1.000  i/100ms
find_or_create_by Bus
                         1.000  i/100ms
Calculating -------------------------------------
find_or_create_by City
                          2.102  (± 0.0%) i/s -     11.000  in   5.260946s
Find find_or_create_by services
                          0.510  (± 0.0%) i/s -      3.000  in   5.885058s
find_or_create_by Bus
                          0.441  (± 0.0%) i/s -      3.000  in   6.919219s
```

Окей, индексы не выход (для импорта данных так уж точно)

Другой день, импорт small.json занимает 18-20 секунд
пробую испольщовать gem `oj`

13.56506800011266 s

хмм, после серии тестов среднее время 13-15 секунд. Неплохо, оставляем

Замена AR методов `delete all` на raw sql дает еще чуть выигрыш в пару секунд

Окей, ставим и настраиваем pg_hero

10 000 элементов в small.json генерируют 4,229 запросов `SELECT FROM services` и всего 10 `INSERT INTO services`

Время работы сейчас важнее потребляемой памяти, попробую не делать на каждую строку find_or_create, а сделать массив и вставить c помощью bulk_insert

Стало намного лучше
```
----------Load data from small.json----------
  0.000284   0.001181   1.671884 (  2.216141)
----------Load data from medium.json----------
  0.000137   0.000838   2.695500 (  2.925685)
----------Load data from large.json----------
  0.000154   0.000889  12.920520 ( 14.627362)
```
