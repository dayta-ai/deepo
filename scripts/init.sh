#!/bin/bash

jupyter lab --ip=0.0.0.0 \
            --port=${JUPYTER_PORT} \
            --NotebookApp.token='daytaai' \
            --notebook-dir=~/workspace \
            > jupyter.log 2>&1 &
bash
