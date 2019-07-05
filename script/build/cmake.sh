#/bin/bash

cd `dirname $0`
cur_path=`pwd`
echo "cur path is ${cur_path}"

project_name=cmake-3.15.0-rc3

compile_path=${cur_path}/../../opensource/${project_name}
if [ ! -d ${compile_path} ];then
echo "compile path: ${compile_path} is not exist, build ${project_name} failed!"
exit 1
else
echo "compile path is ${compile_path}"
fi
cd ${compile_path}

openssl_path=${cur_path}/../..

./configure -D OPENSSL_INCLUDE_DIR=${openssl_path}/../include \
    -D OPENSSL_SSL_LIBRARIES=${openssl_path}/lib/libssl.so \
    -D OPENSSL_CRYPTO_LIBRARIES=${openssl_path}/lib/libcrypto.so

make clean
make
make install

echo "build ${project_name} succeed!"
