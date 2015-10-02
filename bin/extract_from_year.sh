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

errorstart="$totalend\033[31m";
successstart="$totalend\033[32m";
notifystart="$totalend\033[37m";

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
url=$1
criterion=$2

echo -e $totalstart
echo -e $notifystart"Ссылка на веб-страницу с ссылками на регионы: $url" $msgend
echo -e $notifystart"Код показателя: $criterion" $msgend

codename=year`basename "$url" | cut -d'?' -f2 | cut -d'&' -f2 | cut -d'=' -f2`

dirname=$DIR/$codename"_dir"
echo -e $notifystart"Каталог года: $dirname" $msgend

urlfile=$dirname/$codename.html
echo -e $notifystart"Страница года сохранится в $urlfile" $msgend

regionsfile=$dirname/$codename.txt
echo -e $notifystart"Список ссылок на регионы сохранится в $regionsfile" $msgend

########################################
# Скачивание страницы региона с вузами #
########################################
mkdir -p "$dirname"
echo -e $notifystart"Скачивается страница $url:" "\n" $msgend
wget "$url" -nv -O "$urlfile"

##############################################
# Сохранение ссылок на страницы вузов в файл #
##############################################
cat "$urlfile" | recode -f cp1251..utf8 | grep -Po 'material.php[^'"'"'\"]*' | awk -F\' '{print "http://indicators.miccedu.ru/monitoring/"$0}' > "$regionsfile"

echo -e $successstart"Список ссылок на регионы сохранен в $regionsfile" "\n" $msgend

##############################################
# Запуск обработчика файла со списком ссылок #
##############################################
# echo $DIR/extract_from_regionsfile.sh "$regionsfile" "$criterion"
bash $DIR/extract_from_regionsfile.sh "$regionsfile" "$criterion"
