#----------------------------------------------------------------------------------------------
# This work is subject to the terms of the AGPL-3.0 License
# https://github.com/antirez/disque-module/blob/master/LICENSE
#----------------------------------------------------------------------------------------------
# Versions
ARG KEY_DB_VERSION=v6.2.2
ARG DISQUE_RELEASE=master

ARG BUILD_BIN=/build/bin
#----------------------------------------------------------------------------------------------
# Build Disque module
FROM debian:10.3-slim AS builder

ARG BUILD_BIN
ARG DISQUE_RELEASE

ENV DISQUE_RELEASE=${DISQUE_RELEASE}
ENV BUILD_BIN=${BUILD_BIN}

WORKDIR /build
RUN mkdir -p ${BUILD_BIN}

RUN apt update
RUN apt install -y build-essential git

# Disque
RUN git clone -b ${DISQUE_RELEASE} https://github.com/antirez/disque-module.git && \
    cd disque-module && \
    set -ex && \
    make all && \
    cp disque.so ${BUILD_BIN}/ && \
    ls -ltr ${BUILD_BIN}

#----------------------------------------------------------------------------------------------
# Build KeyDB Image with Disque module
FROM eqalpha/keydb:x86_64_${KEY_DB_VERSION}

ARG BUILD_BIN

ENV LIBDIR /usr/lib/redis/modules
RUN mkdir -p ${LIBDIR}

COPY --from=builder ${BUILD_BIN}/* ${LIBDIR}/

CMD [ "keydb-server",  \
    "/etc/keydb/keydb.conf", \
    "--loadmodule", "/usr/lib/redis/modules/disque.so" ]
