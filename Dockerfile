FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
ENV QT_QPA_PLATFORM=xcb
ENV USER=gowin

# 🧱 Обновления и базовые утилиты
RUN apt update && apt install -y \
    sudo wget tar xz-utils unzip usbutils \
    libfreetype6 libfontconfig1 libglib2.0-0 libxext6 libsm6 libice6 \
    libasound2 libnss3 libnspr4 libgl1-mesa-glx \
    libx11-xcb1 libxcb1 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
    libxcb-render0 libxcb-render-util0 libxcb-randr0 libxcb-shape0 \
    libxcb-shm0 libxcb-xfixes0 libxcb-xinerama0 libxcb-xinput0 \
    libxkbcommon-x11-0 qt5-default qtbase5-dev qtbase5-dev-tools \
    qt5-qmake qtbase5-dev-tools

# 🧑 Создание пользователя
RUN useradd -ms /bin/bash $USER && echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER $USER
WORKDIR /home/$USER

# 📦 Распаковка IDE (файл должен быть рядом с Dockerfile)
COPY Gowin_V1.9.11.01_Education_Linux.tar.gz .
RUN tar -xzf Gowin_V1.9.11.01_Education_Linux.tar.gz

# 🛠 Установка переменных среды
ENV PATH="/home/$USER/IDE/bin:$PATH"

# 📂 Обеспечиваем наличие платформ Qt
RUN mkdir -p /home/$USER/IDE/plugins/platforms && \
    cp /usr/lib/x86_64-linux-gnu/qt5/plugins/platforms/libqxcb.so /home/$USER/IDE/plugins/qt/platforms/

CMD ["gw_ide"]

