#!/bin/sh
set -eu

/ttyd -p 8080 -c $USERNAME:$PASSWORD /bin/bash

