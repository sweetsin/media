#/bin/bash


which nasm
ret=$?
if [ ${ret} != "0" ];then
    echo "start build nasm"
    sh nasm.sh
    ret=$?
    if [ ${ret} != "0" ];then
        echo "build nasm failed, return ${ret}"
        exit ${ret}
    fi
else
    nasm --version
    ret=$?
    if [ ${ret} != "0" ];then
        sh nasm.sh
        ret=$?
        if [ ${ret} != "0" ];then
            echo "build nasm failed, return ${ret}"
            exit ${ret}
        fi
    fi
fi

which cmake
ret=$?
if [ ${ret} != "0" ];then
    echo "start build cmake"
    sh cmake.sh
    ret=$?
    if [ ${ret} != "0" ];then
        echo "build cmake failed, return ${ret}"
        exit ${ret}
    fi
else
    cmake --version
    ret=$?
    if [ ${ret} != "0" ];then
        sh cmake.sh
        ret=$?
        if [ ${ret} != "0" ];then
            echo "build cmake failed, return ${ret}"
            exit ${ret}
        fi
    fi
fi    

echo "pre build finished!"
