#!/bin/bash

xhost +local:docker

docker run --rm -t \
  -v $(pwd):/home/gowin/work \
  gowin-docker \
  /home/gowin/IDE/bin/gw_sh work.prj
