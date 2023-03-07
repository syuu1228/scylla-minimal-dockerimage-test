FROM docker.io/scylladb/scylla:latest as scylla

FROM gcr.io/distroless/java11-debian11:debug

COPY --from=scylla /opt/scylladb/jmx /opt/scylladb/jmx

EXPOSE 7199

ENTRYPOINT ["/busybox/sh", "/opt/scylladb/jmx/scylla-jmx", "-l", "/opt/scylladb/jmx"]
