# Jackett and OpenVPN, JackettVPN

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ENV XDG_DATA_HOME="/config" \
XDG_CONFIG_HOME="/config"

WORKDIR /opt

RUN usermod -u 99 nobody

# Make directories
RUN mkdir -p /blackhole /config/Jackett /etc/jackett

RUN 

RUN apt -y purge procps \
    && apt update \
    && apt -y upgrade \
    && apt -y install \
    apt-transport-https
    && apt-get clean \
    && apt -y autoremove \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

RUN apt -y install --no-install-recommends
    wget \
    curl \
    gnupg \
    openvpn \
    moreutils \
    net-tools \
    dos2unix \
    kmod \
    iptables \
    ipcalc\
    libcurl4 \
    liblttng-ust0 \
    libkrb5-3 \
    zlib1g \
    iputils-ping \
    jq \
    libicu66 \
    grepcidr \
    git \
    autopoint \
    autoconf \
    automake \
    libtool-bin \
    gettext \
    libncursesw5-dev \
    dejagnu \
    libnuma-dev \
    libsystemd-dev \
    pkg-config \
    cmake \
    build-essential \
    && git clone "https://gitlab.com/procps-ng/procps.git" \
    && cd /opt/procps && ./autogen.sh && ./configure --disable-dependency-tracking && /usr/bin/make && /usr/bin/make install \
    && apt -y purge \
    autopoint \
    autoconf \
    automake \
    libtool-bin \
    libncursesw5-dev \
    dejagnu \
    libnuma-dev \
    libsystemd-dev \
    pkg-config \
    cmake \
    git \
    build-essential \
    && apt-get clean \
    && apt -y autoremove \
    && rm -rf \
    /opt/procps/ \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

RUN jackett_latest=$(curl --silent "https://api.github.com/repos/Jackett/Jackett/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') \
    && curl -o /opt/Jackett.Binaries.LinuxAMDx64.tar.gz -L https://github.com/Jackett/Jackett/releases/download/$jackett_latest/Jackett.Binaries.LinuxAMDx64.tar.gz \
    && tar -xzf /opt/Jackett.Binaries.LinuxAMDx64.tar.gz \
    && rm /opt/Jackett.Binaries.LinuxAMDx64.tar.gz

VOLUME /blackhole /config

ADD openvpn/ /etc/openvpn/
ADD jackett/ /etc/jackett/

RUN chmod +x /etc/jackett/*.sh /etc/jackett/*.init /etc/openvpn/*.sh /opt/Jackett/jackett

EXPOSE 9117
CMD ["/bin/bash", "/etc/openvpn/start.sh"]
