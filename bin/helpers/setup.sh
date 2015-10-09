#!/bin/bash

#############
# Настройка #
#############
totalstart="\033[32m";
totalend="\033[0m";

msgend="$totalend\033[35m";

errorcolor="\033[31m";
errorstart="$totalend$errorcolorer";
emcolor="\033[33m";
emstart="$totalend$emcolor";
successcolor="\033[32m";
successstart="$totalend$successcolor";
notifycolor="\033[37m";
notifystart="$totalend$notifycolor";

#########################
# Проверка зависимостей #
#########################
command -v wget >/dev/null 2>&1 || { echo -e >&2 $errorstart"\nТребуется программа 'wget'. Установите ее с помощью команды\n\n\tsudo apt-get install wget\n"$totalend; exit 1; }
command -v recode >/dev/null 2>&1 || { echo -e >&2 $errorstart"\nТребуется программа 'recode'. Установите ее с помощью команды\n\n\tsudo apt-get install recode\n"$totalend; exit 1; }
command -v parallel >/dev/null 2>&1 || { echo -e >&2 $errorstart"\nТребуется программа 'parallel'. Установите ее с помощью команды\n\n\tsudo apt-get install parallel\n"$totalend; exit 1; }
command -v xidel >/dev/null 2>&1 || { echo -e >&2 $errorstart"\nТребуется программа 'xidel'. Скачайте ее и установите, как написано на странице\n\n\thttp://videlibri.sourceforge.net/xidel.html#downloads\n"$totalend; exit 1; }
