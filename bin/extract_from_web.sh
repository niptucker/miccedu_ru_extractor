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
echo -e $notifystart"Ссылка на веб-страницу региона: $url" $msgend
echo -e $notifystart"Код показателя: $criterion" $msgend

codename=region`basename "$url" | cut -d'?' -f2 | cut -d'&' -f2 | cut -d'=' -f2`

dirname=$DIR/$codename"_dir"
echo -e $notifystart"Каталог региона: $dirname" $msgend

urlfile=$dirname/$codename.html
echo -e $notifystart"Страница сохранится в $urlfile" $msgend

linksfile=$dirname/$codename.txt
echo -e $notifystart"Список ссылок сохранится в $linksfile" $msgend

########################################
# Скачивание страницы региона с вузами #
########################################
mkdir -p "$dirname"
echo -e $notifystart"Скачивается страница $url:" "\n" $msgend
wget "$url" -nv -O "$urlfile"

##############################################
# Сохранение ссылок на страницы вузов в файл #
##############################################
cat "$urlfile" | recode -f cp1251..utf8 | grep -E 'inst.php' | awk -F\' '{print "http://indicators.miccedu.ru/monitoring/"$2}' > "$linksfile"

echo -e $successstart"Список страниц сохранен в $linksfile" "\n" $msgend

##############################################
# Запуск обработчика файла со списком ссылок #
##############################################
bash $DIR/extract_from_file.sh "$linksfile" "$criterion"
