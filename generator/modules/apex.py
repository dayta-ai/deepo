# -*- coding: utf-8 -*-
from .__module__ import Module, dependency, source
from .python import Python
from .pytorch import Pytorch


@dependency(Python, Pytorch)
@source('git')
class Apex(Module):

    def build(self):
        return r'''
        RUN $GIT_CLONE https://github.com/NVIDIA/apex.git && \
            cd apex && \
            pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./
        '''
