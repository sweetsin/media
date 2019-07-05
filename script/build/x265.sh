#/bin/bash

cd `dirname $0`
cur_path=`pwd`
echo "cur path is ${cur_path}"

project_name=x265_3.0

compile_path=${cur_path}/../../opensource/${project_name}/build/linux
if [ ! -d ${compile_path} ];then
echo "compile path: ${compile_path} is not exist, build ${project_name} failed!"
exit 1
else
echo "compile path is ${compile_path}"
fi
cd ${compile_path}

install_path=${cur_path}/../..
echo "inistall path is ${install_path}"

cmake -D BIN_INSTALL_DIR=bin \
     -D CMAKE_INSTALL_PREFIX=${install_path} \
	 -D ENABLE_HDR10_PLUS=ON \
	 -D ENABLE_LIBNUMA=OFF \
	 -D ENABLE_PIC=ON \
	 -D ENABLE_SHARED=ON \
	 -D HIGH_BIT_DEPTH=ON \
	 ../../source

make clean
make
make install

echo "build ${project_name} succeed!"
