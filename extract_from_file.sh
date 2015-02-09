#!/bin/sh

# ; $1=page url
# ; $2=criterion name
# ; Пример запуска: ./extract_from_file.sh institutes_list.txt I9.1

filename=$1
dirname=`echo $filename | cut -d'.' -f1`
criterion=$2


# # ; скачать страницу региона с вузами
mkdir $dirname
cd $dirname

csv="$2.csv"
echo -n > $csv
csv="../$csv"

mkdir insts
cd insts

# # ; выбрать все ссылки на вузы и скачать их в соседнюю папку
cat ../../$filename | recode cp1251...utf8 | grep -E '(inst_|filial_)' | awk -F\" '{print $1}' | xargs wget


for file in *.htm; do
    echo "Process $file to $csv..."

    lynx --dump $file | sed 's/[\ \n\r\s]\+/\ /g' | grep 'Наименование образовательной организации' -A10 | grep 'Регион,' -m1 -B10 | grep -v -E '(Наименование образовательной организации|Регион,)' | tr "\\n\"" " " | sed 's/^ *//;s/ *$//' | sed 's/;/,/g' | sed 's/[\ \n\r\s]\+/\ /g' >> $csv
    echo -n ';' >> $csv
    echo -n $file >> $csv
    echo -n ';' >> $csv
    lynx --dump $file | grep $criterion -A20 | sed ':a;N;$!ba;s/\n/|/g' | sed -e 's/||\+/~/g' | awk -F~ '{print $4}' | sed 's/^ *//;s/ *$//' >> $csv
    # echo >> $csv

    echo "$file done!";
done;



