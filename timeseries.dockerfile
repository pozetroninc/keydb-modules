#----------------------------------------------------------------------------------------------
# This work is subject to the terms of the Redis Source Available License
# https://redislabs.com/wp-content/uploads/2019/09/redis-source-available-license.pdf
#----------------------------------------------------------------------------------------------
# Versions
ARG KEY_DB_VERSION=v6.3.1
ARG REDIS_TIME_SERIES_VERSION=v1.6.8

#----------------------------------------------------------------------------------------------
# Build Redis Time Series module
FROM debian:11-slim AS builder

ARG REDIS_TIME_SERIES_VERSION
ENV REDIS_TIME_SERIES_VERSION=${REDIS_TIME_SERIES_VERSION}

WORKDIR /build

RUN apt update && apt install -y git
RUN git clone -b ${REDIS_TIME_SERIES_VERSION} --recursive https://github.com/RedisTimeSeries/RedisTimeSeries.git . && \
    git submodule update --recursive --init && \
    ./deps/readies/bin/getpy3 && \
    ./system-setup.py && \
    make build && \
    ls -ltr bin/

#----------------------------------------------------------------------------------------------
# Build KeyDB Image with Time Series Module
FROM eqalpha/keydb:x86_64_${KEY_DB_VERSION}

ENV LIBDIR /usr/lib/redis/modules
RUN mkdir -p ${LIBDIR}

COPY --from=builder /build/bin/redistimeseries.so ${LIBDIR}

CMD ["keydb-server", "--loadmodule", "/usr/lib/redis/modules/redistimeseries.so", "/etc/keydb/keydb.conf", "--loglevel", "verbose"]
