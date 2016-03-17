#!/bin/bash

set -e

export CUDA_SO=$(\ls /usr/lib/x86_64-linux-gnu/libcuda* | \
	xargs -I{} echo '-v {}:{}')
export DEVICES=$(\ls /dev/nvidia* | \
	xargs -I{} echo '--device {}:{}')
docker run -it $CUDA_SO $DEVICES --privileged --net=host -v /mnt/hfsshare:/mnt/hfsshare "$@"
