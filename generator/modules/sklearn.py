# -*- coding: utf-8 -*-
from .__module__ import Module, dependency, source
from .python import Python

@dependency(Python)
@source('pip')
class Sklearn(Module):

    def build(self):
        return r'''
        RUN $PIP_INSTALL \
                scikit-learn
        '''
