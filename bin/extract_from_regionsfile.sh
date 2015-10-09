#!/bin/bash

#################
# Документация #
#################
if [ $# -eq 0 ]
  then
    echo '
Скрипт для извлечения значений показателей из страниц определенных регионов Мониторинга miccedu.ru

Извлечения данных происходит из заранее определенных веб-страниц регионов
Список веб-страниц хранится в файле

На вход подаются:
1) путь к файлу, в котором перечислены адреса веб-страниц регионов, из которых нужно извлечь значения показателей.
   (пример: regions_list.txt)
2) код показателя (на веб-странице находится в графе "№")
   (пример: I7.3)

Пример запуска:
./extract_from_regionsfile.sh "example/regions_list.txt" "I7.3"
'
    exit
fi

#############
# Настройка #
#############
totalstart="\033[32m";
totalend="\033[0m";

msgend="$totalend\033[35m";

errorcolor="\033[31m";
errorstart="$totalend$errorcolorer";
emcolor="\033[33m";
emstart="$totalend$emcolor";
successcolor="\033[32m";
successstart="$totalend$successcolor";
notifycolor="\033[37m";
notifystart="$totalend$notifycolor";

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#########################
# Проверка зависимостей #
#########################
command -v wget >/dev/null 2>&1 || { echo -e >&2 $errorstart "\nТребуется программа 'wget'. Установите ее с помощью команды\n\n\tsudo apt-get install wget\n" $totalend; exit 1; }
command -v recode >/dev/null 2>&1 || { echo -e >&2 $errorstart "\nТребуется программа 'recode'. Установите ее с помощью команды\n\n\tsudo apt-get install recode\n" $totalend; exit 1; }
command -v parallel >/dev/null 2>&1 || { echo -e >&2 $errorstart "\nТребуется программа 'parallel'. Установите ее с помощью команды\n\n\tsudo apt-get install parallel\n" $totalend; exit 1; }

############################
# Обработка входных данных #
############################
filename=`readlink -e $1`
criterion=$2

echo -e $totalstart
echo -e $notifystart"Файл с ссылками на страницы регионов года: $emcolor$filename"$msgend
echo -e $notifystart"Код показателя: $emcolor$criterion"$msgend

dirname=$(dirname "$filename")
echo -e $notifystart"Каталог года: $emcolor$dirname"$msgend

regiondir=$dirname/regions
if [ ! -d "$regiondir" ]; then
    mkdir -p $regiondir
fi
# rm $regiondir/*

######################
# Создание CSV-файла #
######################
if [ -f "$criterion" ]; then
    csvname=$(basename $criterion)
else
    csvname="$criterion"
fi
csv=`readlink -e "$dirname"`"/$csvname.csv"
echo -e -n > "$csv"
# echo "$csv"
# exit
################################
# Обход всех ссылок регионов
################################
# delimiter=";"
delimiter="\t"
echo -e $notifystart"Просматриваем файлы каждого региона и дополняем CSV-файл $emcolor$csv$notifystart:"$msgend
echo

while read -r link; do
    link=$(echo $link | sed -e "s/\r//g")

    echo -e $notifystart"Ссылка $emcolor$link$notifystart: "$msgend

    bash $DIR/extract_from_web.sh "$link" "$criterion" "$csv" "append" "$regiondir"

done < "$filename"

echo -e $successstart"\n\nCSV-файл сохранен в $emcolor$csv"$msgend

echo -e $totalend
