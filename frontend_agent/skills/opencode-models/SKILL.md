---
name: opencode-models
description: This skill should be used when the user asks to "add a model to opencode", "remove a model from opencode.json", "add an Ollama model to opencode", "add a vLLM/llama.cpp model to opencode", "check the ollama list and add <model>", "change opencode's default model", "create a bigger context version of a model", or otherwise wants to edit frontend_agent/opencode.json's provider/model wiring, resolve a loose model name against the live Ollama tag list or the OpenAI-compatible endpoint's model list, or make a longer-context variant of an existing Ollama model. Two providers exist — `ollama` (OLLAMA_HOST) and `openai` (OPENAI_HOST, any OpenAI-compatible server such as vLLM or llama.cpp) — so adding a model first requires establishing which provider/API it's served from.
---

# opencode Model Management

Edits to `frontend_agent/opencode.json`, the baked opencode config for the
`gds_agent` image. It declares two providers — `ollama` and `openai` (both
via `@ai-sdk/openai-compatible`, since Ollama also exposes an
OpenAI-compatible endpoint) — the models the agent may pick from under each,
and the default model. See `frontend_agent/SPEC.md` for how the file gets
mounted and where it lives at runtime (`~/.config/opencode/opencode.json` in
the container, mounted read-only from this file by `gdsa opencode`).

## File shape

```json
{
  "model": "ollama/<default-tag>",
  "provider": {
    "ollama": {
      "models": {
        "<tag>": { "name": "<tag>", "tool_call": true }
      }
    },
    "openai": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "OpenAI Compatible",
      "options": {
        "baseURL": "http://{env:OPENAI_HOST}/v1"
      },
      "models": {
        "<tag>": { "name": "<tag>", "tool_call": true }
      }
    }
  }
}
```

- Each key under `provider.ollama.models` / `provider.openai.models` is the
  exact model tag/id as that backend serves it (everything after
  `ollama/`/`openai/` in the top-level `model` field, e.g.
  `gemma4:12b-it-qat-128k` for Ollama, `bonsai-27b` for the OpenAI-compatible
  endpoint). The `name` field must repeat that same tag/id.
- `tool_call: true` marks the model as capable of tool use — every model
  in the file currently sets this; keep it unless there is a reason not to.
- The top-level `model` field is the default on launch, written as
  `<provider>/<tag>` (`ollama/<tag>` or `openai/<tag>`). It must reference
  an entry that also exists under that provider's `models` map.
- The `models` maps only tell opencode what tags/ids it may request — they
  do not create models on either backend. An Ollama tag must already exist
  on the server `OLLAMA_HOST` points to (`ollama list` there to check); an
  `openai`-provider id must already be served by whatever `OPENAI_HOST`
  points to (vLLM, llama.cpp, etc. — check that server's own model list)
  before it's added here.
- Only edit `provider.ollama.models`, `provider.openai.models`, and `model`.
  Leave `lsp`, the `openai` provider's `npm`/`name`/`options` block, and
  other top-level keys untouched unless the task specifically calls for it
  — adding a third provider from scratch is a bigger, one-off structural
  change, not a routine model add/remove, and isn't covered by this skill.
- The file also carries `$schema: "https://opencode.ai/config.json"`. If a
  per-model field is needed beyond `name`/`tool_call` (e.g. reasoning,
  temperature), check that schema rather than guessing — this skill only
  documents the fields already in use in this repo.

## Resolve provider hosts

Needed to query either backend's live model list. Both hosts are resolved
independently of each other, the same way `gdsa`'s `_cmd_opencode` does
(`utils/gdsa`):

**`OLLAMA_HOST`** (for the `ollama` provider):

1. The `OLLAMA_HOST` env var, if set — bare `host:port`, no scheme.
2. Otherwise, read `utils/provider-url.txt` (next to `gdsa`, gitignored,
   not always present).
3. If neither is available, ask the user for the Ollama endpoint rather
   than guessing.

**`OPENAI_HOST`** (for the `openai` provider — any OpenAI-compatible
server, e.g. vLLM or llama.cpp; may be a different machine than Ollama's):

1. The `OPENAI_HOST` env var, if set — bare `host:port`, no scheme.
2. Otherwise, read `utils/openai-provider-url.txt` (next to `gdsa`,
   gitignored, not always present).
3. If neither is available and the task needs it (e.g. adding a model to
   the `openai` provider), ask the user for the endpoint rather than
   guessing. Unlike Ollama, it's normal for this to be entirely unset —
   the `openai` provider is optional at runtime.

## Determine which provider a model belongs to

There are two independent backends, so adding a model always starts by
establishing which one serves it — do not default to `ollama` just because
it was the original/only provider.

- If the user names the provider or backend explicitly ("add a vLLM
  model", "this is served through llama.cpp", "add it to the openai
  provider"), use that.
- If the user gives a tag/name with no provider stated:
  - If only one of `OLLAMA_HOST` / `OPENAI_HOST` resolves (see above), use
    that provider — there's nothing to disambiguate.
  - If both resolve, query both live catalogs (see "Add a model" below)
    and match the name against each. A match in exactly one catalog
    settles it. A match in both, or in neither, means stop and ask the
    user which provider they mean — don't guess.
- A model's name, family, or license is not a reliable signal by itself —
  the same weights can in principle be served by either backend. The live
  catalog match is the source of truth for which provider/API a model is
  reachable through, not its name.

## Add a model

Handles both an exact tag/id (e.g. "add `gemma4:12b-it-qat-128k`" or "add
`bonsai-27b` to the openai provider") and a loose/partial name (e.g. "add
muse glimmer") that needs resolving against what's actually live.

1. Determine the target provider (see above) and resolve its host.
2. Query the live catalog for that provider:
   - **`ollama`**: `curl -s "http://<OLLAMA_HOST>/api/tags"` returns JSON
     with a `models` array of `{name, ...}`. Extract the names, e.g.
     `python3 -c "import json,sys; print('\n'.join(m['name'] for m in json.load(sys.stdin)['models']))"`
     (use `jq -r '.models[].name'` instead if `jq` is available).
   - **`openai`**: `curl -s "http://<OPENAI_HOST>/v1/models"` returns JSON
     with a `data` array of `{id, ...}`. Extract the ids, e.g.
     `python3 -c "import json,sys; print('\n'.join(m['id'] for m in json.load(sys.stdin)['data']))"`
     (use `jq -r '.data[].id'` instead if `jq` is available).
3. If given a loose name, match it against that list case-insensitively,
   ignoring `-`, `_`, `:`, and spaces (so "muse glimmer" matches
   `muse-glimmer:30b-mlx`).
   - **Exactly one match** — use it, no need to check in with the user,
     proceed to step 4.
   - **More than one match** — stop and ask the user which tag(s)/id(s)
     they mean before touching the file. List the candidates.
   - **No match** — tell the user nothing on that host matches; don't
     invent or guess a tag/id.
4. Add an entry to `provider.<provider>.models` keyed by the exact resolved
   tag/id, with `name` matching the key and `tool_call: true`.
5. Only change the top-level `model` field if the user wants this new
   entry to become the default — write it as `<provider>/<tag>`.
6. Validate the JSON (see Validate below).

## Remove a model

1. Delete its entry from `provider.ollama.models` or
   `provider.openai.models`, whichever it's under.
2. If the removed entry was also the top-level `model` default, pick a
   replacement from what's left (in either provider's map) and update
   `model` — don't leave the default pointing at an entry no longer
   declared.
3. Removing the entry does not delete the model on its backend; that's a
   separate, out-of-scope step on that server — `ollama rm <tag>` for
   Ollama, or whatever the equivalent unload/removal step is for the
   `openai` provider's server (vLLM, llama.cpp, etc.) — and should only
   happen if the user explicitly asks for it.
4. Validate the JSON (see Validate below).

## Create a context-window variant

This workflow is specific to the `ollama` provider. opencode/Ollama's
OpenAI-compatible endpoint does not take context length as a per-request
option — context window (`num_ctx`) is baked into the Ollama model itself.
A "bigger context version" of a model is therefore a **new Ollama model
tag**, created on the Ollama host, then registered in `opencode.json` like
any other model. This repo already follows this pattern: `gemma4:12b-it-qat`
(default context) and `gemma4:12b-it-qat-128k` (128k context) are separate
tags built from the same base.

For the `openai` provider, context length is configured on that server
(vLLM, llama.cpp, etc.) at launch/config time, not per opencode model
entry — there's no Modelfile-style equivalent here. If asked for a
bigger-context `openai`-provider model, say so and ask how that server
exposes the option rather than inventing an opencode-side workaround.

This is a two-part workflow: part 1 runs on the **Ollama host** (wherever
`OLLAMA_HOST` points — frontend_agent only talks to it over HTTP, it does
not run Ollama itself, so these commands are not run inside this repo's
containers). Part 2 is the usual `opencode.json` edit in this repo.

**Part 1 — on the Ollama host:**

1. Write a Modelfile:
   ```
   FROM <base-tag>
   PARAMETER num_ctx <n>
   ```
   `<n>` is context length in tokens, e.g. `65536` for 64k, `131072` for
   128k, `32768` for 32k.
2. Create the new tag from it:
   ```
   ollama create <new-tag> -f Modelfile
   ```
   Name `<new-tag>` by appending the context size to the base tag,
   matching the existing convention: `gemma4:12b-it-qat` →
   `gemma4:12b-it-qat-128k`.
3. Confirm it exists: `ollama list` or `ollama show <new-tag>`.

**Part 2 — in this repo:** add `<new-tag>` to `opencode.json` following
"Add a model" above.

## Validate

After any edit, confirm the file is still valid JSON before considering
the task done:

```bash
python3 -m json.tool frontend_agent/opencode.json > /dev/null
```

Also sanity-check that `model` and every `provider.ollama.models` /
`provider.openai.models` key agree with each other — the default must be
`<provider>/<tag>` for an entry that actually exists under that same
provider — and that FABLE_AUDIT.md's known SPEC/opencode.json drift note
(SPEC.md lists a stale model list) isn't being treated as the source of
truth — `opencode.json` itself is authoritative for what's actually
shipped.
