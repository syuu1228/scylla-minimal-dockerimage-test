#!/bin/bash

tar xvpf scylla-unified-5.3.0~dev-0.20230215.19edaa9b78b7.x86_64.tar.gz
rm -rf scylla-root
(cd scylla-5.3.0~dev/scylla && ./install.sh --without-systemd --root ../../scylla-root || true)
rm -rf scylla-root/etc/scylla.d
rm -rf scylla-root/etc/sysconfig
rm -rf scylla-root/opt/scylladb/bin
rm -f scylla-root/opt/scylladb/libexec/iotune
rm -f scylla-root/opt/scylladb/libexec/patchelf
rm -rf scylla-root/opt/scylladb/node_exporter
rm -rf scylla-root/opt/scylladb/scripts
rm -rf scylla-root/opt/scylladb/scyllatop
rm -rf scylla-root/opt/scylladb/share
rm -rf scylla-root/opt/scylladb/SCYLLA-OFFLINE-FILE
rm -rf scylla-root/usr
rm -rf scylla-root/var/lib/scylla-housekeeping
