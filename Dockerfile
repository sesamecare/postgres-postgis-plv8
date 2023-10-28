FROM sibedge/postgres-plv8:14.9-3.0.0-bullseye
LABEL org.opencontainers.image.source="https://github.com/sesamecare/postgres-postgis-plv8"

ENV PG_MAJOR 14
ENV GOSU_VERSION 1.16

USER root

RUN apt-get update \
  && apt-cache showpkg postgis \
  && apt-get install -y --no-install-recommends \
       # ca-certificates: for accessing remote raster files;
       #   fix: https://github.com/postgis/docker-postgis/issues/307
       ca-certificates postgis wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true
