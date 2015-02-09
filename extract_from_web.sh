#!/bin/sh

# Скрипт для извлечения значений показателей из всех веб-страниц региона Мониторинга miccedu.ru
#
# Извлечения данных происходит из всех веб-страниц определенного региона
# Адрес веб-страницы региона и код показателя, который нужно извлечь,
# передаются как параметры вызова скрипта.
#
# На вход подаются:
# - адрес веб-страницы региона, на которой есть ссылки на вузы, из которых нужно извлечь значения показателей.
# - код показателя (на веб-странице находится в графе "№")
#
# Пример запуска: ./extract_from_web.sh http://miccedu.ru/monitoring/materials/reg_10201.htm I9.1

url=$1
echo $url
filename=$(basename "$url")

dirname=`echo $filename | cut -d'.' -f1`
criterion=$2


# Скачать страницу региона с вузами
mkdir $dirname
cd $dirname
wget $url

csv="$2.csv"
echo -n > $csv
csv="../$csv"

# Выбрать все ссылки на вузы и скачать их в соседнюю папку
mkdir insts
cd insts
cat ../$filename | recode cp1251...utf8 | grep -E '(inst_|filial_)' | awk -F\" '{print "http://miccedu.ru/monitoring/materials/" $2}' | xargs wget

for file in *.htm; do
    echo "Process $file to $csv..."

    lynx --dump $file | sed 's/[\ \n\r\s]\+/\ /g' | grep 'Наименование образовательной организации' -A10 | grep 'Регион,' -m1 -B10 | grep -v -E '(Наименование образовательной организации|Регион,)' | tr "\\n\"" " " | sed 's/^ *//;s/ *$//' | sed 's/;/,/g' | sed 's/[\ \n\r\s]\+/\ /g' >> $csv
    echo -n ';' >> $csv
    echo -n $file >> $csv
    echo -n ';' >> $csv
    lynx --dump $file | grep $criterion -A20 | sed ':a;N;$!ba;s/\n/|/g' | sed -e 's/||\+/~/g' | awk -F~ '{print $4}' | sed 's/^ *//;s/ *$//' >> $csv

    echo "$file done!";
done;



