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
- This [`cloud-config.yml`](cloud-config.yml) file

### Create a VM

We will set up a VM that runs [RancherOS](https://rancher.com/rancher-os/). Following [their own
docs](https://rancher.com/docs/os/v1.x/en/installation/workstation/docker-machine/):

```shell
docker-machine create -d virtualbox \
      --virtualbox-boot2docker-url https://releases.rancher.com/os/latest/rancheros.iso \
      --virtualbox-memory 2048 \
      gdsbox
```

This will create a VirtualBox VM that you can check with `VBoxManage`:

```shell
VBoxManage list vms
```

You should be able to see something similar to:

```shell
"gdsbox" {cb546670-3388-461d-8f0f-87ce352e9134}
```

To set the environment of your shell to that machine:

```shell
docker-machine env gdsbox
```

will display the command to run for that. Keep in mind that that exports
environment variables, so if you want to go back to the original, you can:

```shell
eval $(docker-machine env gdsbox)
```

If you want to reset them:

```shell
eval $(docker-machine env -u)
```

### Provision it

Now there is a VM, we need to "fill" it with `gds_env` container. 

- From the same shell with the `gdsbox` env activated, we can go ahead 
and provision the desired container:

```shell
docker pull darribas/gds_<flavour>:<version>
```

- Now we need to "enter" the VM to add a few extra bits and pieces:

```shell
docker-machine ssh gdsbox -t
```

- Add autostart of the container. To do this, you will need to add the content
  of the [`cloud-config.yml`](cloud-config.yml)to the VM cloud-config:

```shell
sudo vi /var/lib/rancher/conf/cloud-config.yml
```

- Enable the VirtualBox tools to make it easy to share folders:

```shell
sudo ros service enable virtualbox-tools
```

- Leave the inside of the VM:

```shell
exit
```

### Export provisioned VM into `.ova`

## Deployment

### Requirements

To be able to run a VM created by the previous process, you will need the
following:

- [VirtualBox](https://www.virtualbox.org/)
- A copy of the VM generated (a file with the `.ova` file format). See [this
  folder](https://www.dropbox.com/sh/24ehjlwgcjzepeb/AACEVD0IJ9aNj2gpbYmRpAnUa?dl=0)
  for available copies.

