#!/usr/bin/env python3
"""Generate a per-architecture conda spec from env/gds.yml (audit 3.1).

env/gds.yml is the single source of truth for both architectures. Packages
unavailable somewhere stay live entries carrying an architecture flag:

    - r-duckdb   # !arm64: no linux-aarch64 build (checked 2026-08-20)

This script emits the spec for one architecture: flagged lines are dropped
for the arch they exclude, and the flag comment is stripped everywhere else,
so the output is a plain package list that conda reads and that
env/py/check_py_stack.ipynb can parse.

The transform is purely subtractive -- it never adds or reorders a package,
which is what makes it cheap to convince yourself the output is right.

Generated specs are gitignored and must not be committed; `make build` and
`make test` produce them on demand.
"""

import argparse
import re
import sys

# "  - pkg  # !arch[,!arch]: reason". Only a flag directly after the entry
# counts; a bare "# comment" is left alone.
FLAG = re.compile(
    r"""^(?P<entry>\s*-\s*\S+?)      # the package entry
         \s+\#\s*                    # start of its trailing comment
         (?P<arches>!\S+(?:,\s*!\S+)*)  # !arm64  or  !arm64, !osx-arm64
         \s*:\s*(?P<reason>.*)$      # the reason
      """,
    re.VERBOSE,
)

HEADER = """\
# GENERATED FILE -- DO NOT EDIT, DO NOT COMMIT.
#
# Written by env/generate_spec.py from env/gds.yml, for {arch}.
# Edit env/gds.yml and re-run `make env-specs`.
"""


def strip_header(lines):
    """Drop the source file's own leading comment block.

    It documents the flag syntax and says "do not commit" -- guidance for
    whoever edits gds.yml, and actively misleading inside a generated
    artifact, which gets its own header instead.
    """
    for i, line in enumerate(lines):
        if line.strip() and not line.lstrip().startswith("#"):
            return lines[i:]
    return []


def generate(lines, arch):
    """Return the spec for `arch`, plus the list of packages excluded from it."""
    out, excluded = [], []
    for line in strip_header(lines):
        m = FLAG.match(line)
        if not m:
            out.append(line)
            continue
        arches = [a.strip().lstrip("!") for a in m.group("arches").split(",")]
        pkg = m.group("entry").split("-", 1)[1].strip()
        if arch in arches:
            excluded.append((pkg, m.group("reason").strip()))
        else:
            # Available here: keep the entry, drop the flag.
            out.append(m.group("entry"))
    return out, excluded


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--arch", required=True,
                    help="target architecture, e.g. amd64 or arm64")
    ap.add_argument("--source", default="env/gds.yml", help="source spec")
    ap.add_argument("--out", help="output path (default: stdout)")
    ap.add_argument("--quiet", action="store_true",
                    help="do not report the exclusions on stderr")
    args = ap.parse_args(argv)

    with open(args.source, encoding="utf-8") as fo:
        lines = fo.read().split("\n")

    body, excluded = generate(lines, args.arch)
    text = HEADER.format(arch=args.arch) + "\n".join(body)

    if args.out:
        with open(args.out, "w", encoding="utf-8") as fo:
            fo.write(text)
    else:
        sys.stdout.write(text)

    if not args.quiet:
        where = args.out or "stdout"
        print("%s: %d packages excluded on %s" % (where, len(excluded), args.arch),
              file=sys.stderr)
        for pkg, reason in excluded:
            print("  - %s (%s)" % (pkg, reason), file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
