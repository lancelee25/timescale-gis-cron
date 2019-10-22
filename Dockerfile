FROM postgres:11-alpine AS oldversions
RUN set -ex \
&& apk add --no-cache --virtual .postgis-deps --repository http://nl.alpinelinux.org/alpine/edge/testing \
pg_cron

FROM timescale/timescaledb-postgis:latest-pg11
MAINTAINER Timescale https://www.timescale.com
COPY --from=oldversions /usr/lib/postgresql/pg_cron.so /usr/local/lib/postgresql/
COPY --from=oldversions /usr/share/postgresql/extension/pg_cron* /usr/local/share/postgresql/extension/
RUN sed -r -i "s/[#]*\s*(shared_preload_libraries)\s*=\s*'(.*)'/\1 = 'timescaledb,pg_cron'/;s/,'/'/" /usr/local/share/postgresql/postgresql.conf.sample
