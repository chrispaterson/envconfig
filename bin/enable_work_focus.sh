#!/bin/bash

idle_time=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1000000000); exit}')

if [ "$idle_time" -lt 60 ]; then
  shortcuts run "Enable Work Focus"
else
  shortcuts run "Disable Work Focus"
fi
