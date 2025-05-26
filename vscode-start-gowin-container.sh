#!/bin/bash
CONTAINER=gowin-build

if ! docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER$"; then
  # Контейнера нет — создать и стартовать
  docker run -itd --name $CONTAINER -v "$PWD:/home/gowin/work" gowin-docker bash
elif ! docker ps --format '{{.Names}}' | grep -q "^$CONTAINER$"; then
  # Есть, но не запущен — запустить
  docker start $CONTAINER
fi
