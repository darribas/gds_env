# `gds_env` as a VirtualBox VM

This section describes how to deploy the `gds_env` Docker image through
VirtualBox.

## Requirements

This approach does not require Docker installed on the host machine, but the
following needs to be installed and available:

- [VirtualBox](https://www.virtualbox.org/)
- [`vagrant`](https://www.vagrantup.com/)
- The `Vagrantfile` for this project, available to download [here](./Vagrantfile).

Once the VM is created, only VirtualBox is required to run it.

## Provision VirtualBox image

To provision a VM that runs Docker and the `gds_env` image on startup,
automatically, navigate to the folder with the `Vagrantfile`:

```shell
cd path/to/my/folder
```

And run:

```shell
vagrant up
```

The first time you run this on a machine, it will take a long time and will
require a good internet connection as it has to download all the components of
the Docker image, as well as a lightweight layer to make it run on VirtualBox.

When completed, you should be able to point your browser to `localhost:8888`
and JupyterLab should be running.

Once built, you can export the VM into an `.ova` file for transport. Before that, 
make sure the VM is not running:

```shell
vagrant halt
```

And then export with the following command:

```shell
vboxmanage export "GDS Box" -o gds_4p1_vagrant.ova
```

This might take a while but will result on a compressed single file that can be 
imported by VirtualBox on a different machine.

## Run VM through `vagrant` + `VirtualBox`

Once built, every time you want to start the VM again, you need to navigate to
the folder where you keep the `Vagrantfile`:

```shell
cd path/to/my/folder
```

And run:

```shell
vagrant up
```

If the VM is built, booting up should only take a few seconds, one or two
minutes at the most depending on hardware.

Once ready, you should be able to point your browser to `localhost:8888`
and JupyterLab should be running.

### Password

To login to the JupyterLab instance you will need the password `geods`.

### File sharing

By default, the folder where you keep the `Vagrantfile` and where you run
`vagrant up` from is mounted under `/home/jovyan/work` in the container. This
means that, when you access JupyterLab, the `work` folder that appears on the
left-hand side is a "window" into the folder in the host where you start the
VM from.

**NOTE**: you can access all the files and folders _within_ the folder from
which you start the session, but you _cannot_ move outside such location.

### Shutting down

Once you are done with your work and want to stop JupyterLab, you can run:

```shell
vagrant halt
```

## Run VM through `VirtualBox` only

[TBC]

