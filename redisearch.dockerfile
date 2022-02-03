#----------------------------------------------------------------------------------------------
# This work is subject to the terms of the Redis Source Available License
# https://redislabs.com/wp-content/uploads/2019/09/redis-source-available-license.pdf
#----------------------------------------------------------------------------------------------
# Versions
ARG KEY_DB_VERSION=v6.2.2
ARG REDISEARCH_VERSION=v1.6.13

ARG BUILD_BIN=/build/bin
#----------------------------------------------------------------------------------------------
# Build RediSearch module
FROM debian:10.3-slim AS builder

ARG BUILD_BIN
ARG REDISEARCH_VERSION

ENV REDISEARCH_VERSION=${REDISEARCH_VERSION}
ENV BUILD_BIN=${BUILD_BIN}

WORKDIR /build
RUN mkdir -p ${BUILD_BIN}

RUN apt update
RUN apt install -y build-essential git python cmake

# RediSearch
RUN git clone -b ${REDISEARCH_VERSION} --recursive https://github.com/RediSearch/RediSearch.git && \
    cd RediSearch && \
    make build && \
    cp src/redisearch.so ${BUILD_BIN}/ && \
    ls -ltr ${BUILD_BIN}

#----------------------------------------------------------------------------------------------
# Build KeyDB Image with RediSearch module
FROM eqalpha/keydb:x86_64_${KEY_DB_VERSION}

ARG BUILD_BIN

ENV LIBDIR /usr/lib/redis/modules
RUN mkdir -p ${LIBDIR}

COPY --from=builder ${BUILD_BIN}/* ${LIBDIR}/

CMD [ "keydb-server",  \
    "/etc/keydb/keydb.conf", \
    "--loadmodule", "/usr/lib/redis/modules/redisearch.so" ]
