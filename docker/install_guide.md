# Install on Docker

## Installing Docker

To run the `gds_env` you need Docker installed on your machine. Here are the official installation guides:

- [Windows](https://docs.docker.com/desktop/install/windows-install/)
- [macOS](https://docs.docker.com/desktop/install/mac-install/)
- [Ubuntu Linux](https://docs.docker.com/engine/install/ubuntu/)

## Pulling the image

Once Docker is running, pull the `gds` image:

```shell
docker pull darribas/gds:{{ site.gds_env.version }}
```

This may take a few minutes on the first run — the image includes a full Python and R geospatial stack. See the [gds stack page](../stacks/gds) for a full list of included packages.

## Running the image

```shell
docker run --rm -ti -p 8888:8888 -v ${PWD}:/home/jovyan/work darribas/gds:{{ site.gds_env.version }}
```

A few notes:

- This opens port `8888` so you can access JupyterLab from your browser at `localhost:8888`. Copy the token printed in the terminal when prompted.
- The `-v ${PWD}:/home/jovyan/work` flag mounts your current folder into the container. Files in that folder will appear under `work/` in the JupyterLab file browser. Replace `${PWD}` with any path on your machine — for example `/Users/<username>/Desktop` on macOS.
