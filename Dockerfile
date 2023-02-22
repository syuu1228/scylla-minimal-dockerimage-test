FROM gcr.io/distroless/base:latest

COPY scylla-root/etc/scylla /etc/scylla
COPY scylla-root/opt/scylladb /opt/scylladb
COPY scylla-root/var/lib/scylla /var/lib/scylla

EXPOSE 9042
EXPOSE 10942
EXPOSE 9160
EXPOSE 10000
ENV GNUTLS_SYSTEM_PRIORITY_FILE="/opt/scylladb/libreloc/gnutls.config"
ENV LD_LIBRARY_PATH="/opt/scylladb/libreloc"
ENV UBSAN_OPTIONS="suppressions=/opt/scylladb/libexec/ubsan-suppressions.supp"

ENTRYPOINT ["/opt/scylladb/libexec/scylla", "--options-file", "/etc/scylla/scylla.yaml", "--log-to-stdout", "1", "--default-log-level", "info", "--network-stack", "posix", "--developer-mode", "1"]
