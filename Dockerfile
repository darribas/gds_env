# Binder entrypoint ONLY — not the main image build.
# mybinder.org builds this repo root; it pulls the published gds image and drops
# the ./work dir Binder would otherwise mount over. The real build is
# env/Dockerfile.
#
# Bump the tag at release time — see docker/release_checklist.md.
# NOTE: the `gc` suffix on the tag below is not documented anywhere in this repo
# (audit 2.2); confirm the intended tag before the next release bump.
FROM darribas/gds:11.0gc
RUN rm -rf ./work
