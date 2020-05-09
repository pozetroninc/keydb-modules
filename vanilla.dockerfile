# Versions
ARG KEY_DB_VERSION=v5.3.3

#----------------------------------------------------------------------------------------------
# Straight KeyDB Image
FROM eqalpha/keydb:x86_64_${KEY_DB_VERSION}

CMD ["keydb-server", "/etc/keydb/keydb.conf", "--loglevel", "verbose"]
