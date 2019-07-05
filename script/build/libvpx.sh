#/bin/bash

cd `dirname $0`
cur_path=`pwd`
echo "cur path is ${cur_path}"

project_name=libvpx-master

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

./configure --enable-shared --enable-pic --disable-static --prefix=${install_path} \
    --enable-vp8 --enable-vp9 --enable-libyuv \
    --enable-vp9-temporal-denoising --enable-vp9-highbitdepth

make clean
make
make install

echo "build ${project_name} succeed!"
