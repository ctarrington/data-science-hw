#!/bin/bash

# taken from https://gist.github.com/marcomalva/7af9cab40e66d2a539034fb195e5576e

# once launched open notebook in web-browser under: http://localhost:10000
# copy token from podman stdout
#
# based on official web site, see https://jupyter-docker-stacks.readthedocs.io/en/latest/using/running.html#using-the-podman-cli
# see also: [Running rootless Podman as a non-root user | Enable Sysadmin](https://www.redhat.com/sysadmin/rootless-podman-makes-sense)
#

# for rootless mode
uid=${uid:-$(id -u)}
gid=${gid:-$(id -g)}

subuidSize=$(( $(podman info --format "{{ range .Host.IDMappings.UIDMap }}+{{.Size }}{{end }}" ) - 1 ))
subgidSize=$(( $(podman info --format "{{ range .Host.IDMappings.GIDMap }}+{{.Size }}{{end }}" ) - 1 ))

podman run -it --rm -p 10000:8888 \
    -v "${PWD}:/home/jovyan/work:Z" --user $uid:$gid \
    --uidmap $uid:0:1 --uidmap 0:1:$uid --uidmap $(($uid+1)):$(($uid+1)):$(($subuidSize-$uid)) \
    --gidmap $gid:0:1 --gidmap 0:1:$gid --gidmap $(($gid+1)):$(($gid+1)):$(($subgidSize-$gid)) \
    quay.io/jupyter/datascience-notebook

