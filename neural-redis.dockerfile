#----------------------------------------------------------------------------------------------
# This work is subject to the terms of the BSD License
# https://github.com/antirez/neural-redis/blob/master/COPYING
#----------------------------------------------------------------------------------------------
# Versions
ARG KEY_DB_VERSION=v6.0.18
ARG REDIS_NEURAL_RELEASE=master

ARG BUILD_BIN=/build/bin
#----------------------------------------------------------------------------------------------
# Build Neural Redis module
FROM debian:10.3-slim AS builder

ARG BUILD_BIN
ARG REDIS_NEURAL_RELEASE

ENV REDIS_NEURAL_RELEASE=${REDIS_NEURAL_RELEASE}
ENV BUILD_BIN=${BUILD_BIN}

WORKDIR /build
RUN mkdir -p ${BUILD_BIN}

RUN apt update
RUN apt install -y build-essential git

# Nerual Redis
RUN git clone -b ${REDIS_NEURAL_RELEASE} https://github.com/antirez/neural-redis.git && \
    cd neural-redis && \
    make generic && \
    cp neuralredis.so ${BUILD_BIN}/ && \
    ls -ltr ${BUILD_BIN}

#----------------------------------------------------------------------------------------------
# Build KeyDB Image with Neural Redis module
FROM eqalpha/keydb:x86_64_${KEY_DB_VERSION}

ARG BUILD_BIN

ENV LIBDIR /usr/lib/redis/modules
RUN mkdir -p ${LIBDIR}

COPY --from=builder ${BUILD_BIN}/* ${LIBDIR}/

CMD ["keydb-server", \
    "--loadmodule", "/usr/lib/redis/modules/neuralredis.so", \
    "/etc/keydb/keydb.conf"]
