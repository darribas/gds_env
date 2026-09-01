# `frontend_agent/skills/`

Single source of truth for skills authored in this repo (as opposed to
`notebook-cli`, which `frontend_agent/Dockerfile` fetches from upstream
`jupyter-ai-contrib/nb-cli` at build time — that one isn't vendored here).

Each subdirectory is a normal `SKILL.md` skill (YAML frontmatter with
`name`/`description`, then the instructions body) — the same format both
Claude Code and opencode read, confirmed by the baked `notebook-cli`
skill at `~/.config/opencode/skills/notebook-cli/SKILL.md` in the image.

## Why one copy

Content here should never be duplicated by hand elsewhere. Instead:

- **In this dev repo**, Claude Code discovers project skills via
  `.claude/skills/<name>/`. Those paths are symlinks into this directory
  (e.g. `.claude/skills/opencode-models -> ../../frontend_agent/skills/opencode-models`),
  so there's exactly one file on disk to edit.
- **In the built `gds_agent` image**, `frontend_agent/Dockerfile` `COPY`s
  each subdirectory here into `~/.config/opencode/skills/<name>/`, which
  is where opencode looks for skills at runtime. Skills also wired into
  `~/CLAUDE.md` (see below) get concatenated from this same file.

Not every skill here ships in the image. `env-packages` documents a
*maintainer* workflow on this checkout — it needs `env/gds.yml`, `mamba`
and conda-forge access, none of which mean anything inside the built
`gds_agent` image — so it is wired to the `.claude/skills` symlink only,
with no Dockerfile `COPY`. That is the per-skill choice described below,
not an oversight.

Editing the `SKILL.md` in this directory is enough to update it
everywhere it's wired — but wiring a *new* skill into each consumer is a
separate, explicit step (next section).

## Current wiring is per-skill, not automatic

Adding a directory here does not by itself make every harness pick it
up — someone has to wire it:

- opencode: add a `COPY skills/<name> /home/${NB_USER}/.config/opencode/skills/<name>`
  line in the Dockerfile's "baked opencode config" block. opencode reads
  a real, discoverable `skills/` directory, so this is triggered by the
  skill's `description`, same as it would be for Claude Code project
  skills.
- Claude Code, in this dev repo: add the `.claude/skills/<name>` symlink
  described above (also description-triggered — but note `.claude/` is
  gitignored in this repo, so this symlink is local-only and never ships
  in the image; it exists purely so this skill is usable while working
  in this checkout).
- Claude Code, *inside the built image*: there's no discoverable
  `skills/` dir wired up for it, so instead the Dockerfile's
  `notebook-cli skill` step concatenates this skill's body (frontmatter
  stripped) onto the single, always-loaded `~/CLAUDE.md`. That means it's
  loaded into every Claude Code session in the container regardless of
  what the user is doing — acceptable for a couple of small skills, but
  don't fold large or rarely-needed skills in this way without
  reconsidering.

## Adding a new skill

1. `mkdir -p frontend_agent/skills/<name>` and write `SKILL.md`.
2. `ln -s ../../frontend_agent/skills/<name> .claude/skills/<name>` for
   local Claude Code use in this repo.
3. Add the Dockerfile `COPY` line for opencode (see above) if it should
   ship in the image.
4. If it should also reach Claude Code inside the image, add another
   `awk ... >> /home/${NB_USER}/CLAUDE.md` line to the `notebook-cli
   skill` Dockerfile step (after the `COPY` from step 3, since it reads
   from the copied-in file) — mind the always-loaded cost noted above.
