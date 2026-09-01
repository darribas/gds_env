---
name: env-packages
description: This skill should be used when the user wants to add, remove, or update a package in the gds conda environment ("add geopandas", "add an R package to the image", "drop pyppeteer"), or to re-check the architecture exclusions ("are those arm64 packages still unavailable?", "re-check the flags", "update the checked dates", "can we turn any of those back on?"). Covers env/gds.yml, its `# !arch:` flags, the generated per-arch specs, and how to verify a change by solve without needing Docker. Triggers on — gds.yml, env spec, conda env, arm64 exclusions, linux-aarch64, check-flags, env-specs, "the environment won't solve".
---

# GDS environment packages

`env/gds.yml` is the **single source of truth** for the conda environment on
every architecture (audit 3.1). `env/gds_amd64.yml` and `env/gds_arm64.yml`
are generated from it and gitignored — never edit or commit them.

## The flag format

A package available everywhere is a plain entry. One that conda-forge cannot
serve to some architecture stays a **live** entry carrying a flag:

```yaml
  - r-sf
  - r-duckdb   # !arm64: no linux-aarch64 build (checked 2026-08-20)
  - r-mapview  # !arm64: dep r-leafpop has no linux-aarch64 build (checked 2026-08-20)
```

`env/generate_spec.py` drops flagged lines for the arch they exclude and
strips the flag comment everywhere else. Multiple arches are allowed
(`# !arm64, !osx-arm64:`). `####-` and `#-` are *not* flags — they mark
packages retired on both arches, kept for provenance, and are never emitted.

Arch names are the repo's (`amd64`, `arm64`), matching `BUILDARCH` and the
image tags. conda's names for the same platforms are `linux-64` and
`linux-aarch64`; `env/check_flags.py` holds the mapping.

**Every flag is a package arm64 users do not get.** Keep the set as small as
the facts allow — that is what workflow 1 is for.

## Verification, which both workflows share

There is no Docker in most sessions on this repo, and a full `make build`
takes hours. A solve is the practical gate: it proves the spec *resolves*,
which catches the common failure. It does not prove the image builds.

```bash
make env-specs ARCH=amd64
mamba env create -n _check --dry-run -f env/gds_amd64.yml

make env-specs ARCH=arm64
mamba env create -n _check --dry-run --platform linux-aarch64 -f env/gds_arm64.yml
```

`--platform` resolves a foreign subdir from any host — no emulation, no
install — so **arm64 is verifiable from an x86 machine**. This is how audit
2.5 established the current flag set.

Report the resolved package count from each solve. A large unexplained swing
is a finding, not a detail.

CI runs both on every PR that touches `env/gds.yml` or the scripts
(`.github/workflows/test_environment.yml`): a full create plus import check on
linux-64, and a dry-run solve on linux-aarch64.

## Workflow 1 — re-check the architecture flags

Flags are **dated claims, not facts**. conda-forge aarch64 coverage keeps
improving: audit 2.5 found 48 of 56 long-standing arm64 exclusions had gone
stale, and restoring them widened the arm64 R stack by 44 packages. Re-check
periodically — before a release is a good moment.

**Step 1. Screen against conda-forge.**

```bash
make check-flags
```

This prints each flag, whether the package (or the dependency the flag blames)
now has a build for that architecture, and how many days ago the flag was last
checked. `--exit-code` makes it exit 1 when candidates exist, for scheduled use.

**Step 2. Treat candidates as suspects, not conclusions.**

Availability is *necessary, not sufficient*. In audit 2.5 the index said 48
packages were available; the solve then rejected four, because their own
dependencies had no aarch64 build. Do not skip to editing the file.

**Step 3. Unflag the candidates.** Remove the `# !arch:` comment, keep the
entry. Change nothing else.

**Step 4. Re-solve the affected architecture** (see Verification above).

**Step 5. Re-flag whatever the solve rejects.** Read the solver error for the
package that could not be found — often a dependency, not the package you
unflagged. Name it and today's date:

```yaml
  - r-mapview  # !arm64: dep r-leafpop has no linux-aarch64 build (checked 2026-09-01)
```

**Step 6. Update the dates you actually verified**, and the `Last full
re-check` line in the `env/gds.yml` header. Only change a date you rechecked
this session — a stale date is honest, a fabricated one is not.

**Step 7. Report** what moved: packages restored, packages still blocked and
by what, and the before/after resolved counts from the solves.

If nothing is liftable, say so plainly and bump the dates. A no-change result
is a real result — it is what `make check-flags` reported on 2026-09-01, twelve
days after the flags were set.

## Workflow 2 — add, remove, or change a package

**Step 1. Edit `env/gds.yml` only.** Put the entry in the section it belongs to
(the file is grouped: Python, Geospatial, GDS, R, Other) and keep the existing
alphabetical-ish ordering. Pip-only packages go under the `pip:` block.

Do **not** pin a version. This project tracks latest deliberately (audit 4.1,
won't-fix); a proposed fix reading "pin X" is void. Constraints that express a
real requirement (`geopandas>=1`, `r-tmap>=4`) are fine.

**Step 2. Solve both architectures** (see Verification above). Adding a package
available only on amd64 is the normal way a new flag gets created.

**Step 3. If the arm64 solve fails**, find the unavailable package in the
solver output, add a flag naming the reason and today's date, regenerate, and
solve again. Repeat until clean. Check the *dependency* — the flagged package
is often available while something it needs is not.

**Step 4. If the package is Python and importable**, check whether
`env/py/check_py_stack.ipynb` needs to know about it: that notebook derives its
import list from the generated spec, and maps odd cases through its `bespoke`
dict (`scikit-learn` → `sklearn`, and similar). A package whose import name
differs from its conda name needs an entry there or the check will fail.

**Step 5. Report the resolved package counts** and, for anything flagged, why.

## What a solve does not cover

`make build` and `make test` are the real gate, and they need Docker on the
target architecture. As of this writing no remediation session on this repo has
had Docker, and `make test` has not been run on either arch since the audit
began — see FABLE_AUDIT.md, "Outstanding validation debt". Say plainly what you
ran and what you did not. Never describe a spec change as verified because it
solved; a solve proves resolution, not that R libraries compile and load.
