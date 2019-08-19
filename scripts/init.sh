#!/bin/bash

jupyter notebook --ip=0.0.0.0 --port=${JUPYTER_PORT} --NotebookApp.token='daytaai' > jupyter.log 2>&1 &
bash