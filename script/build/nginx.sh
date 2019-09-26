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
    --with-pcre=${compile_path}/../pcre-8.43 \
    --with-zlib=${compile_path}/../zlib-1.2.11 \
    --with-http_ssl_module --with-http_stub_status_module \
    --with-openssl=${compile_path}/../openssl-1.1.1b

ret=$?
if [ ${ret} != "0" ];then
    echo "configure failed, return ${ret}"
    exit 1
fi

make -j8
make install

conf_path=${compile_path}/../../resources/nginx_conf
if [ -d ${conf_path} ];then
    cp ${conf_path}/nginx.conf ${install_path}/conf
    cp ${conf_path}/stat.xsl ${install_path}/html
    echo "use fixed nginx conf"
else
    echo "can't find fixed nginx conf, use default nginx conf"
fi

echo "build ${project_name} succeed!"
