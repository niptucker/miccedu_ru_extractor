
############
# Загрузка #
############
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. $DIR/helpers/setup.sh


bash "$DIR/extract_from_year.sh" "http://indicators.miccedu.ru/monitoring/?m=vpo" "$DIR/../conf/map.txt"
