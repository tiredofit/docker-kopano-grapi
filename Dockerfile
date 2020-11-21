FROM tiredofit/debian:buster
LABEL maintainer="Dave Conroy (dave at tiredofit dot ca)"

ENV ENABLE_SMTP=FALSE \
    ZABBIX_HOSTNAME=grapi-app

RUN set -x && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
                       apt-utils \ 
                       lynx \
                       python3-pip \
                       && \
    \
### Kopano Core
    mkdir -p /usr/src/core && \
    kcore_version=`lynx -listonly -nonumbers -dump https://download.kopano.io/community/core:/ | grep -o core-.*-Debian_10-amd64.tar.gz | sed "s/%2B/+/g " | sed "s/-Debian_10.*//g"` && \
    echo "Kopano Core Version: ${kcore_version} on $(date)" >> /.kopano-versions && \
    curl -L `lynx -listonly -nonumbers -dump https://download.kopano.io/community/core:/ | grep Debian_10-amd64.tar.gz` | tar xvfz - --strip 1 -C /usr/src/core && \
    cd /usr/src/core && \
    apt-ftparchive packages ./ > /usr/src/core/Packages && \
    echo "deb [trusted=yes] file:/usr/src/core/ /" >> /etc/apt/sources.list.d/kopano-core.list && \
    \
### Kopano Meet
    mkdir -p /usr/src/meet && \
    meet_version=`lynx -listonly -nonumbers -dump https://download.kopano.io/community/meet:/ | grep -o meet-.*-Debian_10-amd64.tar.gz | sed "s/%2B/+/g " | sed "s/-Debian_10.*//g"` && \
    echo "Kopano Meet Version: ${meet_version} on $(date)" >> /.kopano-versions && \
    curl -L `lynx -listonly -nonumbers -dump https://download.kopano.io/community/meet:/ | grep Debian_10-amd64.tar.gz` | tar xvfz - --strip 1 -C /usr/src/meet && \
    cd /usr/src/meet && \
    apt-ftparchive packages ./ > /usr/src/meet/Packages && \
    echo "deb [trusted=yes] file:/usr/src/meet/ /" >> /etc/apt/sources.list.d/kopano-meet.list && \
    \
    apt-get update && \
    apt-get install -y --no-install-recommends \
                       kopano-grapi \
                       && \
    ##### Cleanup
    apt-get purge -y \
                      apt-utils \
                      git \
                      lynx \
                      && \
    \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/src/* && \
    rm -rf /var/log/*

ADD install /
