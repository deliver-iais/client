#!/bin/bash

export LC_CTYPE=C
WEB_VERSION="local-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)"

DOCKER_BUILDKIT=0 docker buildx build --platform linux/amd64 -t 172.17.4.40:443/deliver-web:$WEB_VERSION -f local.Dockerfile --push --no-cache .

echo "Update infrastructure with this version"
echo "ver: $WEB_VERSION"
