#!/bin/bash
for i in `seq 1 8`; do

    cat <<EOF
E.$i
//table[@id='result']//tr[td='E.$i']/td[1]

E.$i Название
//table[@id='result']//tr[td='E.$i']/td[2]

E.$i Значение
//table[@id='result']//tr[td='E.$i']/td[3]

E.$i Пороговое значение
//table[@id='result']//tr[td='E.$i']/td[4]

E.$i Относительно прошлого года
//table[@id='result']//tr[td='E.$i']/td[5]

EOF

done

