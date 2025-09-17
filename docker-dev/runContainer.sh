#!/bin/bash

# If not working, first do: sudo rm -rf /tmp/.docker.xauth
# It still not working, try running the script as root.

XAUTH=/tmp/.docker.xauth

echo "Preparing Xauthority data..."
xauth_list=$(xauth nlist :0 | tail -n 1 | sed -e 's/^..../ffff/')
if [ ! -f $XAUTH ]; then
    if [ ! -z "$xauth_list" ]; then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi
echo "Done."

echo "Verifying file contents:"
file $XAUTH
echo "--> It should say \"X11 Xauthority data\"."

echo "Permissions:"
ls -FAlh $XAUTH

echo "Running docker container..."

# Extra commands for 'docker run':
#   --gpus all      Unable to use for WSL. Use with a native Linux installation. Not via WSL or running a
#                   linux docker container on Mac.

docker run -it \
    -p 18570:18570/udp \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --volume="/dev:/dev" \
    --volume="/var/run/dbus/:/var/run/dbus/:z" \
    --volume="$HOME:$HOME/mount" \
    --privileged \
    --name qadt-dev \
    qadt-image