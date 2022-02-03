#----------------------------------------------------------------------------------------------
# This work is subject to the terms of the Redis Source Available License
# https://redislabs.com/wp-content/uploads/2019/09/redis-source-available-license.pdf
#----------------------------------------------------------------------------------------------
# Versions
ARG KEY_DB_VERSION=v6.2.2
ARG REDIS_BLOOM_VERSION=v2.2.2

ARG BUILD_BIN=/build/bin
#----------------------------------------------------------------------------------------------
# Build RedisBloom module
FROM debian:10.3-slim AS builder

ARG BUILD_BIN
ARG REDIS_BLOOM_VERSION

ENV REDIS_BLOOM_VERSION=${REDIS_BLOOM_VERSION}
ENV BUILD_BIN=${BUILD_BIN}

WORKDIR /build
RUN mkdir -p ${BUILD_BIN}

RUN apt update
RUN apt install -y build-essential git

# Redis Bloom
RUN git clone -b ${REDIS_BLOOM_VERSION} https://github.com/RedisBloom/RedisBloom.git && \
    cd RedisBloom && \
    set -ex && \
    make clean && \
    make all -j 4 && \
    cp redisbloom.so ${BUILD_BIN}/ && \
    ls -ltr ${BUILD_BIN}

#----------------------------------------------------------------------------------------------
# Build KeyDB Image with RedisBloom module
FROM eqalpha/keydb:x86_64_${KEY_DB_VERSION}

ARG BUILD_BIN

ENV LIBDIR /usr/lib/redis/modules
RUN mkdir -p ${LIBDIR}

COPY --from=builder ${BUILD_BIN}/* ${LIBDIR}/

CMD [ "keydb-server",  \
    "/etc/keydb/keydb.conf", \
    "--loadmodule", "/usr/lib/redis/modules/redisbloom.so" ]
