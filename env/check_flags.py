#!/usr/bin/env python3
"""Re-check the architecture flags in env/gds.yml against conda-forge.

Every flag in env/gds.yml records a package conda-forge could not build for
some architecture, and the date that was last confirmed:

    - r-duckdb  # !arm64: no linux-aarch64 build (checked 2026-08-20)

Coverage improves over time -- audit 2.5 found 48 of 56 long-standing arm64
exclusions had become available -- so a flag is a claim with an expiry date,
not a fact. This script asks conda-forge which of those claims still hold and
prints a report.

It is a *screening* step, not a verdict. Audit 2.5 restored 48 packages that
the index said were available and a solve then rejected four of them, because
their dependencies had no aarch64 build. Package-level availability is
necessary, not sufficient: only a solve of the whole spec decides. See
`make env-specs` and the solve commands this script prints.

Usage:
    make check-flags
    python3 env/check_flags.py --source env/gds.yml
"""

import argparse
import datetime as dt
import json
import sys
import urllib.error
import urllib.request

from generate_spec import FLAG, strip_header

API = "https://api.anaconda.org/package/conda-forge/%s"

# Flag arch names are the repo's (they match the image tags and BUILDARCH);
# conda calls the same platforms something else.
SUBDIR = {
    "amd64": "linux-64",
    "arm64": "linux-aarch64",
    "osx-arm64": "osx-arm64",
    "osx-64": "osx-64",
}

# "dep r-leafpop has no linux-aarch64 build (checked ...)" -- when a flag
# blames a dependency, that package is what has to gain a build, so check it
# instead of (well, as well as) the flagged one.
DEP_MARKER = "dep "


def subdirs_for(name, cache):
    """Return the set of conda-forge subdirs publishing `name`, or None on error."""
    if name in cache:
        return cache[name]
    try:
        with urllib.request.urlopen(API % name, timeout=30) as fo:
            data = json.load(fo)
    except urllib.error.HTTPError as exc:
        cache[name] = set() if exc.code == 404 else None
        return cache[name]
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError):
        cache[name] = None
        return cache[name]
    cache[name] = {f.get("attrs", {}).get("subdir") for f in data.get("files", [])}
    return cache[name]


def available(subs, subdir):
    """conda-forge serves a package to `subdir` if it builds there or is noarch."""
    return bool(subs) and (subdir in subs or "noarch" in subs)


def blocking_dep(reason):
    """The dependency a flag blames, if it blames one."""
    if not reason.startswith(DEP_MARKER):
        return None
    return reason[len(DEP_MARKER):].split()[0]


def parse_flags(lines):
    for line in strip_header(lines):
        m = FLAG.match(line)
        if not m:
            continue
        pkg = m.group("entry").split("-", 1)[1].strip()
        arches = [a.strip().lstrip("!") for a in m.group("arches").split(",")]
        reason = m.group("reason").strip()
        date = None
        if "(checked " in reason:
            date = reason.rsplit("(checked ", 1)[1].rstrip(")").strip()
        yield pkg, arches, reason, date


def main(argv=None):
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--source", default="env/gds.yml")
    ap.add_argument("--exit-code", action="store_true",
                    help="exit 1 if any flag looks liftable (for scheduled checks)")
    args = ap.parse_args(argv)

    with open(args.source, encoding="utf-8") as fo:
        lines = fo.read().split("\n")

    flags = list(parse_flags(lines))
    if not flags:
        print("No architecture flags in %s -- nothing to re-check." % args.source)
        return 0

    today = dt.date.today()
    cache, candidates, unknown = {}, [], []

    print("Re-checking %d flag(s) in %s against conda-forge.\n" % (len(flags), args.source))
    for pkg, arches, reason, date in flags:
        age = ""
        if date:
            try:
                age = "  [checked %s, %d days ago]" % (
                    date, (today - dt.date.fromisoformat(date)).days)
            except ValueError:
                age = "  [checked %s]" % date

        for arch in arches:
            subdir = SUBDIR.get(arch)
            if subdir is None:
                print("  ? %-16s !%s -- unknown arch, no conda subdir mapping" % (pkg, arch))
                unknown.append(pkg)
                continue

            dep = blocking_dep(reason)
            target = dep or pkg
            subs = subdirs_for(target, cache)

            if subs is None:
                print("  ? %-16s !%s -- could not reach conda-forge for %s"
                      % (pkg, arch, target))
                unknown.append(pkg)
            elif available(subs, subdir):
                if dep:
                    print("  + %-16s !%s -- blocking dep %s NOW has a %s build%s"
                          % (pkg, arch, dep, subdir, age))
                else:
                    print("  + %-16s !%s -- NOW has a %s build%s" % (pkg, arch, subdir, age))
                candidates.append((pkg, arch))
            else:
                what = "dep %s" % dep if dep else "package"
                print("  . %-16s !%s -- still no %s build (%s)%s"
                      % (pkg, arch, subdir, what, age))

    print("\n%d flag(s) checked, %d candidate(s) to lift, %d inconclusive."
          % (len(flags), len(candidates), len(unknown)))

    if candidates:
        print("""
Candidates are NOT a green light. Availability is necessary, not sufficient --
audit 2.5 had four of these rejected by the solve because their own
dependencies had no aarch64 build. To act on them:

  1. Remove the flag comment from each candidate in %s
     (keep the entry; you are only dropping the `# !arch:` part).
  2. Regenerate and solve the affected arch, e.g. for arm64:
       make env-specs ARCH=arm64
       mamba env create -n _check --dry-run --platform linux-aarch64 \\
         -f env/gds_arm64.yml
  3. Re-flag anything the solve rejects, naming the blocking dependency and
     today's date in the reason.
  4. Update the "Last full re-check" line in the %s header.
""" % (args.source, args.source))
    else:
        print("\nNo flags look liftable. Bump the dates in %s if you want to record\n"
              "that this ran." % args.source)

    return 1 if (args.exit_code and candidates) else 0


if __name__ == "__main__":
    sys.exit(main())
