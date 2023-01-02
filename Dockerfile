FROM ubuntu:focal

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/jerheij/docker-rainloop"

HEALTHCHECK --interval=35s --timeout=4s CMD curl -k -f https://localhost || exit 1

ARG GPG_FINGERPRINT="3B79 7ECE 694F 3B7B 70F3  11A4 ED7C 49D9 87DA 4591" 
ARG DEBIAN_FRONTEND=noninteractive

ENV UID=991 GID=991 UPLOAD_MAX_SIZE=25M LOG_TO_STDOUT=false MEMORY_LIMIT=128M

RUN apt-get update -y && \
    apt-get install wget unzip gnupg nginx supervisor -y && \
    apt-get install -y \
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
    php-xml \
    curl && \
    apt-get remove -y apache2* && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

#RUN ln -s /usr/bin/php72 /usr/local/bin/php && \

COPY rootfs /
RUN chmod +x /usr/local/bin/*.sh && \
    /usr/local/bin/InstallRainloop.sh
VOLUME /rainloop/data
EXPOSE 80 443
ENTRYPOINT ["/usr/local/bin/run.sh"]
CMD ["supervisord", "-c", "/conf/supervisor.conf"]]
