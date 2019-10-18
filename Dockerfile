FROM postgres:11
MAINTAINER Lance Lee <linanjun@163.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
      && apt-get install -y --no-install-recommends \
           wget gnupg lsb-release postgis apt-transport-https debian-archive-keyring  \
           postgresql-11-cron \
      && sh -c "echo 'deb https://packagecloud.io/timescale/timescaledb/debian/ `lsb_release -c -s` main' > /etc/apt/sources.list.d/timescaledb.list" \
      # && curl -s https://packagecloud.io/install/repositories/timescale/timescaledb/script.deb.sh | bash \
      && wget --quiet -O /tmp/timescale.gpg https://packagecloud.io/timescale/timescaledb/gpgkey --no-check-certificate \
      && apt-key add /tmp/timescale.gpg \
      && apt-get update \
      # Now install appropriate package for PG version
      && apt-get install -y timescaledb-postgresql-11 \
      && sed -r -i "s/[#]*\s*(shared_preload_libraries)\s*=\s*'(.*)'/\1 = 'timescaledb,\2'/;s/,'/'/" /usr/local/share/postgresql/postgresql.conf.sample \
      && rm -rf /var/lib/apt/lists/*
      

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./docker-entrypoint-initdb.d/* /docker-entrypoint-initdb.d/
