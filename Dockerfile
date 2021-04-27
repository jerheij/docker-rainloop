FROM ubuntu:focal

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/jerheij/docker-rainloop"

HEALTHCHECK --interval=35s --timeout=4s CMD curl -k -f https://localhost || exit 1

ARG GPG_FINGERPRINT="3B79 7ECE 694F 3B7B 70F3  11A4 ED7C 49D9 87DA 4591" 
ARG DEBIAN_FRONTEND=noninteractive

ENV UID=991 GID=991 UPLOAD_MAX_SIZE=25M LOG_TO_STDOUT=false MEMORY_LIMIT=128M

RUN apt-get update -y 

RUN apt-get install wget unzip gnupg nginx supervisor -y

RUN apt-get install -y \
    php-cli \
    php-fpm \
    php-common \
    php \
    php-pear \
    php-memcache \
    php-imap \
    php-mysql \
    php-mbstring \
    php-pear \
    php-pdo \
    php-curl \
    php-xml

RUN apt remove -y apache2*

RUN apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

#RUN ln -s /usr/bin/php72 /usr/local/bin/php && \
RUN cd /tmp && \
    wget -q https://www.rainloop.net/repository/webmail/rainloop-community-latest.zip && \
    wget -q https://www.rainloop.net/repository/webmail/rainloop-community-latest.zip.asc && \
    wget -q https://www.rainloop.net/repository/RainLoop.asc && \
    gpg --import RainLoop.asc && \
    FINGERPRINT="$(LANG=C gpg --verify rainloop-community-latest.zip.asc rainloop-community-latest.zip 2>&1 \
     | sed -n "s#Primary key fingerprint: \(.*\)#\1#p")" && \
    if [ -z "${FINGERPRINT}" ]; then echo "ERROR: Invalid GPG signature!" && exit 1; fi && \
    if [ "${FINGERPRINT}" != "${GPG_FINGERPRINT}" ]; then echo "ERROR: Wrong GPG fingerprint!" && exit 1; else echo "SUCCESS: GPG fingerprint correct!"; fi && \
    mkdir /rainloop && unzip -q /tmp/rainloop-community-latest.zip -d /rainloop && \
    find /rainloop -type d -exec chmod 755 {} \; && \
    find /rainloop -type f -exec chmod 644 {} \; && \
    rm -rf /tmp/* /root/.gnupg

COPY rootfs /
RUN chmod +x /usr/local/bin/run.sh
VOLUME /rainloop/data
EXPOSE 80 443
ENTRYPOINT ["/usr/local/bin/run.sh"]
CMD ["supervisord", "-c", "/conf/supervisor.conf"]]
