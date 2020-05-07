#----------------------------------------------------------------------------------------------
# This work is subject to the terms of the Redis Source Available License
# https://redislabs.com/wp-content/uploads/2019/09/redis-source-available-license.pdf
#----------------------------------------------------------------------------------------------
# Versions
ARG KEY_DB_VERSION=v5.3.3
ARG REDIS_CELL_VERSION=v0.2.5

ARG BUILD_BIN=/build/bin
#----------------------------------------------------------------------------------------------
# Build Redis Time Series module
FROM debian:10.3-slim AS builder

ARG BUILD_BIN
ARG REDIS_CELL_VERSION

ENV REDIS_CELL_VERSION=${REDIS_CELL_VERSION}
ENV BUILD_BIN=${BUILD_BIN}

WORKDIR /build
RUN mkdir -p ${BUILD_BIN}

RUN apt update
RUN apt install -y build-essential git curl tar

# Redis cell
RUN mkdir -p redis-cell && \
    cd redis-cell && \
    curl -Ls https://github.com/brandur/redis-cell/releases/download/${REDIS_CELL_VERSION}/redis-cell-${REDIS_CELL_VERSION}-x86_64-unknown-linux-gnu.tar.gz -o redis-cell.tar.gz && \
    tar -xzvf redis-cell.tar.gz && \
    cp libredis_cell.so ${BUILD_BIN}/ && \
    ls -ltr ${BUILD_BIN}

#----------------------------------------------------------------------------------------------
# Build KeyDB Image with Redis Cell module
FROM eqalpha/keydb:x86_64_${KEY_DB_VERSION}

ARG BUILD_BIN

ENV LIBDIR /usr/lib/redis/modules
RUN mkdir -p ${LIBDIR}

COPY --from=builder ${BUILD_BIN}/* ${LIBDIR}/

CMD ["keydb-server", \
    "--loadmodule", "/usr/lib/redis/modules/libredis_cell.so", \
    "/etc/keydb/keydb.conf"]

