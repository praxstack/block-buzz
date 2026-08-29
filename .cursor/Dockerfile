FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      gnupg \
      lsb-release \
      sudo \
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
    && update-alternatives --set iptables /usr/sbin/iptables-legacy \
    && update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy \
    && mkdir -p /etc/docker \
    && printf '%s\n' '{"storage-driver":"fuse-overlayfs","iptables":false,"bridge":"none"}' > /etc/docker/daemon.json \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/ubuntu-cloud-agent \
    && chmod 0440 /etc/sudoers.d/ubuntu-cloud-agent

RUN usermod -aG docker ubuntu || true

USER ubuntu
WORKDIR /workspace

# bun — required by gstack skill install (scripts/install-gstack-skills.sh)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/home/ubuntu/.bun/bin:${PATH}"
