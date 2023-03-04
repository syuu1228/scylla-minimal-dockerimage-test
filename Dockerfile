FROM docker.io/scylladb/scylla:latest as scylla

FROM gcr.io/distroless/static:latest

COPY --from=scylla /etc/scylla /etc/scylla
COPY --from=scylla /var/lib/scylla /var/lib/scylla
COPY --from=scylla /opt/scylladb/api /opt/scylladb/api
COPY --from=scylla /opt/scylladb/libexec /opt/scylladb/libexec
COPY --from=scylla /opt/scylladb/libreloc /opt/scylladb/libreloc
COPY --from=scylla /opt/scylladb/swagger-ui /opt/scylladb/swagger-ui

EXPOSE 9042
EXPOSE 10942
EXPOSE 9160
EXPOSE 10000
ENV GNUTLS_SYSTEM_PRIORITY_FILE="/opt/scylladb/libreloc/gnutls.config"
ENV LD_LIBRARY_PATH="/opt/scylladb/libreloc"
ENV UBSAN_OPTIONS="suppressions=/opt/scylladb/libexec/ubsan-suppressions.supp"

ENTRYPOINT ["/opt/scylladb/libexec/scylla", "--options-file", "/etc/scylla/scylla.yaml", "--log-to-stdout", "1", "--default-log-level", "info", "--network-stack", "posix", "--developer-mode", "1"]
