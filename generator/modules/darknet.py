# -*- coding: utf-8 -*-
from .__module__ import Module, dependency, source
from .tools import Tools


@dependency(Tools)
@source('git')
class Darknet(Module):

    def build(self):
        use_gpu = 1 if self.composer.cuda_ver else 0

        return r'''
        RUN $GIT_CLONE https://github.com/pjreddie/darknet.git darknet && \
            cd darknet && \
            sed -i 's/GPU=0/GPU=%d/g' Makefile && \
            sed -i 's/CUDNN=0/CUDNN=%d/g' Makefile && \
            make -j"$(nproc)" && \
            cp include/* /usr/local/include && \
            cp *.a /usr/local/lib && \
            cp *.so /usr/local/lib && \
            cp darknet /usr/local/bin
        ''' % (use_gpu, use_gpu)
