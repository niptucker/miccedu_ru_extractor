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
2) описание извлекаемых данных:
    - код показателя (на веб-странице находится в графе "№")
      (пример: I7.3)
    - имя файла, в котором описывается формат извлечения

Пример запуска:

./extract_from_file.sh "example/institutes_list.txt" "I7.3"

./extract_from_file.sh "example/institutes_list.txt" "../conf/map.txt"
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
filename=`readlink -e $1`
criterion=$2

echo -e $totalstart
echo -e $notifystart"Файл с ссылками на страницы вузов: $emcolor$filename"$msgend
echo -e $notifystart"Код показателя: $emcolor$criterion"$msgend

dirname=$(dirname "$filename")
echo -e $notifystart"Каталог региона: $emcolor$dirname"$msgend

instsdir=$dirname/insts
if [ ! -d "$instsdir" ]; then
    mkdir -p $instsdir
fi

######################
# Создание CSV-файла #
######################
if [ -z "$3" ];
    then
        if [ -f "$criterion" ];
        then
            csv="$dirname/$(basename $criterion).csv"
        else
            csv="$dirname/$criterion.csv"
        fi
    else
        csv="$3"
fi

# echo "<$4>"
if [[ ! -z "$4" && "$4" -ne "append" && "$4" -ne "a" ]];
    then
        echo -e -n > "$csv"
fi

################################
# Обход всех ссылок вузов
################################
# delimiter=";"
delimiter="\t"
echo -e $notifystart"Просматриваем файлы каждого вуза и заполняем CSV-файл $emcolor$csv$notifystart:"$msgend
echo
while read -r link; do
    link=$(echo $link | sed -e "s/\r//g")

    echo -e $notifystart"Ссылка $emcolor$link$notifystart: "$msgend

    ################################
    # Скачивание всех ссылок вузов #
    ################################
    linkname=`basename $link | cut -d'?' -f2 | cut -d'&' -f2 | cut -d'=' -f2`
    linkfile=$instsdir/$linkname

    if [ ! -s "$linkfile" ]
    then
        wget "$link" -nv -nc -O "$linkfile"
        recode -f cp1251..utf8 "$linkfile"
    fi

    if [ ! -s "$linkfile" ]; then

        echo -e $notifystart"Ссылка $emcolor$link$errorstart не скачана в файл $linkfile "$msgend

    else
      if false; then

          echo "$link -> $linkfile"

      elif [ ! -f "$criterion" ]; then

        ################################
        # Записываем название региона и разделитель #
        ################################
        name=`cat $linkfile | sed 's/[\ \n\r\s]\+/\ /g' | grep -E -m1 "material.php[^<]+>[^<]+" -A10 -o | grep -o -E ">.*" | grep -o -E "[^>]*" | xargs`
        echo -e -n $name >> $csv
        echo -e -n $delimiter >> $csv

        echo -e $successstart"Регион '$emcolor$name$notifystart' "$msgend


        ################################
        # Записываем название вуза и разделитель #
        ################################
        name=`cat $linkfile | sed 's/[\ \n\r\s]\+/\ /g' | grep 'Регион' -A10 | grep 'Регион,' -m1 -B10 | grep -v -E '(Наименование образовательной организации)' | tr "\\n\"" " " | sed 's/^ *//;s/ *$//' | sed 's/;/,/g' | sed 's/[\ \n\r\s]\+/\ /g' | sed 's|<[^>]*>||g' | sed 's/Регион,адрес//g' | xargs`
        echo -e -n $name >> $csv
        echo -e -n $delimiter >> $csv

        echo -e $successstart"Вуз '$emcolor$name$notifystart' "$msgend


        ################################
        # Записываем статус вуза и разделитель #
        ################################
        # name=`cat $linkfile | sed 's/[\ \n\r\s]\+/\ /g' | grep 'Регион' -A10 | grep 'Регион,' -m1 -B10 | grep -v -E '(Наименование образовательной организации)' | tr "\\n\"" " " | sed 's/^ *//;s/ *$//' | sed 's/;/,/g' | sed 's/[\ \n\r\s]\+/\ /g' | sed 's|<[^>]*>||g' | sed 's/Регион,адрес//g' | xargs`
        # echo -e -n $name >> $csv
        # echo -e -n $delimiter >> $csv

        # echo -e $successstart"Вуз '$name' "$msgend


        ######################################
        # Записываем имя ссылки и разделитель #
        ######################################
        echo -e -n $link >> $csv
        echo -e -n $delimiter >> $csv


        ###################################################################
        # Записываем значение показателя и перенос строки (автоматически) #
        ###################################################################
        value=`cat $linkfile | grep -F "$criterion" -A20 -m1 | grep "</tr>" -B20 -m2 | head --lines=-1 | sed 's|<[^>]*>|~|g' | xargs | sed 's|<[^>]*>|~|g' | sed -E 's|\s+| |g' | sed -E 's|( *~+ *)+|~|g' | awk -F~ '{print $4" -- "$5"--"$6}'`
        echo -e -n $value | sed "s| *-- *|\t|g" >> "$csv"

        echo -e $successstart"$criterion -> $value "$msgend

      else
        echo -e -n $link >> $csv
        echo -e -n $delimiter >> $csv

        while IFS=$'\t'  read title expression
        do
            # echo -e "Processing map: $title -> $expression" "\n"

            # set -x #echo on
            value=`xidel -q "$linkfile" -e "$(echo -e $expression)" | tr "\n" " " | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'`
            # set +x #echo off

            # value=`echo -e $value | tr "\n" " " | xargs`
            echo -e -n "$value" >> "$csv"
            echo -e -n "$delimiter" >> "$csv"

            echo -e -n $successstart"$title: "$msgend
            echo -e -n $emstart"$value"$msgend
            echo

        done < <(cat $DIR/../conf/map.txt | sed ':a;N;$!ba;s/\n/\t/g' | sed 's:\t\t:\n:g')

      fi
    fi

    echo -e >> "$csv"

    echo

done < "$filename"

echo -e -n $successstart"\n\nCSV-файл сохранен в "$msgend
echo -e -n $emstart"$csv"$msgend
echo

echo -e $totalend
