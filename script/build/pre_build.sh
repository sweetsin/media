#/bin/bash

echo "build nasm"
bash nasm.sh

echo "build openssl"
bash openssl.sh

echo "build cmake"
bash cmake.sh

echo "build pre finished!"
