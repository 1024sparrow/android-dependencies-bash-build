#!/bin/bash

appname=myapplication
apppath=com/example/myapplication
apppathDotes=com.example.myapplication
mainActivityName=MainActivity

for i in $(ls $MYANDROID/environments)
do
    source $MYANDROID/environments/$i
    echo "$i.) $BUILD_TARGET_DESCRIPTION"
done
#echo -n Выберите цель сборки: 
#read envIndex
#if [ ! -f $MYANDROID/environments/$envIndex ]
#then
#    echo Недопустимый индекс. Выберите число из приведённого выше списка
#    exit 1
#fi
envIndex=4 #
source $MYANDROID/environments/$envIndex

RED='\033[0;31m'
GREEN='\033[1;32m'
YEL='\033[1;33m'
NC='\033[0m'

function error_quite {
    echo -e "${RED}Сборка прервана из-за возникшей ошибки${NC}"
    exit 1
}

function exe {
    echo -e "${GREEN}$1${NC}"
    $1
}

echo -e "${YEL}Удаляем aab (предыдущую сборку)${NC}"
exe "rm -rf aab"

echo -e "${YEL}Создаём директории, куда будет производиться сборка${NC}"
exe "mkdir aab"

echo -e "${YEL}1111${NC}"
#exe "${BUILD_TOOLS}/aapt2 compile dependencies/cardview-1.0.0/res/values/values.xml -o compiled"
#for i in $(ls dependencies)
#for i in cardview-1.0.0 constraintlayout-2.0.4 material-1.3.0 appcompat-1.2.0
for i in cardview-1.0.0 material-1.3.0 constraintlayout-2.0.4 appcompat-1.2.0
do
    if [ -d dependencies/$i ]
    then
        #exe "ls dependencies/$i"
        for i2 in $(ls dependencies/$i/res)
        do
            for i3 in $(ls dependencies/$i/res/$i2)
            do
                exe "${BUILD_TOOLS}/aapt2 compile dependencies/$i/res/$i2/$i3 -o compiled"
            done
        done
    fi
done

for i2 in $(ls res)
do
    for i3 in $(ls res/$i2)
    do
        echo "${BUILD_TOOLS}/aapt2 compile res/$i2/$i3 -o compiled"
    done
done

exe "${BUILD_TOOLS}/aapt2 link -o output.apk -I ${PLATFORM}/android.jar compiled/* --manifest AndroidManifest.xml"

