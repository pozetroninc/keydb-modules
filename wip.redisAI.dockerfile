#----------------------------------------------------------------------------------------------
# This work is subject to the terms of the Redis Source Available License
# https://redislabs.com/wp-content/uploads/2019/09/redis-source-available-license.pdf
#----------------------------------------------------------------------------------------------
# Versions
ARG KEY_DB_VERSION=v5.3.3
ARG REDIS_AI_VERSION=v0.99.0

ARG BUILD_BIN=/build/bin
#----------------------------------------------------------------------------------------------
# Build RedisAI module
FROM debian:10.3-slim AS builder

ARG BUILD_BIN
ARG REDIS_AI_VERSION

ENV REDIS_AI_VERSION=${REDIS_AI_VERSION}
ENV BUILD_BIN=${BUILD_BIN}

WORKDIR /build
RUN mkdir -p ${BUILD_BIN}

RUN apt update
RUN apt install -y build-essential git cmake

# Clone RedisAI
RUN git clone -b ${REDIS_AI_VERSION} https://github.com/RedisAI/RedisAI.git
WORKDIR /build/RedisAI

# Install dependencies
RUN ./opt/readies/bin/getpy3 && \
    ./opt/system-setup.py && \
    ./get_deps.sh

# Build RedisAI
RUN make -C opt build $BUILD_ARGS SHOW=1 && \
    cp bin/linux-x64-release/install-cpu/redisai.so ${BUILD_BIN} && \
    chmod a+x ${BUILD_BIN}/redisai.so && \
    ls -ltr ${BUILD_BIN}

RUN find . -name "redisai.so"
#----------------------------------------------------------------------------------------------
# Build KeyDB Image with RedisAI module
FROM eqalpha/keydb:x86_64_${KEY_DB_VERSION}

ARG BUILD_BIN

ENV LIBDIR /usr/lib/redis/modules
RUN mkdir -p ${LIBDIR} && \
    apt-get -qq update && \
    apt-get -q install -y libgomp1

COPY --from=builder ${BUILD_BIN}/* ${LIBDIR}/

CMD [ "keydb-server",  \
    "/etc/keydb/keydb.conf", \
    "--loadmodule", "/usr/lib/redis/modules/redisai.so" ]