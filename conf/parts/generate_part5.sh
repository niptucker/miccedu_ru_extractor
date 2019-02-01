#!/bin/bash
names=(
    'Образовательная деятельность 1'
    'Образовательная деятельность 1 (доп)'
    'Образовательная деятельность'
    'Научная деятельность'
    'Кадровый потенциал'
    'Международная деятельность'
    'Инфраструктура'
    'Финансово-экономическая деятельность'
)

nums=(
    'seq 1 1'
    'seq 1 3'
    'seq 2 9'
    'seq 10 20'
    'seq 21 29'
    'seq 30 38'
    'seq 39 47'
    'seq 48 56'
)

for i in "${!names[@]}"; do

    num=$((i+1))
    # echo "$num ";

    for j in `${nums[$i]}`; do

# $j (${names[$i]})
# //table[@id='analis_dop']//tr[not(td[@class='sec'])][td[last()-3]='$j']/td[last()-3]



        if [[ "$i" -eq "1" ]]; then
            cat <<EOF
$j (${names[$i]})
${i}_${j}

$j Название
//table[@id='analis_dop']//tr[not(td[@class='sec'])][not(td[last()-3])][$j]/td[last()-2]

$j Единица измерения
//table[@id='analis_dop']//tr[not(td[@class='sec'])][not(td[last()-3])][$j]/td[last()-1]

$j Значение показателя
//table[@id='analis_dop']//tr[not(td[@class='sec'])][not(td[last()-3])][$j]/td[last()]

EOF

        else
            cat <<EOF
$j (${names[$i]})
//table[@id='analis_dop']//tr[not(td[@class='sec'])][td[last()-3]='$j']/td[last()-3]

$j Название
//table[@id='analis_dop']//tr[not(td[@class='sec'])][td[last()-3]='$j']/td[last()-2]

$j Единица измерения
//table[@id='analis_dop']//tr[not(td[@class='sec'])][td[last()-3]='$j']/td[last()-1]

$j Значение показателя
//table[@id='analis_dop']//tr[not(td[@class='sec'])][td[last()-3]='$j']/td[last()]

EOF

        fi
    done

done

