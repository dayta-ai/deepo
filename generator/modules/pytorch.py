# -*- coding: utf-8 -*-
from .__module__ import Module, dependency, source, version
from .python import Python


@dependency(Python)
@version('1.2')
@source('pip')
class Pytorch(Module):

    def build(self):
        py_ver = int(float(self.composer.ver(Python))*10)
        if py_ver not in [27, 35, 36, 37]:
            raise NotImplementedError('unsupported python version for pytorch')
        if self.version not in ['1.1', '1.2']:
            raise NotImplementedError('unsupported pytorch version')

        cuver = 'cpu' if self.composer.cuda_ver is None else 'cu%d' % (
            float(self.composer.cuda_ver) * 10)
        if float(self.version) == 1.1:
            torchvisionver = 0.3
        else:
            torchvisionver = 0.4
        return r'''
            $PIP_INSTALL torch=={torchver} torchvision=={torchvisionver} && \
        '''.format(torchver=self.version, torchvisionver=torchvisionver)
