FROM alpine:latest

COPY scylla-root/etc/scylla /etc/scylla
COPY scylla-root/etc/scylla.d /etc/scylla.d
COPY scylla-root/opt/scylladb /opt/scylladb
RUN mkdir -p /var/lib/scylla/commitlog /var/lib/scylla/coredump /var/lib/scylla/data /var/lib/scylla/hints /var/lib/scylla/view_hints

EXPOSE 9042
EXPOSE 10942
EXPOSE 9160
EXPOSE 10000

ENTRYPOINT ["/opt/scylladb/bin/scylla", "--options-file", "/etc/scylla/scylla.yaml", "--log-to-stdout", "1", "--default-log-level", "info", "--network-stack", "posix", "--developer-mode", "1"]
