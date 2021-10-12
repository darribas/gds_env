# Build a VirtualBox VM

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
- This [`cloud-config.yml`](https://github.com/darribas/gds_env/raw/master/virtualbox/cloud-config.yml) file

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
  of the [`cloud-config.yml`](https://github.com/darribas/gds_env/raw/master/virtualbox/cloud-config.yml)to the VM cloud-config:

```shell
sudo vi /var/lib/rancher/conf/cloud-config.yml
```

Alternatively, you can copy the cloud-config.yml on the host machine into the docker-machine and appened it using:
```shell
# Copy the file via scp to the docker-machine
docker-machine scp ~/Desktop/cloud-config.yml gdsbox:
# Now ssh into the docker-machine
docker-machine ssh gdsbox -t
# And append it to the cloud-config.yml on the docker-machine using sudo
sudo sh -c 'cat "/home/docker/cloud-config.yml" >> /var/lib/rancher/conf/cloud-config.yml'
```

- Enable and start the VirtualBox tools to make it easy to share folders:

```shell
sudo ros service enable virtualbox-tools
sudo ros service up virtualbox-tools
```

- Leave the inside of the VM:

```shell
exit
```

### Export provisioned VM into `.ova`

Once the VM is built and provisioned, we can write it into an appliance file.

First we need to stop the running VM:

```shell
docker-machine stop gdsbox
```

Then we can export:

```shell
VBoxManage export gdsbox --iso -o <file-name>.ova
```

## Deployment

For a guide on importing the `.ova` export and running the resulting VM,
please check [here](../virtualbox_install).

