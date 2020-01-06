# ==================================================================
# module list
# ------------------------------------------------------------------
# python        3.7    (apt)
# jupyter       latest (pip)
# mxnet         latest (pip)
# onnx          latest (pip)
# pylint        latest (pip)
# pytorch       1.3    (pip)
# sklearn       latest (pip)
# tensorflow    1.14   (pip)
# apex          latest (git)
# jupyterlab    latest (pip)
# keras         latest (pip)
# opencv        4.0.1  (git)
# ==================================================================

FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04
ENV LANG C.UTF-8
ENV CUDA_HOME /usr/local/cuda
ENV APT_INSTALL "apt-get install -y --no-install-recommends"
ENV PIP_INSTALL "python -m pip --no-cache-dir install --upgrade"
ENV GIT_CLONE "git clone --depth 10"
RUN rm -rf /var/lib/apt/lists/* \
        /etc/apt/sources.list.d/cuda.list \
        /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get update
WORKDIR /tmp/

# ==================================================================
# tools
# ------------------------------------------------------------------

RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        build-essential \
        apt-utils \
        software-properties-common \
        ca-certificates \
        wget \
        git \
        vim \
        curl \
        libcurl4-gnutls-dev \
        zlib1g-dev \
        unzip \
        unrar \
        htop \
        sudo \
        nano \
        net-tools \
        && \
    $GIT_CLONE https://github.com/Kitware/CMake cmake && \
    cd cmake && \
    ./bootstrap --system-curl && \
    make -j"$(nproc)" install

# ==================================================================
# python
# ------------------------------------------------------------------

RUN DEBIAN_FRONTEND=noninteractive \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        python3.7 \
        python3.7-dev \
        python3-distutils-extra \
        && \
    wget -O get-pip.py \
        https://bootstrap.pypa.io/get-pip.py && \
    python3.7 get-pip.py && \
    ln -s /usr/bin/python3.7 /usr/local/bin/python3 && \
    ln -s /usr/bin/python3.7 /usr/local/bin/python && \
    $PIP_INSTALL \
        setuptools \
        && \
    $PIP_INSTALL \
        numpy \
        scipy \
        pandas \
        cloudpickle \
        scikit-learn \
        matplotlib \
        Cython

# ==================================================================
# boost
# ------------------------------------------------------------------

RUN wget -O boost.tar.gz https://dl.bintray.com/boostorg/release/1.69.0/source/boost_1_69_0.tar.gz && \
    tar -zxf boost.tar.gz -C . && \
    cd boost_* && \
    ./bootstrap.sh --with-python=python3.7 && \
    ./b2 install -j"$(nproc)" --prefix=/usr/local

# ==================================================================
# jupyter
# ------------------------------------------------------------------

RUN $PIP_INSTALL \
        jupyter

# ==================================================================
# mxnet
# ------------------------------------------------------------------

RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        libatlas-base-dev \
        graphviz \
        && \
    $PIP_INSTALL \
        mxnet-cu101 \
        gluoncv \
        graphviz

# ==================================================================
# onnx
# ------------------------------------------------------------------

RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        protobuf-compiler \
        libprotoc-dev \
        && \
    $PIP_INSTALL \
        onnx

# ==================================================================
# pylint
# ------------------------------------------------------------------

RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        protobuf-compiler \
        libprotoc-dev \
        && \
    $PIP_INSTALL \
        pylint

# ==================================================================
# pytorch
# ------------------------------------------------------------------

RUN $PIP_INSTALL torch==1.3 torchvision==0.4

# ==================================================================
# sklearn
# ------------------------------------------------------------------

RUN $PIP_INSTALL \
        scikit-learn

# ==================================================================
# tensorflow
# ------------------------------------------------------------------

RUN $PIP_INSTALL \
        tensorflow-gpu==1.14

# ==================================================================
# apex
# ------------------------------------------------------------------

RUN $GIT_CLONE https://github.com/NVIDIA/apex.git && \
    cd apex && \
    pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./

# ==================================================================
# jupyterlab
# ------------------------------------------------------------------

RUN $PIP_INSTALL \
        jupyterlab

# ==================================================================
# keras
# ------------------------------------------------------------------

RUN $PIP_INSTALL \
        h5py \
        keras

# ==================================================================
# opencv
# ------------------------------------------------------------------

RUN ln -fs /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime && \
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
    $GIT_CLONE --branch 4.0.1 https://github.com/opencv/opencv opencv && \
    $GIT_CLONE --branch 4.0.1 https://github.com/opencv/opencv_contrib.git opencv_contrib && \
    mkdir -p opencv/build && cd opencv/build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_IPP=OFF \
          -D WITH_CUDA=OFF \
          -D WITH_TBB=ON \
          -D WITH_V4L=ON \
          -D WITH_QT=ON \                   
          -D WITH_OPENCL=ON \
          -D WITH_GTK=ON \
          -D WITH_LIBV4L=ON \
          -D BUILD_TESTS=OFF \
          -D BUILD_PERF_TESTS=OFF \
          -D WITH_FFMPEG=ON \
          -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
          .. && \
    make -j"$(nproc)" install && \
    ln -s /usr/local/include/opencv4/opencv2 /usr/local/include/opencv2

# ==================================================================
# config & cleanup
# ------------------------------------------------------------------

RUN ldconfig && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* && \
    echo "root:docker" | chpasswd
