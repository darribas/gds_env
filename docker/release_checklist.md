# Developer notes for `gds_env`

## Testing buildings

To be able to build  and save the logs for examining errors:

```bash
docker build -t gds:latest . | tee gds_latest.log
```

## Pre-release

1. [ ] Update `Dockerfile` for `gds_py`
1. [ ] Update version ENV variable
1. [ ] Build `gds_py`
1. [ ] Potentially update check notebook for `gds_py`
1. [ ] Pin versions to `Dockerfile` and pip
1. [ ] Run check for `gds_py`
1. [ ] Generate `.yml` file
3. [ ] Confirm CI works (building env with `.yml` and `pip` install files)
4. [ ] Push `gds_py` image
5. [ ] Update dependency version on `Dockerfile` for `gds` (and other potential changes to `gds`)
6. [ ] Build `gds`
7. [ ] Potentially update check notebook for `gds`
8. [ ] Run check for `gds` R stack
9. [ ] Push `gds` image
10. [ ] Write stacks (amend `tini` in `.yml` for CI)
11. [ ] Commit version changes on git (preferably use `"Package version changes from X to Y"` for commit message)
12. [ ] Update dependency version on `Dockerfile` for `gds_dev` (and other potential changes to `gds_dev`)
13. [ ] Build `gds_dev`
14. [ ] Push `gds_dev` image

## Release

1. [ ] Update version number on `README.md`
2. [ ] Update version on Appveyor and Travis tests
3. [ ] Update version number on website's `_config.yml`
4. [ ] Update version number on `virtualbox/Vagrantfile`
5. [ ] Update version number on `virtualbox/cloud_config.yml`
6. [ ] Update microbadger badges (run `curl -X POST <webhook>` to refresh)
7. [ ] Build website with version updated
8. [ ] Mark commit as for release: `git commit -am "RLS: vX.X - Website built"`
9. [ ] Tag version: `git tag -a vX.X -m "Version X.X"`
10. [ ] Push release version: `git push origin master`
11. [ ] Push tags: `git push origin --tags`
12. [ ] Make release on Github
