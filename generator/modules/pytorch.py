# -*- coding: utf-8 -*-
from .__module__ import Module, dependency, source, version
from .python import Python

@dependency(Python)
@version('1.4')
@source('pip')
class Pytorch(Module):

    def build(self):
        py_ver = int(float(self.composer.ver(Python))*10)
        if py_ver not in [27, 35, 36, 37]:
            raise NotImplementedError('unsupported python version for pytorch')
        if self.version not in ['1.1', '1.2', '1.3', '1.3.1', '1.4']:
            raise NotImplementedError('unsupported pytorch version')

        cuver = 'cpu' if self.composer.cuda_ver is None else 'cu%d' % (
            float(self.composer.cuda_ver) * 10)
        if str(self.version)[:3] == '1.1':
            torchvisionver = '0.3'
        elif str(self.version) == '1.2':
            torchvisionver = '0.4'
        elif str(self.version) == '1.3':
            torchvisionver = '0.4.1'            
        elif str(self.version) == '1.3.1':
            torchvisionver = '0.4.2'
        elif str(self.version) == '1.4':
            torchvisionver = '0.5'
            return r'''
            RUN $PIP_INSTALL torch=={torchver} torchvision=={torchvisionver}
            '''.format(torchver=self.version, torchvisionver=torchvisionver)

        return r'''
        RUN $PIP_INSTALL torch=={torchver} torchvision=={torchvisionver} Pillow==6.1
        '''.format(torchver=self.version, torchvisionver=torchvisionver)
