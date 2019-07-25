#/bin/bash

cd `dirname $0`
cur_path=`pwd`
echo "cur path is ${cur_path}"

project_name=opencv-4.1.0

compile_path=${cur_path}/../../opensource/${project_name}
if [ ! -d ${compile_path} ];then
    echo "compile path: ${compile_path} is not exist, build ${project_name} failed!"
exit 1
else
    echo "compile path is ${compile_path}"
fi

build_dir=build
cd ${compile_path}
mkdir -p ${build_dir}
cd ${build_dir}

install_path=${cur_path}/../..
echo "inistall path is ${install_path}"

cmake -D ENABLE_CXX11=0 -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=${install_path} -D WITH_FFMPEG=OFF -D BUILD_opencv_world=ON ..

make -j8

make install

echo "build ${project_name} succeed!"
