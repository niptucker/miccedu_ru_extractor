#!/bin/bash

#################
# Документация #
#################
if [ $# -eq 0 ]
  then
    echo '
Скрипт для извлечения ссылок на регионы со страницы года

На вход подаются:
1) адрес веб-страницы года, на которой есть ссылки на регионы
2) код показателя (на веб-странице находится в графе "№")

Пример запуска:
./extract_from_year.sh "http://indicators.miccedu.ru/monitoring/" "I7.3"
./extract_from_year.sh "http://indicators.miccedu.ru/monitoring/" "../conf/map.txt"
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

echo -e $totalstart
echo -e $notifystart"Ссылка на веб-страницу с ссылками на регионы: $emcolor$url"$msgend
echo -e $notifystart"Код показателя: $emcolor$criterion"$msgend

codename=year`basename "$url" | cut -d'?' -f2 | cut -d'&' -f2 | cut -d'=' -f2`

dirname=$DIR/$codename"_dir"
echo -e $notifystart"Каталог года: $emcolor$dirname"$msgend

urlfile=$dirname/$codename.html
echo -e $notifystart"Страница года сохранится в $emcolor$urlfile"$msgend

regionsfile=$dirname/$codename.txt
echo -e $notifystart"Список ссылок на регионы сохранится в $emcolor$regionsfile"$msgend

mkdir -p "$dirname"

########################################
# Скачивание страницы региона с вузами #
########################################
if [ ! -s "$urlfile" ]
then
    echo -e $notifystart"Скачивается страница $emcolor$url$msgend:"$msgend
    wget "$url" -nv -nc -O "$urlfile"
    recode -f cp1251..utf8 "$urlfile"
else
    echo -e $notifystart"Страница $emcolor$url$notifystart $successcolorуже скачана$notifystart."$msgend
fi

##############################################
# Сохранение ссылок на страницы вузов в файл #
##############################################
url_base=`echo $url | sed 's:[^/]*$::'`
#echo Url base: $url_base
cat "$urlfile" | grep -Po '[^'"'"'\"]*material.php[^'"'"'\"]*' | awk -F\' -v url_base="$url_base" '{print url_base$0}' | tee "$regionsfile"

#exit

echo -e $notifystart"Список ссылок на регионы сохранен в $emcolor$regionsfile$notifystart"$msgend
echo

##############################################
# Запуск обработчика файла со списком ссылок #
##############################################
# echo $DIR/extract_from_regionsfile.sh "$regionsfile" "$criterion"
bash $DIR/extract_from_regionsfile.sh "$regionsfile" "$criterion"
