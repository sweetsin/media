#/bin/bash

cd `dirname $0`
cur_path=`pwd`
echo "cur path is ${cur_path}"

project_name=xavs2-master

compile_path=${cur_path}/../../opensource/${project_name}/build/linux
if [ ! -d ${compile_path} ];then
echo "compile path: ${compile_path} is not exist, build ${project_name} failed!"
exit 1
else
echo "compile path is ${compile_path}"
fi
cd ${compile_path}

install_path=${cur_path}/../..
echo "install path is ${install_path}"

./configure --enable-shared --enable-pic --prefix=${install_path}
ret=$?
if [ ${ret} != "0" ];then
    echo "configure ${project_name} failed, return ${ret}"
    exit ${ret}
fi

make
ret=$?
if [ ${ret} != "0" ];then
    echo "make ${project_name} failed, return ${ret}"
    exit ${ret}
fi

make install
ret=$?
if [ ${ret} != "0" ];then
    echo "install ${project_name} failed, return ${ret}"
    exit ${ret}
fi

echo "build ${project_name} succeed!"
