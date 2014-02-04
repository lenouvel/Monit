#!/bin/bash

PID="/var/run/monit.pid"
LOG="/var/log/monitortoparse/out.log"
PREV_TOTAL=0
PREV_IDLE=0
MEMTOTAL=(`cat /proc/meminfo | grep MemTotal | awk '{print $2/1024}'`)
DISKSPACE=(`df -k | grep /dev/md2 | awk '{print ($4/1048576)}'`)

echo $$ > $PID
while true; do
  CPU=(`cat /proc/stat | grep '^cpu '`) # Get the total CPU statistics.
  MEMFREE=(`cat /proc/meminfo | grep MemFree | awk '{print $2/1024}'`)
  MEMUSED=(`echo "$MEMTOTAL-$MEMFREE" | bc -l`)
  DISKUSED=(`df -k | grep /dev/md2 | awk '{print ($3/1048576)}'`)
  NET=(`ifstat -i eth0 -q 1 1 | awk '{print FNR ":"$0}' | grep -E ^3`)
  NETOUT=${NET[2]}
  NETIN=${NET[1]}

  unset CPU[0]                          # Discard the "cpu" prefix.
  IDLE=${CPU[4]}                        # Get the idle CPU time.
 
  # Calculate the total CPU time.
  TOTAL=0
  for VALUE in "${CPU[@]}"; do
    let "TOTAL=$TOTAL+$VALUE"
  done
 
  # Calculate the CPU usage since we last checked.
  let "DIFF_IDLE=$IDLE-$PREV_IDLE"
  let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
  let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"
  echo -e "$DIFF_USAGE $MEMUSED $MEMTOTAL $DISKUSED $DISKSPACE $NETIN $NETOUT" > $LOG
 
  # Remember the total and idle CPU times for the next check.
  PREV_TOTAL="$TOTAL"
  PREV_IDLE="$IDLE"
 
  # Wait before checking again.
  sleep 1.5
done
