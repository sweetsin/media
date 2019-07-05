#/bin/bash

cd `dirname $0`
cur_path=`pwd`
echo "build path is ${cur_path}"

project_name=srt-master

compile_path=${cur_path}/../../opensource/${project_name}
if [ ! -d ${compile_path} ];then
echo "compile path: ${compile_path} is not exist, build ${project_name} failed!"
exit 1
else
echo "compile path is ${compile_path}"
fi
cd ${compile_path}

install_path=${cur_path}/../..
echo "install_path is ${install_path}"

export PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:${install_path}/lib/pkgconfig
echo "PKG_CONFIG_PATH is ${PKG_CONFIG_PATH}"
pkg-config --list-all

./configure --enable-encryption=1 --enable-shared=1 --enable-static=0 --prefix=${install_path} \
    --openssl-crypto-library=../lib/libcrypto.so \
    --openssl-include-dir=../include/ \
    --openssl-ssl-library=../lib/libssl.so

make clean
make
make install

cp -rf ${install_path}/lib/x86_64-linux-gnu/* ${install_path}/lib/
echo "build ${project_name} succeed!"
