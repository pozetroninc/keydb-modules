# Versions
ARG KEY_DB_VERSION=v6.2.2

#----------------------------------------------------------------------------------------------
# Straight KeyDB Image
FROM eqalpha/keydb:x86_64_${KEY_DB_VERSION}

CMD ["keydb-server", "/etc/keydb/keydb.conf", "--loglevel", "verbose"]
