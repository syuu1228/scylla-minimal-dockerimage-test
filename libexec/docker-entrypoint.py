#!/busybox/env python3
# -*- coding: utf-8 -*-

import os
import sys
import re
import signal
import subprocess
import scyllasetup
import logging
import commandlineparser
sys.path.append('/opt/scylladb/scripts')
from scylla_util import sysconfig_parser

logging.basicConfig(stream=sys.stdout, level=logging.DEBUG, format="%(message)s")

supervisord = None

def signal_handler(signum, frame):
    supervisord.send_signal(signum)

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

try:
    arguments, extra_arguments = commandlineparser.parse()
    setup = scyllasetup.ScyllaSetup(arguments, extra_arguments=extra_arguments)
    setup.developerMode()
    setup.cpuSet()
    setup.io()
#    setup.cqlshrc()
    setup.arguments()
#    setup.set_housekeeping()
#    supervisord = subprocess.Popen(["/usr/bin/supervisord", "-c",  "/etc/supervisord.conf"])
#    supervisord.wait()

    cmdline = ['/usr/bin/scylla']
    scylla_server_conf = sysconfig_parser('/etc/default/scylla-server')
    scylla_args = scylla_server_conf.get('SCYLLA_ARGS')
    cmdline += scylla_args.split()
    if arguments.developerMode == '0' and arguments.io_setup == '1':
        io_conf = sysconfig_parser('/etc/scylla.d/io.conf')
        seastar_io = io_conf.get('SEASTAR_IO')
        cmdline += seastar_io.split()
    if arguments.developerMode == '1':
        dev_mode_conf = sysconfig_parser('/etc/scylla.d/dev-mode.conf')
        dev_mode = dev_mode_conf.get('DEV_MODE')
        cmdline += dev_mode.split()
    if arguments.cpuset:
        cpuset_conf = sysconfig_parser('/etc/scylla.d/cpuset.conf')
        cpuset = cpuset_conf.get('CPUSET')
        cmdline += cpuset.split()
    docker_conf = sysconfig_parser('/etc/scylla.d/docker.conf')
    scylla_docker_args = docker_conf.get('SCYLLA_DOCKER_ARGS')
    cmdline += scylla_docker_args.split()
    print(f'cmdline:{cmdline}')
    scylla_server = subprocess.Popen(cmdline, env={'SCYLLA_HOME': '/var/lib/scylla', 'SCYLLA_CONF': '/etc/scylla'})
    scylla_server.wait()
except Exception:
    logging.exception('failed!')
