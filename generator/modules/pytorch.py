# -*- coding: utf-8 -*-
from .__module__ import Module, dependency, source, version
from .python import Python


@dependency(Python)
@version('1.1')
@source('pip')
class Pytorch(Module):

    def build(self):
        py_ver = int(float(self.composer.ver(Python))*10)
        if py_ver not in [27, 35, 36, 37]:
            raise NotImplementedError('unsupported python version for pytorch')
        if self.version not in ['1.1']:
            raise NotImplementedError('unsupported pytorch version')

        cuver = 'cpu' if self.composer.cuda_ver is None else 'cu%d' % (
            float(self.composer.cuda_ver) * 10)
        return r'''
            $PIP_INSTALL \
                future \
                numpy \
                protobuf \
                enum34 \
                pyyaml \
                typing \
            	torch \
                && \
            $PIP_INSTALL https://download.pytorch.org/whl/{cuver}/torch-{torchver}.0-cp{pyver}-cp{pyver}m-linux_x86_64.whl && \
            $PIP_INSTALL https://download.pytorch.org/whl/{cuver}/torchvision-0.3.0-cp{pyver}-cp{pyver}m-linux_x86_64.whl && \
        '''.format(cuver=cuver, pyver=py_ver, torchver=self.version)
