#!/bin/bash

CONFIG="~/.config/polybar/config.ini"
MONITORS=$(xrandr --query | grep -w "connected")

# kill running polybars
killall -q polybar

# launch primary monitor's polybar
PRIMARY_MONITOR=$(echo "${MONITORS}" | grep -w "primary" | cut -d" " -f1)
MONITOR=${PRIMARY_MONITOR} polybar --config=${CONFIG} primary 2>&1 | tee -a /tmp/polybar-${PRIMARY_MONITOR}.log &
disown

# launch secondary monitors' polybar
SECONDARY_MONITORS=$(echo "${MONITORS}" | grep -v "primary" | cut -d" " -f1)
for monitor in ${SECONDARY_MONITORS}; do
  MONITOR=${monitor} polybar --config=${CONFIG} secondary 2>&1 | tee -a /tmp/polybar-${monitor}.log &
  disown
  echo
done
