# Jupyter Python

Run Jupyter lab or notebook with a (quite) fresh Python installation. No assumptions have been made about your use case so nothing but iPython support is included.

## About Jupyter

Jupyter is an interactive computing environment widely used in data analysis, data science, and research. It serves as the next-generation interface for Jupyter, offering a flexible workspace with a multi-panel layout. Jupyter supports various programming languages like Python, R, and Julia, enabling users to create and share documents containing live code, visualizations, and narrative text - This image provides Python kernels.

Within Jupyter, users can arrange notebooks, text files, terminal windows, and other components in a customizable workspace. The platform provides advanced functionalities such as drag-and-drop support for files, rich text editors, and interactive visualizations, empowering data analysts, scientists, and researchers to explore data, conduct analysis, and experiment with code more effectively.

## Pre-built Images

Docker images are built automatically through a GitHub Actions workflow and hosted at the GitHub Container Registry.

#### Version Tags

There is no `latest` tag.
Tags follow these patterns:

##### _CUDA_
`:[python-version]-cuda-[x.x.x]{-cudnn[x]}-[base|runtime|devel]-[ubuntu-version]`

##### _ROCm_
`:[python-version]-rocm-[x.x.x]-[core|runtime|devel]-[ubuntu-version]`

##### _CPU_
`:[python-version]-ubuntu-[ubuntu-version]`

Browse [here](https://github.com/ai-dock/jupyter-python/pkgs/container/jupyter-python) for an image suitable for your target environment.

You can also self-build from source by editing `.env` and running `docker compose build`.

Supported Python versions: `all` `3.11`, `3.10`, `3.9`, `3.8`, `2.7`

Supported Platforms: `NVIDIA CUDA`, `AMD ROCm`, `CPU`

## Run Locally

A 'feature-complete' docker-compose.yaml file is included for your convenience. All features of the image are included - Simply edit the environment variables, save and then type `docker compose up`.

If you prefer to use the standard `docker run` syntax, the command to pass is `init.sh`.

## Run in the Cloud

__Container Cloud__

Container providers don't give you access to the docker host but are quick and easy to set up. They are often inexpensive when compared to a full VM or bare metal solution.

All images built for ai-dock are tested for compatibility with both [vast.ai](https://cloud.vast.ai/?ref_id=62897&template_id=24694ce07616536027f37359c95f0d7c) and [runpod.io](https://runpod.io/gsc?template=qcnhzcoflg&ref=m0vk9g4f).

Images that include Jupyter are also tested to ensure compatibility with [Paperspace Gradient](https://console.paperspace.com/signup?R=FI2IEQI)

See a list of pre-configured templates [here](#pre-configured-templates)

>[!WARNING]  
>Container cloud providers may offer both 'community' and 'secure' versions of their cloud. If your usecase involves storing sensitive information (eg. API keys, auth tokens) then you should always choose the secure option.

__VM Cloud__

Running docker images on a virtual machine/bare metal server is much like running locally.

You'll need to:
- Configure your server
- Set up docker
- Clone this repository
- Edit `.env`and `docker-compose.yml`
- Run `docker compose up`

Find a list of compatible VM providers [here](#compatible-vm-providers).

### Connecting to Your Instance

All services listen for connections at [`0.0.0.0`](https://en.m.wikipedia.org/wiki/0.0.0.0). This gives you some flexibility in how you interact with your instance:

_**Expose the Ports**_

This is fine if you are working locally but can be **dangerous for remote connections** where data is passed in plaintext between your machine and the container over http.

_**SSH Tunnel**_

This is the preferred method. You will only need to expose `port 22` (SSH) which can then be used with port forwarding to allow **secure** connections to your services.

If you are unfamiliar with port forwarding then you should read the guides [here](https://www.digitalocean.com/community/tutorials/ssh-essentials-working-with-ssh-servers-clients-and-keys?refcode=405a7b000d31#setting-up-ssh-tunnels) and [here](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-tunneling-on-a-vps?refcode=405a7b000d31).

## Environment Variables

| Variable              | Description |
| --------------------- | ----------- |
| `GPU_COUNT`           | Limit the number of available GPUs |
| `JUPYTER_MODE`        | `lab` (default), `notebook` |
| `JUPYTER_TOKEN`       | Manually set your password |
| `RCLONE_*`            | Rclone configuration - See [rclone documentation](https://rclone.org/docs/#config-file) |
| `SKIP_ACL`            | Set `true` to skip modifying workspace ACL |
| `SSH_PUBKEY`          | Your public key for SSH |
| `WORKSPACE`           | A volume path. Defaults to `/workspace/` |


Environment variables can be specified by using any of the standard methods (`docker-compose.yaml`, `docker run -e...`). Additionally, environment variables can also be passed as parameters of `init.sh`.

Passing environment variables to init.sh is usually unnecessary, but is useful for some cloud environments where the full `docker run` command cannot be specified.

Example usage: `docker run -e STANDARD_VAR1="this value" -e STANDARD_VAR2="that value" init.sh EXTRA_VAR="other value"`

## Software Management

A small software collection is installed by apt-get. This is mostly to provide basic functionality, but also includes `openssh-server` as the OS vendor is likely to be first to patch any security issues.

All other software is installed into its own environment by `micromamba`, which is a drop-in replacement for conda/mamba. Read more about it [here](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html).

Micromamba environments are particularly useful where several software packages are required but their dependencies conflict. 

### Installed Micromamba Environments

| Environment    | Packages / Rationale |
| -------------- | ----------------------------------------- |
| `base`         | micromamba's base environment |
| `system`       | `supervisord`, `rclone` - latest versions |
| `jupyter`      | `jupyter` |
| `python_[ver]` | `python` |

If you are extending this image or running an interactive session where additional software is required, you should almost certainly create a new environment first. See below for guidance.

### Useful Micromamba Commands

| Command                              | Function |
| -------------------------------------| --------------------- |
| `micromamba env list`                | List available environments |
| `micromamba activate [name]`         | Activate the named environment |
| `micromamba deactivate`              | Close the active environment |
| `micromamba run -n [name] [command]` | Run a command in the named environment without activating |

All ai-dock images create micromamba environments using the `--experimental` flag to enable hardlinks which can save disk space where multiple environments are available.

To create an additional micromamba environment, eg for python, you can use the following:

`micromamba --experimental create -y -c conda-forge -c defaults -n [name] python=3.10`

## Volumes

Data inside docker containers is ephemeral - You'll lose all of it when the container is destroyed.

You may opt to mount a data volume at `/workspace` - This is a directory that ai-dock images will look for to make downloaded data available outside of the container for persistence. 

This is usually of importance where large files are downloaded at runtime or if you need a space to save your work. This is the ideal location to store Jupyter notebooks(.ipynb) and datasets.

You can define an alternative path for the workspace directory by passing the environment variable `WORKSPACE=/my/alternative/path/` and mounting your volume there. This feature will generally assist where cloud providers enforce their own mountpoint location for persistent storage.

The provided docker-compose.yaml will mount the local directory `./workspace` at `/workspace`.

As docker containers generally run as the root user, new files created in /workspace will be owned by uid 0(root).

To ensure that the files remain accessible to the local user that owns the directory, the docker entrypoint will set a default ACL on the directory by executing the commamd `setfacl -d -m u:${WORKSPACE_UID}:rwx /workspace`.

If you do not want this, you can set the environment variable `SKIP_ACL=true`.

## Running Services

This image will spawn multiple processes upon starting a container because some of our remote environments do not support more than one container per instance.

All processes are managed by [supervisord](https://supervisord.readthedocs.io/en/latest/) and will restart upon failure until you either manually stop them or terminate the container.

>[!NOTE]  
>*Some of the included services would not normally be found **inside** of a container. They are, however, necessary here as some cloud providers give no access to the host; Containers are deployed as if they were a virtual machine.*

### Jupyter

The jupyter server will launch a `lab` instance unless you specify `JUPYTER_MODE=notebook`.

Jupyter server will listen on port `8888`.

A python kernel will be installed coresponding with the python version(s) of the image.

Jupyter's official documentation is available at https://jupyter.org/ 

### SSHD

A SSH server will be started if at least one valid public key is found inside the running container in the file `/root/.ssh/authorized_keys`

There are several ways to get your keys to the container.

- If using docker compose, you can paste your key in the local file `config/authorized_keys` before starting the container.
 
- You can pass the environment variable `SSH_PUBKEY` with your public key as the value.

- Cloud providers often have a built-in method to transfer your key into the container

If you choose not to provide a public key then the SSH server will not be started.

To make use of this service you should map `port 22` to a port of your choice on the host operating system.

See [this guide](https://www.digitalocean.com/community/tutorials/ssh-essentials-working-with-ssh-servers-clients-and-keys?refcode=405a7b000d31#) by DigitalOcean for an excellent introduction to working with SSH servers.

>[!NOTE]  
>_SSHD is included because the end-user should be able to know the version prior to deloyment. Using a providers add-on, if available, does not guarantee this._

### Rclone mount

Rclone allows you to access your cloud storage from within the container by configuring one or more remotes. If you are unfamiliar with the project you can find out more at the [Rclone website](https://rclone.org/).

Any Rclone remotes that you have specified, either through mounting the config directory or via setting environment variables will be mounted at `/workspace/remote/[remote name]`. For this service to start, the following conditions must be met:

- Fuse3 installed in the host operating system
- Kernel module `fuse` loaded in the host
- Host `/etc/passwd` mounted in the container
- Host `/etc/group` mounted in the container
- Host device `/dev/fuse` made available to the container
- Container must run with `cap-add SYS_ADMIN`
- Container must run with `securiry-opt apparmor:unconfined`
- At least one remote must be configured

The provided docker-compose.yaml includes a working configuration (add your own remotes).

In the event that the conditions listed cannot be met, `rclone` will still be available to use via the CLI - only mounts will be unavailable.

If you intend to use the `rclone create` command to interactively generate remote configurations you should ensure `port 53682` is accessible. See https://rclone.org/remote_setup/ for further details.

>[!NOTE]  
>_Rclone is included to give the end-user an opportunity to easily transfer files between the instance and their cloud storage provider._

>[!WARNING]  
>You should only provide auth tokens in secure cloud environments.

### Logtail

This script follows and prints the log files for each of the above services to stdout. This allows you to follow the progress of all running services through docker's own logging system.

If you are logged into the container you can follow the logs by running `logtail.sh` in your shell.

## Open Ports

Some ports need to be exposed for the services to run or for certain features of the provided software to function


| Open Port             | Service / Description |
| --------------------- | --------------------- |
| `22`                  | SSH server            |
| `8888`                | Jupyter server |
| `53682`               | Rclone interactive config |

## Pre-Configured Templates

**Vast.​ai**
[Python All](https://cloud.vast.ai/?ref_id=62897&template_id=24694ce07616536027f37359c95f0d7c)

**Runpod.​io**
[Python All](https://runpod.io/gsc?template=qcnhzcoflg&ref=m0vk9g4f)

**Paperspace**
- Create a [new notebook](https://console.paperspace.com/signup?R=FI2IEQI) with the `Start from Scratch` template.
- Select `Advanced options`
- In Container Name enter `ghcr.io/ai-dock/jupyter-python:all-cuda-11.8.0-cudnn8-runtime-22.04`
- In Registry Username enter `x` (Paperspace bug)
- In Command enter `init.sh WORKSPACE=/notebooks`


>[!NOTE]  
>These templates are configured to use Python `all` with the `cuda-11.8-0-cudnn8-runtime` tag but you are free to change to any of the available Python CUDA tags listed [here](https://github.com/ai-dock/jupyter-python/pkgs/container/jupyter-python)

## Compatible VM Providers

Images that do not require a GPU will run anywhere - Use an image tagged `:*-ubuntu-xx.xx`

Where a GPU is required you will need either `:*cuda*` or `:*rocm*` depending on the underlying hardware.

A curated list of VM providers currently offering GPU instances:

- [Akami/Linode](https://www.linode.com/lp/refer/?r=d49cf667cec6bcbb6c2d7d70665c5c9b9a5a4b95)
- [Amazon Web Services](https://aws.amazon.com)
- [Google Compute Engine](https://cloud.google.com)
- [Vultr](https://www.vultr.com/?ref=9519053-8H)

---

_The author ([@robballantyne](https://github.com/robballantyne)) may be compensated if you sign up to services linked in this document. Testing multiple variants of GPU images in many different environments is both costly and time-consuming; This helps to offset costs_
