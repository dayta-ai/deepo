# -*- coding: utf-8 -*-
from .__module__ import Module, source


@source('apt')
class Tools(Module):

    def __repr__(self):
        return ''

    def build(self):
        return r'''
            DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
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

            $GIT_CLONE https://github.com/Kitware/CMake ~/cmake && \
            cd ~/cmake && \
            ./bootstrap --system-curl && \
            make -j"$(nproc)" install && \
            '''
