#!/bin/sh
set -e

#
# Trigger reload for all Gunicorn processes
#
kill -HUP $(pidof -x gunicorn)
