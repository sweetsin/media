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

bash bootstrap
ret=$?
if [ ${ret} != "0" ];then
    echo "boostrap failed, return ${ret}"
    exit ${ret}
fi

make -j8
ret=$?
if [ ${ret} != "0" ];then
    echo "make failed, return ${ret}"
    exit ${ret}
fi

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/src/media/lib
make install
ret=$?
if [ ${ret} != "0" ];then
    echo "install failed, return ${ret}"
    exit ${ret}
fi

echo "build ${project_name} succeed!"
