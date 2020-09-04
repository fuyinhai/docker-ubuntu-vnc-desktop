#!/bin/sh
set -eu

/usr/bin/curl http://admin.lab/lab/pvz/$LAB_NAME

/ttyd -p 8080 -c $USERNAME:$PASSWORD /bin/bash

