FROM nvidia/cuda:7.5-cudnn4-devel
MAINTAINER Amos Elberg <amos.elberg@gmail.com>

#ENV PATH /torch-distro/install/bin:/usr/local/cuda/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#ENV LD_LIBRARY_PATH /torch-distro/install/lib:/usr/local/cuda/lib64/

#ENV CUDA_HOME /usr/local/cuda
#ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:
ENV LD_LIBRARY_PATH /usr/local/cudnn-7.0-v4:/usr/local/lib:/usr/lib
#ENV PATH /usr/local/cuda-7.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin

RUN apt-get update && \
    apt-get -y install \
		software-properties-common \
		python-software-properties && \ 
	add-apt-repository -y ppa:jtaylor/ipython && \
	apt-get update && \
	apt-get upgrade -y 
RUN apt-get install -y \
	build-essential \
	wget \
	zip \
	curl \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python-pip \
	hdf5-tools \
	libhdf5-dev \
	graphicsmagick \
# torch
	libgraphicsmagick1-dev nodejs npm libfftw3-dev sox libsox-dev libsox-fmt-all \
	cmake libqt4-core libqt4-gui libqt4-dev libjpeg-dev libpng-dev ncurses-dev \
	imagemagick libzmq3-dev gnuplot gnuplot-x11 ipython libreadline-dev \
	libopenblas-dev liblapack-dev \
# after torch
	gfortran \
	libavcodec-dev \
	libavformat-dev \
	libgtk2.0-dev \
	git \
  	g++ \
    	automake \
    	autoconf \
    	autoconf-archive \
    	libtool \
    	libboost1.55-all-dev \
    	libevent-dev \
    	libdouble-conversion-dev \
    	libgoogle-glog-dev \
    	libgflags-dev \
    	liblz4-dev \
    	liblzma-dev \
    	libsnappy-dev \
    	make \
    	zlib1g-dev \
    	binutils-dev \
    	libjemalloc-dev \
    	$extra_packages \
    	flex \
    	bison \
    	libkrb5-dev \
   	libsasl2-dev \
    	libnuma-dev \
    	pkg-config \
    	libssl-dev \
    	libedit-dev \
    	libmatio-dev \
    	libpython-dev \
    	libpython3-dev \
	libswscale-dev \
	python-numpy \
	python-scipy \
	python-matplotlib \
	python-pandas \
	python-sympy \
	python-nose \
	ipython \
	libprotobuf-dev \
	protobuf-compiler \
# opencv 3
	libjpeg8-dev \
	libtiff4-dev \
	libjasper-dev \
	libavcodec-dev \
	libavformat-dev \
	libswscale-dev \
	libv4l-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

RUN git clone -b v0.35.0 --depth 1 https://github.com/facebook/folly /tmp/folly && \
    git clone -b v0.24.0 --depth 1 https://github.com/facebook/fbthrift /tmp/fbthrift && \
    git clone -b v1.0 https://github.com/facebook/thpp /tmp/thpp && \
    git clone -b v1.0 https://github.com/facebook/fblualib /tmp/fblualib && \
    git clone -b v1.0 https://github.com/facebook/fbtorch /tmp/fbtorch && \
    git clone -b v1.0 https://github.com/facebook/fbnn /tmp/fbnn && \
    git clone -b v1.0 https://github.com/facebook/fbcunn /tmp/fbcunn 

RUN cd /tmp/folly/folly && \
	autoreconf -ivf && \
	./configure && \
	make install && \
	ldconfig && \
    cd /tmp/fbthrift/thrift && \
	autoreconf -ivf && \
	./configure && \
	make install && \
	ldconfig

ENV PATH /torch-distro/install/bin:/distro/install/bin:/usr/local/cuda/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN git clone https://github.com/torch/distro.git && \
	cd distro && \
	bash install.sh

RUN cd /tmp/thpp/thpp && \
	./build.sh && \
    cd /tmp/fblualib/fblualib && \
	bash ./build.sh && \
    cd /tmp/fbtorch && \
	luarocks make rocks/fbtorch-scm-1.rockspec 

RUN git clone https://github.com/torch/nn && \
	cd nn && \
	git checkout getParamsByDevice && \
	luarocks make rocks/nn-scm-1.rockspec 

RUN luarocks install nn
RUN luarocks install cunn

RUN cd /tmp && \
	git clone -b R4 https://github.com/soumith/cudnn.torch && \
	cd /tmp/cudnn.torch && \
	luarocks make ./cudnn-scm-1.rockspec
    
# This wasn't in the fbcunn instructions, but when I tried to run the imagenet
# example, it complained it couldn't find fbnn.
RUN cd /tmp/fbnn && \
	luarocks make rocks/fbnn-scm-1.rockspec && \
    cd /tmp/fbcunn && \
	luarocks make rocks/fbcunn-scm-1.rockspec 

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

# Senna 
RUN cd /tmp && \
	git clone https://github.com/torch/senna.git && \
	cd senna && \
	wget http://ml.nec-labs.com/senna/senna-v3.0.tgz && \
	tar -xzvf ./senna-v3.0.tgz && \
	luarocks make rocks/senna-scm-1.rockspec && \
	mv senna* /usr/local/bin/ && \
	cd && \
	rm -rf /tmp/*

# Keras & Tensorflow (not tested)
RUN pip install cython && \
    pip install h5py && \
    pip install scikit-learn && \
    pip install scikit-image && \
    pip install https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.7.1-cp27-none-linux_x86_64.whl && \
    pip install git+git://github.com/fchollet/keras.git && \
    pip install jupyter
	
	
# IPython
EXPOSE 8888

WORKDIR "/root"

CMD ["/bin/bash"]
