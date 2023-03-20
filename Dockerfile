FROM docker.io/scylladb/scylla:latest as scylla

RUN sed -i -e 's/^SCYLLA_ARGS=".*"$/SCYLLA_ARGS="--log-to-syslog 0 --log-to-stdout 1 --default-log-level info --network-stack posix"/' /etc/default/scylla-server

RUN for i in /opt/scylladb/bin/*;do \
        if [ -f $i ]; then \
            sed -i -e '1 s#\#!/bin/bash#\#!/busybox/sh#' $i; \
        fi; \
    done
RUN for i in /opt/scylladb/bin/*;do \
        if [ -f $i ]; then \
            sed -i -e 's#${GNUTLS_SYSTEM_PRIORITY_FILE-/opt/scylladb/libreloc/gnutls.config}#/opt/scylladb/libreloc/gnutls.config#' $i; \
        fi; \
    done
RUN for i in /opt/scylladb/python3/bin/*;do \
        if [ -f $i ]; then \
            sed -i -e '1 s#\#!/bin/bash#\#!/busybox/sh#' $i; \
        fi; \
    done
RUN for i in /opt/scylladb/scripts/*;do \
        if [ -f $i ]; then \
            sed -i -e '1 s#\#!/usr/bin/env bash#\#!/busybox/sh#' $i; \
        fi; \
    done
RUN for i in /opt/scylladb/scripts/libexec/*;do \
        if [ -f $i ]; then \
            sed -i -e '1 s#\#!/usr/bin/env python3#\#!/busybox/env python3#' $i; \
        fi; \
    done

FROM gcr.io/distroless/static:debug

COPY --from=scylla /etc/default/scylla-server /etc/default/
COPY --from=scylla /etc/scylla/ /etc/scylla/
COPY --from=scylla /etc/scylla.d/ /etc/scylla.d/
COPY --from=scylla /var/lib/scylla/ /var/lib/scylla/
RUN ["ln", "-sf", "/etc/scylla", "/var/lib/scylla/conf"]
COPY --from=scylla /opt/scylladb/api/ /opt/scylladb/api/
COPY --from=scylla /opt/scylladb/bin/scylla /opt/scylladb/bin/scylla
COPY --from=scylla /opt/scylladb/bin/iotune /opt/scylladb/bin/iotune
COPY --from=scylla /opt/scylladb/libexec/scylla /opt/scylladb/libexec/scylla
COPY --from=scylla /opt/scylladb/libexec/iotune /opt/scylladb/libexec/iotune
COPY --from=scylla /opt/scylladb/libexec/ubsan-suppressions.supp /opt/scylladb/libexec/ubsan-suppressions.supp
COPY --from=scylla /opt/scylladb/libreloc/ /opt/scylladb/libreloc/
COPY --from=scylla /opt/scylladb/scripts/ /opt/scylladb/scripts/
COPY --from=scylla /opt/scylladb/python3/ /opt/scylladb/python3/
# XXX: workaround for resolve symlink issue on Dockerfile
RUN ["rm", "/opt/scylladb/python3/bin/python3"]
RUN ["ln", "-sf", "/opt/scylladb/python3/bin/python3.9", "/opt/scylladb/python3/bin/python3"]
RUN ["ln", "-sf", "/opt/scylladb/bin/iotune", "/usr/bin/iotune"]
RUN ["ln", "-sf", "/opt/scylladb/bin/scylla", "/usr/bin/scylla"]
COPY scyllasetup.py commandlineparser.py docker-entrypoint.py /opt/scylladb/docker/
COPY libexec/ /opt/scylladb/docker/libexec/

EXPOSE 9042
EXPOSE 10942
EXPOSE 9160
EXPOSE 10000

ENTRYPOINT ["/opt/scylladb/docker/docker-entrypoint.py"]
