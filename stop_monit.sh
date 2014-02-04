#!/bin/bash
kill $(cat /var/run/monit.pid)
rm /var/run/monit.pid
echo "Monit Stopped"
