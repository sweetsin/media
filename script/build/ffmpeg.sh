#/bin/bash

cd `dirname $0`
cur_path=`pwd`
echo "cur path is ${cur_path}"

project_name=ffmpeg-4.1.3

compile_path=${cur_path}/../../opensource/${project_name}
if [ ! -d ${compile_path} ];then
echo "compile path: ${compile_path} is not exist, build ${project_name} failed!"
exit 1
else
echo "compile path is ${compile_path}"
fi
cd ${compile_path}

install_path=${cur_path}/../..
echo "install path is ${install_path}"

export PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:${install_path}/lib/pkgconfig

pkg-config --list-all

./configure --enable-shared --enable-pic --disable-static --enable-rpath --prefix=${install_path} \
    --extra-cflags="-I../../include" --extra-ldflags="-L../../lib"  \
    --enable-libsrt \
    --enable-libx264 --enable-gpl \
    --enable-libx265 \
    --enable-libxavs2 --enable-libdavs2 \
    --enable-libfdk-aac --enable-nonfree \
    --enable-libvpx \
    --enable-libxvid \
    --enable-libaom \
    --enable-libopus

make clean
make
make install

echo "build ${project_name} succeed!"
