#/bin/bash

echo "build x264"
bash x264.sh

echo "build x265"
bash x265.sh

echo "build fdk-aac"
bash fdk-aac.sh

echo "build xavs2"
bash xavs2.sh
ret=$?
if [ ${ret} != "0" ];then
    echo "build xavs failed, return ${ret}"
    exit ${ret}
fi

echo "build davs2"
bash davs2.sh

echo "build aom"
bash aom.sh

echo "build xvid"
bash xvidcore.sh

echo "build srt"
bash srt.sh

echo "build opus"
bash opus.sh

echo "build libvpx"
bash libvpx.sh

echo "build ffmpeg"
bash ffmpeg.sh

echo "build finished!!"
