#/bin/bash

cd `dirname $0`
cur_path=`pwd`
echo "cur path is ${cur_path}"

project_name=aom

compile_path=${cur_path}/../../opensource/${project_name}
if [ ! -d ${compile_path} ];then
echo "compile path: ${compile_path} is not exist, build ${project_name} failed!"
exit 1
else
echo "compile path is ${compile_path}"
fi
cd ${compile_path}
mkdir -p compile
cd compile

install_path=${cur_path}/../..
echo "inistall path is ${install_path}"

cmake -D BUILD_SHARED_LIBS=1 -D CMAKE_INSTALL_PREFIX=${install_path} ..

make clean
make
make install

echo "build ${project_name} succeed!"
