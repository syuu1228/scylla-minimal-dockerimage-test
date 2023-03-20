#!/busybox/sh
[[ -z "$LD_PRELOAD" ]] || { echo "$0: not compatible with LD_PRELOAD" >&2; exit 110; }
export LC_ALL=en_US.UTF-8
x="$(readlink -f "$0")"
b="$(basename "$x")"
d="$(dirname "$x")"
CENTOS_SSL_CERT_FILE="/etc/pki/tls/cert.pem"
if [ -f "${CENTOS_SSL_CERT_FILE}" ]; then
  c=${CENTOS_SSL_CERT_FILE}
fi
DEBIAN_SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
if [ -f "${DEBIAN_SSL_CERT_FILE}" ]; then
  c=${DEBIAN_SSL_CERT_FILE}
fi
PYTHONPATH="${d}:${d}/libexec:$PYTHONPATH" PATH="${d}/../bin:${d}/../python3/bin:${PATH}" SSL_CERT_FILE="${c}" exec -a "$0" "${d}/libexec/${b}" "$@"
