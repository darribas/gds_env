# Install on Docker

## Installing Docker

To install and run any of the `gds_env` [flavours](../stacks) on your computer through Docker, all you need is Docker installed. Please note not every platform (most notably older or non-Pro versions of Windows) meet the requirements to run the Docker app. If your computer cannot run Docker easily, consider [running `gds_env` through VirtualBox](../guides/virtualbox_install).

Here are a few useful links to install Docker:

- Official documentation from Docker to install on [Windows 10 Pro/Student](https://docs.docker.com/docker-for-windows/), [Mac](https://docs.docker.com/docker-for-mac/), and [Ubuntu Linux](https://docs.docker.com/engine/install/ubuntu/)
- [General Docker guide](https://gdsl-ul.github.io/the_knowledge/docker.html) by the [Geographic Data Science Lab](https://www.liverpool.ac.uk/geographic-data-science/).

## Installing `gds_env`

Please check in the description of [each flavour](../stacks) for the exact command. Generally speaking, if you have Docker installed and running on your computer, you can install `gds_env` by typing:

```shell
docker pull darribas/<gds-flavour>:{{ site.gds_env.version }}
```

where `<gds-flavour>` is one of [`gds_py`](../../stacks/gds_py), [`gds`](../../stacks/gds), [`gds_dev`](../../stacks/gds_dev).

## Running `gds_env`

Once installed, you can run a container by typing:

```shell
docker run --rm -ti -p 8888:8888 -v ${PWD}:/home/jovyan/work darribas/<gds-flavour>:{{ site.gds_env.version }}
```

A couple of notes on the command above:

* This opens the `8888` port of the container so you can access JupyterLab 
  from your browser. To access the Lab instance,
  you will have to point your browser to `localhost:8888` and insert the token
  printed on the terminal
* The command also mounts the current folder from where you run it (`${PWD}`) to the container. This means that you can see the files in that folder from JupyterLab by opening the `work` folder in its file browser. You can replace `${PWD}` with the path to any folder on your local machine. For example, to mount the Desktop folder on a Mac, you can replace `${PWD}` by `/Users/<username>/Desktop`.
