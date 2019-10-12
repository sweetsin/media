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

pcre_path=${cur_path}/../../opensource/pcre-8.43
if [ ! -d ${pcre_path} ];then
    echo "pcre path:{$pcre_path} is not exist"
    exit 1
else
    echo "pcre path is ${pcre_path}"
    cd ${pcre_path}
    touch --date="`date`" aclocal.m4 Makefile.am configure Makefile.in
    cd -
fi

./configure --prefix=${install_path} \
    --add-module=../nginx-rtmp-module-master \
    --with-http_ssl_module --with-http_stub_status_module \
    --with-stream \
    --with-pcre=${compile_path}/../pcre-8.43 \
    --with-zlib=${compile_path}/../zlib-1.2.11 \
    --with-openssl=${compile_path}/../openssl-1.1.1b

ret=$?
if [ ${ret} != "0" ];then
    echo "configure failed, return ${ret}"
    exit 1
fi

make -j8
ret=$?
if [ ${ret} != "0" ];then
    echo "make failed, return ${ret}"
    exit 1
fi

make install
ret=$?
if [ ${ret} != "0" ];then
    echo "make install failed, return ${ret}"
    exit 1
fi

conf_path=${compile_path}/../../resources/nginx_conf
if [ -d ${conf_path} ];then
    cp ${conf_path}/nginx.conf ${install_path}/conf
    cp ${conf_path}/stat.xsl ${install_path}/html
    echo "use fixed nginx conf"
else
    echo "can't find fixed nginx conf, use default nginx conf"
fi

echo "build ${project_name} succeed!"
