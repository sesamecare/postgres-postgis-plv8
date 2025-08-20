FROM pgvector/pgvector:pg16 AS builder

FROM sibedge/postgres-plv8:16.9-3.2.3-bookworm
LABEL org.opencontainers.image.source="https://github.com/sesamecare/postgres-postgis-plv8"

ENV PG_MAJOR 16
ENV GOSU_VERSION 1.16

USER root

COPY --from=builder /usr/lib/postgresql/16/lib/vector.so /usr/lib/postgresql/16/lib/
COPY --from=builder /usr/share/postgresql/16/extension/vector* /usr/share/postgresql/16/extension/

RUN apt-get update \
  && apt-cache showpkg postgis \
  && apt-get install -y --no-install-recommends \
       # ca-certificates: for accessing remote raster files;
       #   fix: https://github.com/postgis/docker-postgis/issues/307
       ca-certificates postgis postgresql-16-postgis-3 wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true

USER postgres
