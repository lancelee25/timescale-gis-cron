FROM postgres:11
MAINTAINER Lance Lee <linanjun@163.com>

ENV POSTGIS_MAJOR 2.5
ENV POSTGIS_VERSION 2.5.3+dfsg-1~exp1.pgdg90+1

RUN apt-get update \
      && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
      && apt-get install -y --no-install-recommends \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts=$POSTGIS_VERSION \
           postgis=$POSTGIS_VERSION \
      && sh -c "echo 'deb https://packagecloud.io/timescale/timescaledb/debian/ `lsb_release -c -s` main' > /etc/apt/sources.list.d/timescaledb.list" \
      && wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add - \
      && sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
      && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - \
      && apt-get update \

      # Now install appropriate package for PG version
      && apt-get -y install timescaledb-postgresql-11 \
      && apt-get -y install postgresql-11-cron \
      && sed -r -i "s/[#]*\s*(shared_preload_libraries)\s*=\s*'(.*)'/\1 = 'timescaledb,\2'/;s/,'/'/" /usr/local/share/postgresql/postgresql.conf.sample
      && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-ts-gis-cron.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./update-ts-gis-cron.sh /usr/local/bin
