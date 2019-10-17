FROM postgres:11
MAINTAINER Lance Lee <linanjun@163.com>

RUN apt-get update \
      && apt-get install -y --no-install-recommends \
           postgis \
           postgresql-11-cron \
      && sh -c "echo 'deb https://packagecloud.io/timescale/timescaledb/debian/ `lsb_release -c -s` main' > /etc/apt/sources.list.d/timescaledb.list" \
      && wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add - \
      && apt-get update \

      # Now install appropriate package for PG version
      && apt-get -y install timescaledb-postgresql-11 \
      && sed -r -i "s/[#]*\s*(shared_preload_libraries)\s*=\s*'(.*)'/\1 = 'timescaledb,\2'/;s/,'/'/" /usr/local/share/postgresql/postgresql.conf.sample \
      && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-ts-gis-cron.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./update-ts-gis-cron.sh /usr/local/bin
