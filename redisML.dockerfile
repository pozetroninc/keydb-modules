#----------------------------------------------------------------------------------------------
# This work is subject to the terms of the Redis Source Available License
# https://redislabs.com/wp-content/uploads/2019/09/redis-source-available-license.pdf
#----------------------------------------------------------------------------------------------
# Versions
ARG KEY_DB_VERSION=v6.2.2
ARG REDIS_ML_VERSION=v0.99.2

ARG BUILD_BIN=/build/bin
#----------------------------------------------------------------------------------------------
# Build RedisML module
FROM debian:10.3-slim AS builder

ARG BUILD_BIN
ARG REDIS_ML_VERSION

ENV REDIS_ML_VERSION=${REDIS_ML_VERSION}
ENV BUILD_BIN=${BUILD_BIN}

WORKDIR /build
RUN mkdir -p ${BUILD_BIN}

RUN apt update
RUN apt install -y build-essential git cmake libatlas-base-dev

# RedisML
RUN git clone -b ${REDIS_ML_VERSION} https://github.com/RedisLabsModules/redisml.git && \
    cd redisml && \
    make && \
    cp src/redis-ml.so ${BUILD_BIN}/ && \
    ls -ltr ${BUILD_BIN}

#----------------------------------------------------------------------------------------------
# Build KeyDB Image with RedisML module
FROM eqalpha/keydb:x86_64_${KEY_DB_VERSION}

ARG BUILD_BIN

ENV LIBDIR /usr/lib/redis/modules
RUN mkdir -p ${LIBDIR}

COPY --from=builder ${BUILD_BIN}/* ${LIBDIR}/

CMD [ "keydb-server",  \
    "/etc/keydb/keydb.conf", \
    "--loadmodule", "/usr/lib/redis/modules/redis-ml.so" ]
