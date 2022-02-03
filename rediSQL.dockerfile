#----------------------------------------------------------------------------------------------
# This work is subject to the terms of the custom RediSQL licence
# https://github.com/RedBeardLab/rediSQL/blob/master/LICENSE.txt
#----------------------------------------------------------------------------------------------
# Versions
ARG KEY_DB_VERSION=v6.2.2
ARG REDISQL_VERSION=v1.1.1

ARG BUILD_BIN=/build/bin
#----------------------------------------------------------------------------------------------
# Build RediSQL module
FROM debian:10.3-slim AS builder

ARG BUILD_BIN
ARG REDISQL_VERSION

ENV REDISQL_VERSION=${REDISQL_VERSION}
ENV BUILD_BIN=${BUILD_BIN}

WORKDIR /build
RUN mkdir -p ${BUILD_BIN}

RUN apt update
RUN apt install -y curl

# RediSQL
RUN mkdir -p redisql && \
    cd redisql && \
    curl -Ls https://github.com/RedBeardLab/rediSQL/releases/download/${REDISQL_VERSION}/RediSQL_${REDISQL_VERSION}_9b110f_x86_64-unknown-linux-gnu_release.so -o redisql.so && \
    chmod a+x redisql.so && \
    cp redisql.so ${BUILD_BIN}/ && \
    ls -ltr ${BUILD_BIN}

#----------------------------------------------------------------------------------------------
# Build KeyDB Image with RediSQL module
FROM eqalpha/keydb:x86_64_${KEY_DB_VERSION}

ARG BUILD_BIN

ENV LIBDIR /usr/lib/redis/modules
RUN mkdir -p ${LIBDIR}

COPY --from=builder ${BUILD_BIN}/* ${LIBDIR}/

RUN apt update
RUN apt install -y ca-certificates

CMD [ "keydb-server", \
    "/etc/keydb/keydb.conf", \
    "--loadmodule", "/usr/lib/redis/modules/redisql.so" ]
