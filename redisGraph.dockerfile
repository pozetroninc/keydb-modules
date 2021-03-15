#----------------------------------------------------------------------------------------------
# This work is subject to the terms of the Redis Source Available License
# https://redislabs.com/wp-content/uploads/2019/09/redis-source-available-license.pdf
#----------------------------------------------------------------------------------------------
# Versions
ARG KEY_DB_VERSION=v6.0.16
ARG REDIS_GRAPH_VERSION=v2.0.11

ARG BUILD_BIN=/build/bin
#----------------------------------------------------------------------------------------------
# Build RedisGraph module
FROM debian:10.3-slim AS builder

ARG BUILD_BIN
ARG REDIS_GRAPH_VERSION

ENV REDIS_GRAPH_VERSION=${REDIS_GRAPH_VERSION}
ENV BUILD_BIN=${BUILD_BIN}

WORKDIR /build
RUN mkdir -p ${BUILD_BIN}

RUN apt update
RUN apt install -y build-essential git cmake m4 automake peg libtool autoconf

# Redis Graph
RUN git clone -b ${REDIS_GRAPH_VERSION} --recurse-submodules -j8 https://github.com/RedisGraph/RedisGraph.git && \
    cd RedisGraph && \
    make && \
    cp src/redisgraph.so ${BUILD_BIN}/ && \
    ls -ltr ${BUILD_BIN}

#----------------------------------------------------------------------------------------------
# Build KeyDB Image with RedisGraph module
FROM eqalpha/keydb:x86_64_${KEY_DB_VERSION}

ARG BUILD_BIN

ENV LIBDIR /usr/lib/redis/modules
RUN mkdir -p ${LIBDIR}

RUN apt-get update && \
    apt-get install -y --no-install-recommends libgomp1

COPY --from=builder ${BUILD_BIN}/* ${LIBDIR}/

CMD [ "keydb-server",  \
    "/etc/keydb/keydb.conf", \
    "--loadmodule", "/usr/lib/redis/modules/redisgraph.so" ]
