## Актуальная проблема
В нашем проекте возникла серьёзная проблема.

### Импорт данных
При выполнении `bin/setup` в базу данных загружаются данные о рейсах из файла fixtures/small.json
Сама загрузка данных из файла делается очень наивно.

В комплекте с заданием поставляются файлы
```
31M     large.json
3,2M    medium.json
308K    small.json
```

Нужно оптимизировать механизм перезагрузки расписания из файла так, чтобы он обрабатывал файл large.json в пределах минуты.

### Отображение расписаний
Сами страницы расписаний тоже формируются не эффективно и при росте объёмов начинают сильно тормозить.

Нужно найти и устранить проблемы, замедляющие формирование этих страниц.

## Формирование метрики
Для того, чтобы понимать, дают ли мои изменения положительный эффект на быстродействие программы буду использовать такую метрику:
- Время выполнения программы на файле: small.json

Время выполнения исходного кода:
```
Loading data from fixtures/small.json
  7.531087   0.446847   7.977934 (  9.376662)
```

```
# ab -n 10 -c 10 http://localhost:3000/автобусы/Самара/Москва

Concurrency Level:      10
Time taken for tests:   1.874 seconds
Complete requests:      10
Failed requests:        0
Total transferred:      88112 bytes
HTML transferred:       81130 bytes
Requests per second:    5.34 [#/sec] (mean)
Time per request:       1874.175 [ms] (mean)
Time per request:       187.417 [ms] (mean, across all concurrent requests)
Transfer rate:          45.91 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.0      0       0
Processing:   268 1127 449.1    943    1606
Waiting:      268 1127 449.1    943    1606
Total:        268 1127 449.1    943    1606

Percentage of the requests served within a certain time (ms)
  50%    943
  66%   1571
  75%   1596
  80%   1603
  90%   1606
  95%   1606
  98%   1606
  99%   1606
 100%   1606 (longest request)
```

## Feedback-Loop
Для того, чтобы иметь возможность быстро проверять гипотезы я создал задачу `rails feedback:start`, которая позволит мне получать обратную связь по эффективности сделанных изменений за время ~7,5 секунд.

## Вникаем в детали системы, чтобы найти 20% точек роста
Для того, чтобы найти "точки роста" для оптимизации я воспользовался библиотеками benchmark, ab.

Вот какие проблемы удалось найти и решить.

## Оптимизация 1
Импорт данных: замена парсинга на Oj и индексы таблиц бд, существенного изменения метрики не дали.
Чего нельзя сказать про использование гема  activerecord-import.

```
Loading data from fixtures/small.json
  0.462224   0.002725   0.464949 (  0.520389)
```

## Оптимизация 2
Рендеринг: избавляемся от N+1 и рендеринга лишних партиалов.

```
# ab -n 10 -c 10 http://localhost:3000/автобусы/Самара/Москва

Concurrency Level:      10
Time taken for tests:   0.244 seconds
Complete requests:      10
Failed requests:        0
Total transferred:      92284 bytes
HTML transferred:       85340 bytes
Requests per second:    41.03 [#/sec] (mean)
Time per request:       243.738 [ms] (mean)
Time per request:       24.374 [ms] (mean, across all concurrent requests)
Transfer rate:          369.75 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.0      0       0
Processing:    45  143  49.7    142     198
Waiting:       45  143  49.8    142     198
Total:         45  143  49.7    142     198

Percentage of the requests served within a certain time (ms)
  50%    142
  66%    182
  75%    194
  80%    197
  90%    198
  95%    198
  98%    198
  99%    198
 100%    198 (longest request)
```

## Результаты
В результате проделанной оптимизации удалось улучшить метрику системы **c 7.5s до 0.5s**

```
#rails asymptotics:start

Loading data from fixtures/small.json
  0.472344   0.007469   0.479813 (  0.543996)

Loading data from fixtures/medium.json
  2.892941   0.012608   2.905549 (  3.054357)

Loading data from fixtures/large.json
 28.034505   0.102898  28.137403 ( 29.604921)
```
