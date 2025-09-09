#!/bin/bash

# Exits cleanly if something fails
set -e

# Sources for you
source "/opt/ros/humble/setup.bash"

# To execute command you want
echo "==> Container ready"
exec "$@"
