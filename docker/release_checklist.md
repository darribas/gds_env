# Developer notes for `gds_env`

## Pre-release

### Build and test

1. [ ] Update `env/gds_amd64.yml` and `env/gds_arm64.yml` with any package changes
1. [ ] Update `GDS_ENV_VERSION` arg in `env/Dockerfile` (or pass via `make build`)
1. [ ] Build the image: `make build image=darribas/gds:<version>`
1. [ ] Update check notebooks if needed (`env/py/check_py_stack.ipynb`, `env/r/check_r_stack.ipynb`)
1. [ ] Run tests: `make test image=darribas/gds:<version>`
1. [ ] Write stack files: `make write_stacks image=darribas/gds:<version>`
1. [ ] Confirm CI passes and explicit env files are written
1. [ ] Push image to Docker Hub: `docker push darribas/gds:<version>`

### Build `gds_code`

1. [ ] Build: `make build_code image=darribas/gds:<version>`
1. [ ] Test manually (launch container, verify code-server and extensions load)
1. [ ] Update `frontend_code/compose.yml` version reference
1. [ ] Push image: `docker push darribas/gds_code:<version>`

## Release

1. [ ] Update version in `website/_config.yml`
1. [ ] Update version in `Dockerfile` (root-level, used for Binder)
1. [ ] Update version in citation block in `README.md`
1. [ ] Build website: `make website`
1. [ ] Commit version and website changes: `git commit -am "RLS: v<X.X> - Website built"`
1. [ ] Tag release: `git tag -a v<X.X> -m "Version <X.X>"`
1. [ ] Push: `git push origin master && git push origin --tags`
1. [ ] Create release on GitHub
