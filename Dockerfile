FROM ubuntu:14.04
MAINTAINER Kevin James Matzen <kmatzen@cs.cornell.edu>

ENV PATH /torch-distro/install/bin:/usr/local/cuda/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH /torch-distro/install/lib:/usr/local/cuda/lib64/

RUN apt-get update && \
    apt-get -y install build-essential wget curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

RUN apt-get update && \
    apt-get --purge remove -y nvidia* &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

RUN wget http://developer.download.nvidia.com/compute/cuda/6_5/rel/installers/cuda_6.5.14_linux_64.run -O /tmp/cuda_6.5.14_linux_64.run -q && \
    sh /tmp/cuda_6.5.14_linux_64.run -extract=/tmp/nvidia/ && \
    /tmp/nvidia/NVIDIA-Linux-x86_64-340.29.run -s -N --no-kernel-module && \
    rm -rf /tmp/selfgz7 && \
    /tmp/nvidia/cuda-linux64-rel-6.5.14-18749181.run -noprompt && \
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64 && \
    echo "/usr/local/cuda-6.5/lib64" >> /etc/ld.so.conf.d/cuda.conf && \
    rm -rf /tmp/* && \
    rm -rf /usr/local/cuda-6.5/doc && \
    rm -rf /usr/local/cuda-6.5/jre && \
    rm -rf /usr/local/cuda-6.5/libnsight && \
    rm -rf /usr/local/cuda-6.5/libnvvp && \
    rm -rf /usr/local/cuda-6.5/lib64/*.a && \
    rm -rf /usr/lib32

RUN apt-get update && \
    curl -sk https://raw.githubusercontent.com/torch/ezinstall/master/install-deps | bash && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

RUN git clone https://github.com/soumith/torch-distro.git
RUN cd torch-distro && bash install.sh

# folly doesn't install the first time correctly, so I run this script twice.
RUN apt-get update && \
    curl -sk https://raw.githubusercontent.com/soumith/fblualib/master/install_all.sh | bash && \
    curl -sk https://raw.githubusercontent.com/soumith/fblualib/master/install_all.sh | bash && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

RUN git clone https://github.com/torch/nn && cd nn && git checkout getParamsByDevice && luarocks make rocks/nn-scm-1.rockspec
RUN git clone https://github.com/facebook/fbcunn.git
RUN cd fbcunn && luarocks make rocks/fbcunn-scm-1.rockspec

# cudnn 6.5 R1 actually didn't work despite being the version mentioned in the 
# instructions.  It was missing cudnnGetVersion, I think.  v2 works though.
ADD cudnn-6.5-linux-x64-v2-rc2/cudnn.h /usr/local/cuda/include/
ADD cudnn-6.5-linux-x64-v2-rc2/libcudnn.so.6.5.41 /usr/local/cuda/lib64/
RUN ln -s /usr/local/cuda/lib64/libcudnn.so.6.5.41 /usr/local/cuda/lib64/libcudnn.so.6.5 && \
    ln -s /usr/local/cuda/lib64/libcudnn.so.6.5.41 /usr/local/cuda/lib64/libcudnn.so && \
    ldconfig

# This wasn't in the fbcunn instructions, but when I tried to run the imagenet
# example, it complained it couldn't find fbnn.
RUN git clone https://github.com/facebook/fbnn.git
RUN cd fbnn && luarocks make rocks/fbnn-scm-1.rockspec
