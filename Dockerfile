FROM scylladb/scylla:latest as scylla

RUN for i in /opt/scylladb/share/cassandra/bin/*;do sed -i -e '1 s#\#!/bin/sh#\#!/busybox/sh#' $i;done
RUN sed -i -e '1 s#\#!/bin/bash#\#!/busybox/sh#' /opt/scylladb/jmx/scylla-jmx

FROM debian:11-slim as debian11
RUN cd /tmp && apt-get update && apt-get download \
    bzip2 file libexpat1 libgdbm-compat4 libgdbm6 libgpm2 libmagic-mgc libmagic1 \
    libncursesw6 libperl5.32 libpython2.7-minimal libpython2.7-stdlib \
    libreadline8 libsqlite3-0 mailcap media-types mime-support netbase perl \
    perl-modules-5.32 python2.7 python2.7-minimal readline-common xz-utils && \
    mkdir /dpkg && \
    for deb in *.deb; do dpkg --extract $deb /dpkg || exit 10; done
RUN apt-get install -y python2.7-minimal curl
RUN curl -O https://bootstrap.pypa.io/pip/2.7/get-pip.py
RUN python2.7 get-pip.py
RUN pip2.7 install pyyaml

FROM gcr.io/distroless/java11-debian11:debug

COPY --from=scylla /etc/scylla /etc/scylla
COPY --from=scylla /opt/scylladb/jmx /opt/scylladb/jmx
COPY --from=scylla /opt/scylladb/share/cassandra /opt/scylladb/share/cassandra
RUN ["/busybox/sh", "-c", "for i in /opt/scylladb/share/cassandra/bin/*;do ln -sf $i /usr/bin;done"]

COPY --from=debian11 /dpkg /
COPY --from=debian11 /usr/local/lib/python2.7/dist-packages/yaml /usr/local/lib/python2.7/dist-packages/yaml
EXPOSE 7199

ENTRYPOINT ["/opt/scylladb/jmx/scylla-jmx", "-l", "/opt/scylladb/jmx"]
