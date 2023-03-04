FROM docker.io/scylladb/scylla:latest as scylla
FROM docker.io/busybox:uclibc as busybox

FROM gcr.io/distroless/java11-debian11:latest

COPY --from=scylla /opt/scylladb/jmx /opt/scylladb/jmx
COPY --from=busybox /bin/sh /bin/sh
COPY --from=busybox /bin/hostname /bin/hostname
COPY --from=busybox /bin/cat /bin/cat

EXPOSE 7199

ENTRYPOINT ["/bin/sh", "/opt/scylladb/jmx/scylla-jmx", "-l", "/opt/scylladb/jmx"]
