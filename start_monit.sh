#!/bin/bash
start-stop-daemon --start --quiet --exec /usr/sbin/monit.sh -b
echo "Monit Started"
