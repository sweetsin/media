#/bin/bash

cd `dirname $0`
cur_path=`pwd`
echo "build path is ${cur_path}"

project_name=openssl-1.1.1b

compile_path=${cur_path}/../../opensource/${project_name}
if [ ! -d ${compile_path} ];then
echo "comile path:${compile_path} is not exist, build ${project_name} failed"
exit 1
else
echo "compile path is ${compile_path}"
fi
cd ${compile_path}

install_path=${cur_path}/../..
echo "install path is ${install_path}"

./config --prefix=${install_path}

make
make install

echo "build ${project_name} succeed!"
