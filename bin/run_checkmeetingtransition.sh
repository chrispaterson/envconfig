#!/bin/bash

current_hour=$(date +"%H")
current_day=$(date +"%u")

# Run only Monday-Friday (1-5) and between 7 AM - 6 PM
if [[ $current_day -ge 1 && $current_day -le 5 ]] && [[ $current_hour -ge 7 && $current_hour -lt 18 ]]; then
    /usr/bin/shortcuts run "Transition Warning"
fi

