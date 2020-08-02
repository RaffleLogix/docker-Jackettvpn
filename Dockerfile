# Jackett and OpenVPN, JackettVPN

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ENV XDG_DATA_HOME="/config" \
XDG_CONFIG_HOME="/config"

WORKDIR /opt

RUN usermod -u 99 nobody

# Make directories
RUN mkdir -p /blackhole /config/Jackett /etc/jackett

# Remove procps
RUN apt -y purge procps

# Update, upgrade and install required packages
RUN apt update \
    && apt -y upgrade \
    && apt -y install \
    apt-transport-https \
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
    grepcidr \
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
    git

# Compile procps
RUN git clone "https://gitlab.com/procps-ng/procps.git" \
    && cd /opt/procps \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install

# Clean procps dependencies
RUN apt -y purge \
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
    git \
    && apt-get clean \
    && apt -y autoremove \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

# Install Jackett
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
