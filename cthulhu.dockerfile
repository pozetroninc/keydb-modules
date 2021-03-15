#----------------------------------------------------------------------------------------------
# This work is subject to the terms of the BSD License
# https://github.com/sklivvz/cthulhu/blob/master/LICENSE
#----------------------------------------------------------------------------------------------
# Versions
ARG KEY_DB_VERSION=v6.0.16
ARG CTHULHU_RELEASE=master

ARG BUILD_BIN=/build/bin
#----------------------------------------------------------------------------------------------
# Build cthulhu module
FROM debian:10.3-slim AS builder

ARG BUILD_BIN
ARG CTHULHU_RELEASE

ENV CTHULHU_RELEASE=${CTHULHU_RELEASE}
ENV BUILD_BIN=${BUILD_BIN}

WORKDIR /build
RUN mkdir -p ${BUILD_BIN}

RUN apt update
RUN apt install -y build-essential git cmake

# cthulhu
RUN git clone -b ${CTHULHU_RELEASE} https://github.com/sklivvz/cthulhu.git && \
    cd cthulhu/src && \
    ./make.sh && \
    cp cthulhu.so ${BUILD_BIN}/ && \
    cp cthulhu.js ${BUILD_BIN}/ && \
    ls -ltr ${BUILD_BIN}

#----------------------------------------------------------------------------------------------
# Build KeyDB Image with cthulhu module
FROM eqalpha/keydb:x86_64_${KEY_DB_VERSION}

ARG BUILD_BIN

ENV LIBDIR /usr/lib/redis/modules
RUN mkdir -p ${LIBDIR}

COPY --from=builder ${BUILD_BIN}/* ${LIBDIR}/

CMD [ "keydb-server",  \
    "/etc/keydb/keydb.conf", \
    "--loadmodule", "/usr/lib/redis/modules/cthulhu.so", "/usr/lib/redis/modules/cthulhu.js" ]
