# Build Docker containers

---

**IMPORTANT** This is a guide for *building* Docker containers, not for downloading or using existing ones. If you are an end-user, you probably prefer to [install containers](../docker_install).

---

## Requirements

To build one of the `gds_env` flavours from source, you need to access the Docker image can be built by running:

## Build process

Make sure to point your terminal of choice to the folder where you have placed the `Dockerfile` to build:

```shell
cd /path/to/folder/with/Dockerfile
```

Then, run the following command:

```shell
docker build -t <image-name> .
```

where `<image-name>` can be replaced by the name you want to give to the image you will create.

Mind this process may take a long time. Particularly for [`gds`](../../stacks/gds), several of the R libraries need to be compiled from source and this takes time and CPU cycles.

Once it finishes, you can check it has been built correctly by:

```shell
docker image ls
```

And you should see one image with the `image-name` you have selected.
