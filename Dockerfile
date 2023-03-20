FROM scylladb/scylla-nightly:latest as scylla

RUN for i in /opt/scylladb/python3/bin/*;do \
        if [ -f $i ]; then \
            sed -i -e '1 s#\#!/bin/bash#\#!/busybox/sh#' $i; \
        fi; \
    done

RUN for i in /opt/scylladb/share/cassandra/bin/*;do \
        if [ -f $i ]; then \
            sed -i -e '1 s#\#!/bin/sh#\#!/busybox/sh#' $i; \
            sed -i -e '1 s#\#!/usr/bin/env bash#\#!/busybox/sh#' $i; \
        fi; \
    done
RUN for i in /opt/scylladb/share/cassandra/libexec/*;do \
        if [ -f $i ]; then \
            sed -i -e '1 s#\#!/bin/sh#\#!/busybox/sh#' $i; \
            sed -i -e '1 s#\#!/usr/bin/python3#\#!/busybox/env python3#' $i; \
        fi; \
    done

RUN sed -i -e '1 s#\#!/bin/bash#\#!/busybox/sh#' /opt/scylladb/jmx/scylla-jmx

FROM gcr.io/distroless/java11-debian11:debug

COPY --from=scylla /etc/scylla /etc/scylla
COPY --from=scylla /opt/scylladb/jmx /opt/scylladb/jmx
COPY --from=scylla /opt/scylladb/share/cassandra /opt/scylladb/share/cassandra
COPY --from=scylla /opt/scylladb/python3/ /opt/scylladb/python3/
RUN ["sh", "-c", "for i in /opt/scylladb/share/cassandra/bin/*;do ln -sf $i /usr/bin;done"]
# XXX: workaround for resolve symlink issue on Dockerfile
RUN ["rm", "/opt/scylladb/python3/bin/python3"]
RUN ["ln", "-sf", "/opt/scylladb/python3/bin/python3.11", "/opt/scylladb/python3/bin/python3"]

EXPOSE 7199

ENTRYPOINT ["/opt/scylladb/jmx/scylla-jmx", "-l", "/opt/scylladb/jmx"]
