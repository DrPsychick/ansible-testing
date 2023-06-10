#!/bin/sh

set -e

if [ -n "$ROOT_KEY" ]; then
  mkdir -p /root/.ssh
  echo "$ROOT_KEY" >> /root/.ssh/authorized_keys
fi

cat </dev/$(cat /sys/devices/virtual/tty/console/active) >/dev/null 2>&1 &

exec "$@"
