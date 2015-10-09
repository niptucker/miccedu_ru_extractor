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
command -v wget >/dev/null 2>&1 || { echo -e >&2 $errorstart"\nТребуется программа 'wget'. Установите ее с помощью команды\n\n\tsudo apt-get install wget\n"$totalend; exit 1; }
command -v recode >/dev/null 2>&1 || { echo -e >&2 $errorstart"\nТребуется программа 'recode'. Установите ее с помощью команды\n\n\tsudo apt-get install recode\n"$totalend; exit 1; }
command -v parallel >/dev/null 2>&1 || { echo -e >&2 $errorstart"\nТребуется программа 'parallel'. Установите ее с помощью команды\n\n\tsudo apt-get install parallel\n"$totalend; exit 1; }
command -v xidel >/dev/null 2>&1 || { echo -e >&2 $errorstart"\nТребуется программа 'xidel'. Скачайте ее и установите, как написано на странице\n\n\thttp://videlibri.sourceforge.net/xidel.html#downloads\n"$totalend; exit 1; }

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
if [ ! -f "$urlfile" ]
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
cat "$urlfile" | grep -Po 'material.php[^'"'"'\"]*' | awk -F\' '{print "http://indicators.miccedu.ru/monitoring/"$0}' > "$regionsfile"

echo -e $notifystart"Список ссылок на регионы сохранен в $emcolor$regionsfile$notifystart"$msgend
echo

##############################################
# Запуск обработчика файла со списком ссылок #
##############################################
# echo $DIR/extract_from_regionsfile.sh "$regionsfile" "$criterion"
bash $DIR/extract_from_regionsfile.sh "$regionsfile" "$criterion"
