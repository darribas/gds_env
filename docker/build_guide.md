# Build the Docker image

---

**NOTE**: This guide is for *building* the Docker image from source. If you just want to run `gds_env`, see the [install guide](../docker_install) instead.

---

## Requirements

- Docker installed and running
- A clone of the [`gds_env` repository](https://github.com/darribas/gds_env)
- `make`

## Build process

From the root of the repository, run:

```shell
make build
```

This builds the image and tags it as `gds:latest` (and `gds:<date>_<arch>`). The build log is saved to `env/build_<arch>.log`.

The build installs the full conda environment defined in `env/gds_<arch>.yml`, plus a set of additional tools (Quarto, Jekyll, tippecanoe, decktape, LaTeX tools, Vim, GPQ). It can take a while — especially on first run.

Once complete, verify the image was built:

```shell
docker image ls | grep gds
```

## Testing the build

To run the test notebooks against a built image:

```shell
make test image=gds:<your-tag>
```

This runs both the Python and R check notebooks inside the container and saves HTML output locally.

## Building `gds_code`

To build the `gds_code` variant (VS Code in the browser) on top of an existing `gds` image:

```shell
make build_code image=gds:<your-tag>
```

See the [`gds_code` stack page](../../stacks/gds_code) for more details.
