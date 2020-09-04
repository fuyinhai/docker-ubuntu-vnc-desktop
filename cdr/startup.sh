#!/bin/sh
set -eu

/usr/bin/curl http://admin.lab/lab/pvz/$LAB_NAME

/usr/local/cdr/lib/node /usr/local/cdr --bind-addr 0.0.0.0:8080

