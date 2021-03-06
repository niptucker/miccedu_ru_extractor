#!/bin/bash
names=(
    'Образовательная деятельность'
    'Научно-исследовательская деятельность'
    'Международная деятельность'
    'Финансово-экономическая деятельность'
    'Инфраструктура'
    'Трудоустройство'
    'Кадровый состав'
)

nums=(
    'seq 1 15'
    'seq 1 16'
    'seq 1 13'
    'seq 1 4'
    'seq 1 8'
    'seq 1 1'
    'seq 1 5'
)

for i in "${!names[@]}"; do

    num=$((i+1))
    # echo "$num ";

    for j in `${nums[$i]}`; do

    cat <<EOF
$num.$j (${names[$i]})
//table[@class='napde'][preceding-sibling::span[1][.="${names[$i]}"]]//tr[td='$num.$j']/concat("'", td[1])

$num.$j Название
//table[@class='napde'][preceding-sibling::span[1][.="${names[$i]}"]]//tr[td='$num.$j']/td[2]

$num.$j Единица измерения
//table[@class='napde'][preceding-sibling::span[1][.="${names[$i]}"]]//tr[td='$num.$j']/td[3]

$num.$j Значение показателя
//table[@class='napde'][preceding-sibling::span[1][.="${names[$i]}"]]//tr[td='$num.$j']/td[4]

EOF

    done


done

