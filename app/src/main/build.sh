#!/bin/bash
# скрипт, собирающий проект под Android
# Реализация основана на статье, расположенной по адресу http://www.hanshq.net/command-line-android.html

appname=myapplication
apppath=com/example/myapplication
apppathDotes=com.example.myapplication
mainActivityName=MainActivity

function exe {
    echo "$1"
    $1
}

# ./gradlew app:androidDependencies
# releaseCompileClasspath - Dependencies for compilation
dependencies=(
    com.google.android.material:material:1.3.0 #@aar
    androidx.constraintlayout:constraintlayout:2.0.4 #@aar
    androidx.appcompat:appcompat:1.2.0 #@aar
    androidx.viewpager2:viewpager2:1.0.0 #@aar
    androidx.fragment:fragment:1.1.0 #@aar
    androidx.appcompat:appcompat-resources:1.2.0 #@aar
    androidx.drawerlayout:drawerlayout:1.0.0 #@aar
    androidx.coordinatorlayout:coordinatorlayout:1.1.0 #@aar
    androidx.dynamicanimation:dynamicanimation:1.0.0 #@aar
    androidx.recyclerview:recyclerview:1.1.0 #@aar
    androidx.transition:transition:1.2.0 #@aar
    androidx.vectordrawable:vectordrawable-animated:1.1.0 #@aar
    androidx.vectordrawable:vectordrawable:1.1.0 #@aar
    androidx.viewpager:viewpager:1.0.0 #@aar
    androidx.legacy:legacy-support-core-utils:1.0.0 #@aar
    androidx.loader:loader:1.0.0 #@aar
    androidx.activity:activity:1.0.0 #@aar
    androidx.customview:customview:1.0.0 #@aar
    androidx.core:core:1.3.1 #@aar
    androidx.cursoradapter:cursoradapter:1.0.0 #@aar
    androidx.cardview:cardview:1.0.0 #@aar
    androidx.lifecycle:lifecycle-runtime:2.1.0 #@aar
    androidx.versionedparcelable:versionedparcelable:1.1.0 #@aar
    androidx.collection:collection:1.1.0 #@aar
    androidx.lifecycle:lifecycle-viewmodel:2.1.0 #@aar
    androidx.savedstate:savedstate:1.0.0 #@aar
    androidx.lifecycle:lifecycle-livedata:2.0.0 #@aar
    androidx.lifecycle:lifecycle-livedata-core:2.0.0 #@aar
    androidx.lifecycle:lifecycle-common:2.1.0 #@aar
    androidx.arch.core:core-runtime:2.0.0 #@aar
    androidx.arch.core:core-common:2.1.0 #@aar
    androidx.interpolator:interpolator:1.0.0 #@aar
    androidx.documentfile:documentfile:1.0.0 #@aar
    androidx.localbroadcastmanager:localbroadcastmanager:1.0.0 #@aar
    androidx.print:print:1.0.0 #@aar
    androidx.annotation:annotation:1.1.0 #@aar
    androidx.constraintlayout:constraintlayout-solver:2.0.4 #@aar
    androidx.annotation:annotation-experimental:1.0.0 #@aar
)

declare -i state=0
for i in ${dependencies[@]}
do
    state=0
    OIFS=$IFS
    IFS=:
    for i2 in $i
    do
        if [ $state -eq 0 ]
        then
            OIFS2=$IFS
            IFS=.
            sourceId=($i2)
            sourceId=${sourceId[@]}
            IFS=$OIFS2
        elif [ $state -eq 1 ]
        then
            name=$i2
        elif [ $state -eq 2 ]
        then
            version=$i2
        fi
        state+=1
    done
    IFS=$OIFS
    mkdir boris_dependencies #
    pushd boris_dependencies
        #exe "wget https://dl.google.com/android/maven2/com/google/android/material/material/1.3.0/material-1.3.0.aar"
        if [ ! -f ${name}-${version}.aar ]
        then
            echo "${name}-${version}"

            state=0
            url=
            for i in $sourceId
            do
                echo "== $i"
                prevState=$state
                if [ $state -eq 0 ]
                then
                    if [ $i == com ]
                    then
                        state=11
                    elif [ $i == androidx ]
                    then
                        state=21
                    fi
                elif [ $state -eq 11 ]
                then
                    if [ $i == google ]
                    then
                        state=12
                    fi
                elif [ $state -eq 12 ]
                then
                    if [ $i == android ]
                    then
                        state=13
                    fi
                elif [ $state -eq 13 ]
                then
                    url=https://dl.google.com/android/maven2/com/google/android/$i/$name/$version/$name-$version.aar
                    state=200
                elif [ $state -eq 21 ]
                then
                    url=https://dl.google.com/android/maven2/androidx/$i/$name/$version/$name-$version.aar
                    state=200
                fi

                if [ $state -eq $prevState ]
                then
                    echo unknown source
                fi
            done

            if [ -z $url ]
            then
                echo "unknown source"
            else
                exe "wget $url"
            fi
        fi
    popd
done

#dependencies=(
#    appcompat-1.2.0
#    # https://dl.google.com/android/maven2/androidx/constraintlayout/constraintlayout/2.0.4/constraintlayout-2.0.4.aar
#    constraintlayout-2.0.4
#    material-1.3.0
#    # https://dl.google.com/android/maven2/androidx/cardview/cardview/1.0.0/cardview-1.0.0.aar
#    cardview-1.0.0
#    # implementation 'com.android.support:design:27.0.2'
#    design-27.0.2
#)

exit 0 #

#source /home/boris/da/pro/android-console-build-tools/environments/2
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
YEL='\033[1;33m'
NC='\033[0m'

function error_quite {
    echo -e "${RED}Сборка прервана из-за возникшей ошибки${NC}"
    exit 1
}

echo -e "${YEL}Удаляем build (предыдущую сборку)${NC}"
rm -rf build

echo -e "${YEL}Создаём директории, куда будет производиться сборка${NC}"
mkdir -p build/gen build/obj build/apk || error_quite

echo -e "${YEL}Генерируем специфичный для версии анроида файл AndroidManifest.xml${NC}"
sed "s/\${sdkVersion}/${SDK_VERSION}/" AndroidManifest.xml > build/gen/AndroidManifest.xml

echo -e "${YEL}Генерируем java-файлы (R.java), отображающие содержимое ресурсов (которые описаны в XML)${NC}"
echo "\"${BUILD_TOOLS}/aapt\" package -f -m -J build/gen/ -S res -M build/gen/AndroidManifest.xml -I \"${PLATFORM}\"/android.jar"
#"${BUILD_TOOLS}/aapt" package -f -m -J build/gen/ -M build/gen/AndroidManifest.xml -I "${PLATFORM}/android.jar" -j dependencies/appcompat-1.2.0/classes.jar && echo 11111 &&
#"${BUILD_TOOLS}/aapt" package -f -m -J build/gen/ -S dependencies/appcompat-1.2.0/res -S dependencies/constraintlayout-2.0.4/res -M dependencies/appcompat-1.2.0/AndroidManifest.xml -I "${PLATFORM}/android.jar" -j dependencies/appcompat-1.2.0/classes.jar -j dependencies/constraintlayout-2.0.4/classes.jar && echo 11111 &&
#"${BUILD_TOOLS}/aapt" package -f -m -J build/gen/ -S dependencies/appcompat-1.2.0/res -S dependencies/constraintlayout-2.0.4/res dependencies/material-1.3.0/res -M AndroidManifest.xml -I "${PLATFORM}/android.jar" -j dependencies/appcompat-1.2.0/classes.jar -j dependencies/constraintlayout-2.0.4/classes.jar --auto-add-overlay && echo 11111 && # dependencies/material-1.3.0/res/values/values.xml: error: Duplicate file.
#"${BUILD_TOOLS}/aapt" package -f -m -J build/gen/ -S dependencies/appcompat-1.2.0/res -S dependencies/constraintlayout-2.0.4/res -S dependencies/material-1.3.0/res -S dependencies/cardview-1.0.0/res -M AndroidManifest.xml   -I "${PLATFORM}/android.jar" -j dependencies/appcompat-1.2.0/classes.jar -j dependencies/constraintlayout-2.0.4/classes.jar -j dependencies/cardview-1.0.0/classes.jar -j dependencies/material-1.3.0/classes.jar --auto-add-overlay  && echo 11111 && # dependencies/material-1.3.0/res/values/values.xml: error: Duplicate file.
#"${BUILD_TOOLS}/aapt" package -f -m -J build/gen/ -S res -M build/gen/AndroidManifest.xml -I "${PLATFORM}/android.jar" && echo 2222222 || error_quite

exe "$BUILD_TOOLS/aapt package -f -m \
	-J build/gen \
	-M build/gen/AndroidManifest.xml \
	-S res \
    -S dependencies/appcompat-1.2.0/res \
    -S dependencies/material-1.3.0/res \
    -S dependencies/constraintlayout-2.0.4/res \
	-I "${PLATFORM}/android.jar" --auto-add-overlay " ||
error_quite
# -S dependencies/cardview-1.0.0/res \

echo -e "${YEL}Собираем байт-код${NC}"
# get kotlin compiler: https://kotlinlang.org/docs/command-line.html
kotlinc java build/gen -include-runtime \
    -cp "${PLATFORM}"/android.jar:dependencies/appcompat-1.2.0/classes.jar:dependencies/constraintlayout-2.0.4/classes.jar:dependencies/material-1.3.0/classes.jar \
	-d build/compiled.jar || error_quite

#echo -e "${YEL}Собираем байт-код для нашего Java-приложения. Делаем байт-код для версии Java 7.${NC}"
#javac \
#    -source 1.7 \
#    -target 1.7 \
#    -bootclasspath "${JAVA_HOME}/jre/lib/rt.jar" \
#    -classpath "${PLATFORM}/android.jar"  \
#    -classpath /home/boris/da/pro/android-console-build-tools/dependencies/appcompat-1.2.0/classes.jar \
#    -classpath /home/boris/da/pro/android-console-build-tools/dependencies/material-1.3.0/classes.jar \
#    -classpath /home/boris/da/pro/android-console-build-tools/dependencies/constraintlayout-2.0.4/classes.jar \
#    -d build/obj build/gen/${apppath}/R.java java/${apppath}/MainActivity.java || error_quite
#echo "Вот мы получили байт-код Java (файлы .class). Но Android использует байт-код другого формата - Dalvik (файлы .dex)"

#echo -e "${YEL}Преобразуем стандартный байт-код в Андроидовский (Dalvik) байт-код${NC}"
#"${BUILD_TOOLS}/dx" --dex --output=build/apk/classes.dex build/obj/ || error_quite

#echo -e "${YEL}Запаковываем .dex-файлы, манифест и ресурсы в APK${NC}"
#"${BUILD_TOOLS}/aapt" package -f -M build/gen/AndroidManifest.xml -A assets -S res/ -I "${PLATFORM}/android.jar" -F build/${appname}.unsigned.apk build/apk/ || error_quite
#"${BUILD_TOOLS}/aapt" package -f -M build/gen/AndroidManifest.xml -S res/ -I "${PLATFORM}/android.jar" -F build/${appname}.unsigned.apk build/apk/ || error_quite
#echo "У нас есть apk-файл, но прежде чем его устанавливать на смартфон, его необходимо подписать..."

#echo -e "${YEL}Делаем так, чтобы после распаковки нашего apk файлы были выровнены по размеру блока 4 байта${NC}"
#"${BUILD_TOOLS}/zipalign" -f -p 4 build/${appname}.unsigned.apk build/${appname}.aligned.apk || error_quite

#if [ ! -f keystore.jks ]
#then
#    echo -e "${YEL}Генерируем ключ (будут запрашиваться данные у пользователя)${NC}"
#    keytool -genkeypair -keystore keystore.jks -alias androidkey -validity 10000 -keyalg RSA -keysize 2048 -storepass android -keypass android || error_quite
#fi

#echo -e "${YEL}Подписываем полученным ключом наш apk${NC}"
#"${BUILD_TOOLS}/apksigner" sign --ks keystore.jks --ks-key-alias androidkey --ks-pass pass:android --key-pass pass:android --out build/${appname}.apk build/${appname}.aligned.apk || error_quite

echo "#!/bin/bash
# установка приложения на устройство пользователя по USB

adb install -r build/$(basename com/example/myapplication).apk
adb shell am start -n ${apppathDotes}/${apppathDotes}.${mainActivityName}
" > deploy_and_run.sh
chmod +x deploy_and_run.sh

