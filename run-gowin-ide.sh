docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -e LIBGL_ALWAYS_SOFTWARE=1 \
  -e QT_XCB_GL_INTEGRATION=none \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /media/hk-51/pt/fpga/tang_fpga:/home/gowin/work \
  --device /dev/bus/usb \
  --name gowin \
  gowin-ide
