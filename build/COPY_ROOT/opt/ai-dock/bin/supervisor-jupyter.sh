#!/bin/bash

trap 'kill $(jobs -p)' EXIT

if [[ -z $JUPYTER_MODE || ! "$JUPYTER_MODE" = "notebook" ]]; then
    JUPYTER_MODE="lab"
fi

printf "Starting Jupyter %s...\n" $JUPYTER_MODE

wait -n
micromamba run -n jupyter jupyter \
    $JUPYTER_MODE \
    --allow-root \
    --ip=0.0.0.0 \
    --no-browser \
    --ServerApp.trust_xheaders=True \
    --ServerApp.disable_check_xsrf=False \
    --ServerApp.allow_remote_access=True \
    --ServerApp.allow_origin='*' \
    --ServerApp.allow_credentials=True \
    --ServerApp.notebook_dir=/workspace \
    --ServerApp.preferred_dir=/workspace \
    --KernelSpecManager.ensure_native_kernel=False
