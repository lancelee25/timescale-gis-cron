ARG PG_VERSION_TAG="pg11"
ARG TS_VERSION_TAG="1.4.2"
FROM timescale/timescaledb:${TS_VERSION_TAG}-${PG_VERSION_TAG}

MAINTAINER Timescale https://www.timescale.com
ARG POSTGIS_VERSION
ENV POSTGIS_VERSION ${POSTGIS_VERSION:-2.5.3}

RUN set -ex \
    && apk add --no-cache --virtual .fetch-deps \
                ca-certificates \
                openssl \
                tar \
    # add libcrypto from (edge:main) for gdal-2.3.0
    && apk add --no-cache --virtual .crypto-rundeps \
                --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
                libressl2.7-libcrypto \
                libcrypto1.1 \
                musl \
                musl-dev \
    && apk add --no-cache --virtual .postgis-deps --repository http://nl.alpinelinux.org/alpine/edge/testing \
        geos \
        gdal \
        protobuf-c \
    && apk add --no-cache --virtual .build-deps --repository http://nl.alpinelinux.org/alpine/edge/testing \
        postgresql-dev \
        perl \
        file \
        geos-dev \
        libxml2-dev \
        gdal-dev \
        protobuf-c-dev \
        json-c-dev \
        gcc g++ clang \
        make \
    && cd /tmp \
    && wget http://download.osgeo.org/proj/proj-4.9.3.tar.gz -O - | tar -xz \
    && cd /tmp/proj-4.9.3 \
    && ./configure \
    && make \
    && make install \
    && cd /tmp \
    && wget http://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz -O - | tar -xz \
    && chown root:root -R postgis-${POSTGIS_VERSION} \
    && cd /tmp/postgis-${POSTGIS_VERSION} \
    && ./configure \
    && echo "PERL = /usr/bin/perl" >> extensions/postgis/Makefile \
    && echo "PERL = /usr/bin/perl" >> extensions/postgis_topology/Makefile \
    && make -s \
    && make -s install \
    && apk add --no-cache --virtual .postgis-rundeps \
        json-c \
    && cd / \
    \
    && rm -rf /tmp/postgis-${POSTGIS_VERSION} \
    && rm -rf /tmp/proj-4.9.3 \
    && cd /tmp && wget https://codeload.github.com/citusdata/pg_cron/tar.gz/v1.2.0 -O - |tar -xz \
    && cd pg_cron-1.2.0 \
    && export PATH=/usr/local/bin:$PATH \
    && make && make install \
    && cd / && rm -rf /tmp/pg_cron-1.2.0 \
    && apk del .fetch-deps .build-deps
    
