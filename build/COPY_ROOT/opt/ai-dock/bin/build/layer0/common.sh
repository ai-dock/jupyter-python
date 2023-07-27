#!/bin/bash

# Must exit and fail to build if any command fails
set -e

kernel_path=/usr/local/share/jupyter/kernels/

main() {
    install_jupyter
    # Create target playground environment
    if [[ ${PYTHON_VERSION} == 2* ]]; then
        install_python "defaults" 2
    else
        install_python "conda-forge" 3
    fi
}

install_jupyter() {
    $MAMBA_CREATE -n jupyter python=${MAMBA_BASE_PYTHON_VERSION} && \
    micromamba -n jupyter install -c conda-forge -y \
        jupyter \
        jupyterlab
    # This must remain clean. User software should not be in this environment
    printf "Removing default ipython kernel...\n"
    rm -rf /root/micromamba/envs/jupyter/share/jupyter/kernels/python3
}

install_python() {
    conda_channel=$1
    python_major_version=$2
    $MAMBA_CREATE -n ${PYTHON_MAMBA_NAME} python=${PYTHON_VERSION}
    micromamba -n ${PYTHON_MAMBA_NAME} install -c "${conda_channel}" -y \
        ipykernel \
        ipywidgets
    
    # Both kernels point to the same python environment
    sed -i 's/PYTHON_MAJOR_VERSION/'"${python_major_version}"'/g' ${kernel_path}pythonX/kernel.json
    sed -i 's/PYTHON_MAMBA_NAME/'"${PYTHON_MAMBA_NAME}"'/g' ${kernel_path}pythonX/kernel.json
    mv ${kernel_path}pythonX ${kernel_path}python${python_major_version}
    
    sed -i 's/PYTHON_VERSION/'"${PYTHON_VERSION}"'/g' ${kernel_path}python_xxx/kernel.json
    sed -i 's/PYTHON_MAMBA_NAME/'"${PYTHON_MAMBA_NAME}"'/g' ${kernel_path}python_xxx/kernel.json
    mv ${kernel_path}python_xxx ${kernel_path}${PYTHON_MAMBA_NAME}
    
}

main "$@"; exit