# Run collin80/SavvyCAN desktop app in a container
#
# docker run -it \
#   --user $(id -u) \
#   -e DISPLAY=unix$DISPLAY \
#   -v /tmp/.X11-unix:/tmp/.X11-unix \
#   -v "$(pwd)":/home/projects \
#   savvycan "$@"

FROM ubuntu:18.04

ENV QT_MAJOR_VERSION=5.11
ENV QT_MINOR_VERSION=2
ENV QT_FULL_VERSION=$QT_MAJOR_VERSION.$QT_MINOR_VERSION

RUN apt-get update && apt-get install -y \
      ca-certificates \
      g++ \
      git \
      make \
      unzip \
      wget \
      libdbus-1-3 \
      libfontconfig \
      libglib2.0-0 \
      libx11-6 \
      libx11-xcb-dev \
      libxi6 \
      libgl1-mesa-dev \
      mesa-common-dev \
      libxrender1 \
      --no-install-recommends \
      && rm -rf /var/lib/apt/lists/*

# Install Qt
RUN wget https://download.qt.io/archive/qt/${QT_MAJOR_VERSION}/${QT_FULL_VERSION}/qt-opensource-linux-x64-${QT_FULL_VERSION}.run && \
      chmod +x qt-opensource-linux-x64-${QT_FULL_VERSION}.run

# Copy Qt installer script into the container
COPY qt-noninteractive.qs /qt-noninteractive.qs

RUN ./qt-opensource-linux-x64-${QT_FULL_VERSION}.run \
      --script qt-noninteractive.qs \
      -platform minimal && \
      rm -f qt-noninteractive.qs && \
      rm -f qt-opensource-linux-x64-${QT_FULL_VERSION}.run

RUN git clone https://github.com/collin80/SavvyCAN && \
      cd SavvyCAN && \
      /qt/$QT_FULL_VERSION/gcc_64/bin/qmake && \
      make

# Automatically start SavvyCAN
ENTRYPOINT ["/SavvyCAN/SavvyCAN"]
