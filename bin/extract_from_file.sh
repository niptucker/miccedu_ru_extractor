#!/bin/bash

#################
# Документация #
#################
if [ $# -eq 0 ]
  then
    echo '
Скрипт для извлечения значений показателей из определенных веб-страниц Мониторинга miccedu.ru

Извлечения данных происходит из заранее определенных веб-страниц
Список веб-страниц хранится в файле

На вход подаются:
1) путь к файлу, в котором перечислены адреса веб-страниц вузов, из которых нужно извлечь значения показателей.
   (пример: institutes_list.txt)
2) код показателя (на веб-странице находится в графе "№")
   (пример: I7.3)

Пример запуска:
./extract_from_file.sh "example/institutes_list.txt" "I7.3"
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
filename=`readlink -e $1`
criterion=$2

echo -e $totalstart
echo -e $notifystart"Файл с ссылками на страницы вузов: $filename" $msgend
echo -e $notifystart"Код показателя: $criterion" $msgend

dirname=$(dirname "$filename")
echo -e $notifystart"Каталог региона: $dirname" $msgend

instsdir=$dirname/insts
mkdir -p $instsdir
rm $instsdir/*

######################
# Создание CSV-файла #
######################
csv="$dirname/$2.csv"
echo -e -n > "$csv"

################################
# Обход всех ссылок вузов
################################
# delimiter=";"
delimiter="\t"
echo -e $notifystart"Просматриваем файлы каждого вуза и заполняем CSV-файл $csv:" $msgend
while read -r link; do
    echo -e $notifystart"Ссылка $link: " $msgend

    ################################
    # Скачивание всех ссылок вузов #
    ################################
    linkname=$(basename $link)
    linkfile=$instsdir/$linkname
    wget -nv "$link" -O "$linkfile"

    ################################
    # Записываем название вуза и разделитель #
    ################################
    name=`cat $linkfile | recode -f cp1251..utf8 | sed 's/[\ \n\r\s]\+/\ /g' | grep 'Наименование образовательной организации' -A10 | grep 'Регион,' -m1 -B10 | grep -v -E '(Наименование образовательной организации)' | tr "\\n\"" " " | sed 's/^ *//;s/ *$//' | sed 's/;/,/g' | sed 's/[\ \n\r\s]\+/\ /g' | sed 's|<[^>]*>||g' | sed 's/Регион,адрес//g' | xargs`
    echo -e -n $name >> $csv
    echo -e -n $delimiter >> $csv

    echo -e $successstart"Вуз '$name' " $msgend


    ######################################
    # Записываем имя ссылки и разделитель #
    ######################################
    echo -e -n $link >> $csv
    echo -e -n $delimiter >> $csv


    ###################################################################
    # Записываем значение показателя и перенос строки (автоматически) #
    ###################################################################
    value=`cat $linkfile | recode -f cp1251..utf8 | grep $criterion -A20 | sed 's|<[^>]*>|~|g' | xargs | awk -F~ '{print $9}'`
    echo -e $value >> $csv

    echo -e $successstart"$criterion -> $value " $msgend
done < "$filename"

echo -e $successstart"\n\nCSV-файл сохранен в $csv " $msgend

echo -e $totalend

# echo -e "\n\n"
# cat $csv
