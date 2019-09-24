#/bin/bash

cd `dirname $0`
cur_path=`pwd`
echo "cur path is ${cur_path}"

project_name=nginx-1.16.1

compile_path=${cur_path}/../../opensource/${project_name}
if [ ! -d ${compile_path} ];then
echo "compile path: ${compile_path} is not exist, build ${project_name} failed!"
exit 1
else
echo "compile path is ${compile_path}"
fi
cd ${compile_path}

install_path=/root/nginx
echo "inistall path is ${install_path}"

make clean

./configure --prefix=${install_path} --add-module=../nginx-rtmp-module-master \
    --with-http_ssl_module --with-http_stub_status_module \
    --with-openssl=/root/src/media/opensource/openssl-1.1.1b

ret=$?
if [ ${ret} != "0" ];then
    echo "configure failed, return ${ret}"
    exit 1
fi

make -j8
make install

cp ${cur_path}/nginx_conf/nginx.conf /root/nginx/conf/
cp ${cur_path}/nginx_conf/stat.xsl /root/nginx/html/

echo "build ${project_name} succeed!"
