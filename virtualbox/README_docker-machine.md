# `gds_env`VirtualBox VM with `docker-machine`

This document covers the following two steps:

1. [Provisioning](#Provision-a-VM): how to create a VirtualBox VM that runs
   the `gds_env` container
1. [Deployment](#Deployment): import a generated `.ova` file into VirtualBox

**NOTE**: this document relies heavily on [this blog
post](https://towardsdatascience.com/sharing-data-visualisations-in-virtualbox-to-keep-it-departments-happy-f978854ea44d).

## Provision a VM

### Requirements

This approach requires the following to be installed on the machine that 
will provision the VM:

- [VirtualBox](https://www.virtualbox.org/)
- [`docker`](https://www.docker.com/)
- [`docker-machine`](https://docs.docker.com/machine/)


## Deployment

### Requirements

To be able to run a VM created by the previous process, you will need the
following:

- [VirtualBox](https://www.virtualbox.org/)
- A copy of the VM generated (a file with the `.ova` file format)

