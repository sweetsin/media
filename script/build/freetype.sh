#/bin/bash

cd `dirname $0`
cur_path=`pwd`
echo "cur path is ${cur_path}"

project_name=freetype-2.10.0

compile_path=${cur_path}/../../opensource/${project_name}
if [ ! -d ${compile_path} ];then
echo "compile path: ${compile_path} is not exist, build ${project_name} failed!"
exit 1
else
echo "compile path is ${compile_path}"
fi
cd ${compile_path}

install_path=${cur_path}/../..
echo "inistall path is ${install_path}"

./configure --enable-shared --prefix=${install_path}

ret=$?
if [ ${ret} != "0" ];then
    echo "configure failed, return ${ret}"
    exit 1
fi

make clean
make -j8
make install

echo "build ${project_name} succeed!"
