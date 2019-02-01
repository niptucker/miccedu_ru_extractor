# ВОЗМОЖНО, УСТАРЕЛО!

# Извлечение данных с [сайта мониторинга эффективности вузов](http://indicators.miccedu.ru/monitoring/) за 2015 год

## Как пользоваться:
### Кратко (tl;dr)
Как извлечь данные сразу за год:

 ```bash
git clone https://github.com/niptucker/miccedu_ru_extractor.git
cd miccedu_ru_extractor/bin
./run_extract.sh
```


### Подробно (по шагам)
1. Откройте терминал
1. Скачайте это приложение в какую-нибудь папку:

 ```bash
git clone https://github.com/niptucker/miccedu_ru_extractor.git
```
2. Перейдите в каталог `miccedu_ru_extractor/bin`:

 ```bash
cd miccedu_ru_extractor/bin
```

3. <del>Выберите нужный скрипт для извлечения значений показатей.</del> Запустите скрипт `run_extract.sh`.

Он запустит скрипт извлечения всех данных за данный год (`extract_from_year.sh`)



## Документация (еще подробнее)

### Подготовка к работе
 ```bash
git clone https://github.com/niptucker/miccedu_ru_extractor.git
cd miccedu_ru_extractor/bin
```

### Обычный запуск - извлечение данных за текущий год

```
./run_extract.sh
```


### Подробное описание скриптов:
Есть два вспомогательных скрипта


### Извлечение данных по отдельному показателю по вузам определенного региона
```bash
./extract_from_web.sh "http://indicators.miccedu.ru/monitoring/material.php?type=2&id=10201" "I7.3"
```

#### extract_from_web.sh
 Первый — `extract_from_web.sh` — анализирует страницу региона ([список регионов](http://indicators.miccedu.ru/monitoring/)), скачивает страницы всех вузов выбранного региона и извлекает значение выбранного показателя из всех этих страниц.
 
 На вход скрипту подаются:
 
 1) адрес веб-страницы региона, на которой есть ссылки на вузы, из которых нужно извлечь значения показателей.
 
 2) код показателя (на веб-странице находится в графе '№')

 Пример запуска:

 ```bash
./extract_from_web.sh "http://indicators.miccedu.ru/monitoring/material.php?type=2&id=10201" "I7.3"
```
 Здесь
  
  `"http://indicators.miccedu.ru/monitoring/material.php?type=2&id=10201"` - ссылка на страницу региона (обязательно в кавычках!),
  
  `"I7.3"` - код показателя (в кавычках).

 Итоговый csv-файл `I7.3.csv` будет создан в новом каталоге `region10201_dir` (где `10201` - номер региона)





### Извлечение данных по отдельному показателю по определенным вузам (по списку с ссылками на вузы)
 ```bash
./extract_from_file.sh "example/institutes_list.txt" "I7.3"
```

#### extract_from_file.sh
 Второй — `extract_from_file.sh` — скачивает перечисленные в указанном файле страницы вузов и извлекает значение выбранного показателя из этих страниц.
 
 На вход скрипту подаются:
 
  1) путь к файлу, в котором перечислены адреса веб-страниц вузов, из которых нужно извлечь значения показателей.
   (пример: example/institutes_list.txt)
  
  2) код показателя (на веб-странице находится в графе "№")
   (пример: I7.3)
  
   Пример запуска:

 ```bash
./extract_from_file.sh "example/institutes_list.txt" "I7.3"
```
 Здесь
  
  `"example/institutes_list.txt"` - путь к файлу c ссылками на страницы вузов 
  
  `"I7.3"` - код показателя (в кавычках).

  Итоговый csv-файл `I7.3.csv` будет создан в том же каталоге, что и указанный файл (т. е. в каталоге `example`)

