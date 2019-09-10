#/bin/bash

cd `dirname $0`
cur_path=`pwd`
echo "cur path is ${cur_path}"

project_name=nasm-2.14.02

compile_path=${cur_path}/../../opensource/${project_name}
if [ ! -d ${compile_path} ];then
    echo "compile path: ${compile_path} is not exist, build ${project_name} failed!"
    exit 1
else
    echo "compile path is ${compile_path}"
fi
cd ${compile_path}

bash autogen.sh
ret=$?
if [ ${ret} != "0" ];then
    echo "autogen.sh failed, return ${ret}"
    exit ${ret}
fi

bash configure
ret=$?
if [ ${ret} != "0" ];then
    echo "configure failed, return ${ret}"
    exit ${ret}
fi

make -j8
ret=$?
if [ ${ret} != "0" ];then
    echo "make failed, return ${ret}"
    exit ${ret}
fi

make install
ret=$?
if [ ${ret} != "0" ];then
    echo "install failed, return ${ret}"
    exit ${ret}
fi

echo "build ${project_name} succeed!"
