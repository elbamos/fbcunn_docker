A docker build file for `fbcunn` and `tensorflow`, based on the `fbcunn` Dockerfile by @kmatzen and the `tensorflow` Dockerfile included with Tensorflow.

This is intended to solve the problem that both `fbcunn` and `tensorflow` are very sensitive in terms of what versions of Ubuntu, CUDA, and various dependencies they will accept.

This docker image will enable torch with `fbcunn`, and `tensorflow`, with `keras`, to work with an Nvidia GPU. 

A slew of other likely-to-be-needed torch and python packages are installed at the same time.  

This works on a system with Ubuntu 15.10, CUDA 7.5 and CUDN 6.5v2.

It is assumed that the user will modify the launch script to add their data directory to the docker installation. 