# Developer notes for `gds_env`


## Pre-release

1. [ ] Update `Dockerfile` for `gds_py`
1. [ ] Build `gds_py`
1. [ ] Potentially update check notebook for `gds_py`
1. [ ] Run check for `gds_py`
1. [ ] Push `gds_py` image
1. [ ] Update dependency version on `Dockerfile` for `gds` (and other potential changes to `gds`)
1. [ ] Build `gds`
1. [ ] Potentially update check notebook for `gds`
1. [ ] Run check for `gds` R stack
1. [ ] Push `gds` image
1. [ ] Write stacks and commit version changes on git (preferably use `"Package version changes from X to Y"` for commit message)
1. [ ] Update dependency version on `Dockerfile` for `gds_dev` (and other potential changes to `gds_dev`)
1. [ ] Build `gds_dev`
1. [ ] Push `gds_dev` image

## Release

1. [ ] Update version number on `README.md`
1. [ ] Update microbadger badges (run `curl -X POST <webhook>` to refresh)
1. [ ] Make release on Github
