#!/usr/bin/env bash
podman pull payitadmin/devcontainer
podman container inspect devcontainer > /dev/null
ec=$?
if [[ $ec -gt 0 ]];then
    echo "creating new container"
    podman run -dt --platform linux/x86_64 --name devcontainer -v /Users/$USER:/home/user payitadmin/devcontainer /bin/bash
    podman exec -it devcontainer /bin/bash
else
    echo "running existing container"
    podman start devcontainer
    podman exec -it devcontainer /bin/bash
fi
