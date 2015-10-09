#!/bin/bash

#################
# Документация #
#################
if [ $# -eq 0 ]
  then
    echo '
Скрипт для извлечения значений показателей из всех веб-страниц региона Мониторинга miccedu.ru

Извлечения данных происходит из всех веб-страниц определенного региона
Адрес веб-страницы региона и код показателя, который нужно извлечь,
передаются как параметры вызова скрипта.

На вход подаются:
1) адрес веб-страницы региона, на которой есть ссылки на вузы, из которых нужно извлечь значения показателей.
2) код показателя (на веб-странице находится в графе "№")

Пример запуска:
./extract_from_web.sh "http://indicators.miccedu.ru/monitoring/material.php?type=2&id=10201" "I7.3"
'
    exit
fi

############
# Загрузка #
############
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. $DIR/helpers/setup.sh

############################
# Обработка входных данных #
############################
url=$1
criterion=$2
csv=$3
append=$4
if [ -z "$5" ];
    then
        workdir="$DIR"
    else
        workdir="$5"
fi

echo -e $totalstart
echo -e $notifystart"Ссылка на веб-страницу региона: $emcolor$url"$msgend
echo -e $notifystart"Код показателя: $emcolor$criterion"$msgend

codename=region`basename "$url" | cut -d'?' -f2 | cut -d'&' -f2 | cut -d'=' -f2`

dirname=$workdir/$codename"_dir"
echo -e $notifystart"Каталог региона: $emcolor$dirname"$msgend

urlfile=$dirname/$codename.html
echo -e $notifystart"Страница сохранится в $emcolor$urlfile"$msgend

linksfile=$dirname/$codename.txt
echo -e $notifystart"Список ссылок сохранится в $emcolor$linksfile"$msgend

mkdir -p "$dirname"

########################################
# Скачивание страницы региона с вузами #
########################################
if [ ! -f "$urlfile" ]
then
    echo -e $notifystart"Скачивается страница $emcolor$url$notifystart:" "\n"$msgend
    wget "$url" -nv -nc -O "$urlfile"
    recode -f cp1251..utf8 "$urlfile"
else
    echo -e $notifystart"Страница $emcolor$url$notifystart $successcolorуже скачана$notifystart:" "\n"$msgend
fi

##############################################
# Сохранение ссылок на страницы вузов в файл #
##############################################
cat "$urlfile" | grep -E 'inst.php' | awk -F\' '{print "http://indicators.miccedu.ru/monitoring/"$2}' > "$linksfile"

echo -e $notifystart"Список страниц вузов сохранен в $emcolor$linksfile"$msgend

##############################################
# Запуск обработчика файла со списком ссылок #
##############################################
bash $DIR/extract_from_file.sh "$linksfile" "$criterion" "$csv" "$append" "$workdir"
