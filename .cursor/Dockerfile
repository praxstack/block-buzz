FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      gnupg \
      lsb-release \
      fuse-overlayfs \
      iptables \
      docker.io \
      docker-compose-v2 \
      build-essential \
      g++ \
      file \
      libasound2-dev \
      libayatana-appindicator3-dev \
      libgtk-3-dev \
      librsvg2-dev \
      libssl-dev \
      libwebkit2gtk-4.1-dev \
      libxdo-dev \
      patchelf \
      wget \
      pkg-config \
      lsof \
      python3 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /etc/docker \
    && printf '%s\n' '{"storage-driver":"vfs"}' > /etc/docker/daemon.json
