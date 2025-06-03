#!/bin/bash -x
docker build --tag=incus-os-devcontainer --add-host=host.docker.internal:host-gateway --build-arg "INCUS_ADMIN_GID=$(getent group incus-admin | cut -d: -f3)" .devcontainer
