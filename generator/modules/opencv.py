# -*- coding: utf-8 -*-
from .__module__ import Module, dependency, source, version
from .tools import Tools
from .boost import Boost
from .python import Python


@dependency(Tools, Python, Boost)
@source('git')
@version('4.0.1')
class Opencv(Module):

    def build(self):
        return r'''
            ln -fs /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime && \
            DEBIAN_FRONTEND=noninteractive \
                add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main" && \
                apt update && \
                $APT_INSTALL \
                libatlas-base-dev \
                libgflags-dev \
                libgoogle-glog-dev \
                libhdf5-serial-dev \
                libleveldb-dev \
                liblmdb-dev \
                libprotobuf-dev \
                libsnappy-dev \
                protobuf-compiler \
                libopencv-dev \
                yasm \
                libjpeg-dev \
                libjasper-dev \
                libavcodec-dev \
                libavformat-dev \
                libswscale-dev \
                libdc1394-22-dev \
                libv4l-dev \
                libtbb-dev \
                libqt4-dev \
                libgtk2.0-dev \
                libfaac-dev \
                libmp3lame-dev \
                libopencore-amrnb-dev \
                libopencore-amrwb-dev \
                libtheora-dev \
                libvorbis-dev \
                libxvidcore-dev \
                x264 \
                v4l-utils \
                ffmpeg \
                && \
            $GIT_CLONE --branch {0} https://github.com/opencv/opencv ~/opencv && \
            $GIT_CLONE --branch {0} https://github.com/opencv/opencv_contrib.git ~/opencv_contrib && \
            mkdir -p ~/opencv/build && cd ~/opencv/build && \
            cmake -D CMAKE_BUILD_TYPE=RELEASE \
                  -D CMAKE_INSTALL_PREFIX=/usr/local \
                  -D WITH_IPP=OFF \
                  -D WITH_CUDA=OFF \
                  -D WITH_TBB=ON \
                  -D WITH_V4L=ON \
                  -D WITH_QT=ON \                   
                  -D WITH_OPENCL=ON \
                  -D BUILD_TESTS=OFF \
                  -D BUILD_PERF_TESTS=OFF \
                  -D WITH_FFMPEG=ON \
                  -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
                  .. && \
            make -j"$(nproc)" install && \
            ln -s /usr/local/include/opencv4/opencv2 /usr/local/include/opencv2 && \
        '''.format(self.version)
