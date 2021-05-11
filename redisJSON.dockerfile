#----------------------------------------------------------------------------------------------
# This work is subject to the terms of the custom RediSQL licence
# https://github.com/RedBeardLab/rediSQL/blob/master/LICENSE.txt
#----------------------------------------------------------------------------------------------
# Versions
ARG KEY_DB_VERSION=v6.0.18
ARG REDISJSON_VERSION=v1.0.4

ARG BUILD_BIN=/build/bin
#----------------------------------------------------------------------------------------------
# Download RedisJSON module
FROM debian:10.3-slim AS builder

ARG BUILD_BIN
ARG REDISJSON_VERSION

ENV REDISJSON_VERSION=${REDISJSON_VERSION}
ENV BUILD_BIN=${BUILD_BIN}

WORKDIR /build
RUN mkdir -p ${BUILD_BIN}

RUN apt update
RUN apt install -y curl

# RedisJSON
RUN mkdir -p redisjson && \
    cd redisjson && \
    curl -L https://github.com/RedisJSON/RedisJSON/releases/download/${REDISJSON_VERSION}/rejson.so -o rejson.so && \
    chmod a+x rejson.so && \
    cp rejson.so ${BUILD_BIN}/ && \
    ls -ltr ${BUILD_BIN}

#----------------------------------------------------------------------------------------------
# Build KeyDB Image with RedisJSON module
FROM eqalpha/keydb:x86_64_${KEY_DB_VERSION}

ARG BUILD_BIN

ENV LIBDIR /usr/lib/redis/modules
RUN mkdir -p ${LIBDIR}

COPY --from=builder ${BUILD_BIN}/* ${LIBDIR}/

CMD [ "keydb-server", \
    "/etc/keydb/keydb.conf", \
    "--loadmodule", "/usr/lib/redis/modules/rejson.so" ]
