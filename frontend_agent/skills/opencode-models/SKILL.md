---
name: opencode-models
description: This skill should be used when the user asks to "add a model to opencode", "remove a model from opencode.json", "add an Ollama model to opencode", "check the ollama list and add <model>", "change opencode's default model", "create a bigger context version of a model", or otherwise wants to edit frontend_agent/opencode.json's provider/model wiring, resolve a loose model name against the live Ollama tag list, or make a longer-context variant of an existing Ollama model.
---

# opencode Model Management

Edits to `frontend_agent/opencode.json`, the baked opencode config for the
`gds_agent` image. It declares the Ollama provider (via
`@ai-sdk/openai-compatible`), the models the agent may pick from, and the
default model. See `frontend_agent/SPEC.md` for how the file gets mounted
and where it lives at runtime (`~/.config/opencode/opencode.json` in the
container, mounted read-only from this file by `gdsa opencode`).

## File shape

```json
{
  "model": "ollama/<default-tag>",
  "provider": {
    "ollama": {
      "models": {
        "<tag>": { "name": "<tag>", "tool_call": true }
      }
    }
  }
}
```

- Each key under `provider.ollama.models` is the exact Ollama tag name
  (everything after `ollama/`, e.g. `gemma4:12b-it-qat-128k`). The `name`
  field must repeat that same tag.
- `tool_call: true` marks the model as capable of tool use — every model
  in the file currently sets this; keep it unless there is a reason not to.
- The top-level `model` field is the default on launch, written as
  `ollama/<tag>`. It must reference a tag that also exists under
  `provider.ollama.models`.
- The `models` map only tells opencode what tags it may request — it does
  not create Ollama models. The tag must already exist on the Ollama
  server that `OLLAMA_HOST` points to (`ollama list` on that host to
  check) before it's added here.
- Only edit `provider.ollama.models` and `model`. Leave `lsp` and other
  top-level keys untouched unless the task specifically calls for it.
- The file also carries `$schema: "https://opencode.ai/config.json"`. If a
  per-model field is needed beyond `name`/`tool_call` (e.g. reasoning,
  temperature), check that schema rather than guessing — this skill only
  documents the fields already in use in this repo.

## Resolve `OLLAMA_HOST`

Needed to query the live model list. Resolve it the same way `gdsa`'s
`_cmd_opencode` does (`utils/gdsa`):

1. The `OLLAMA_HOST` env var, if set — bare `host:port`, no scheme.
2. Otherwise, read `utils/provider-url.txt` (next to `gdsa`, gitignored,
   not always present).
3. If neither is available, ask the user for the Ollama endpoint rather
   than guessing.

## Add a model

Handles both an exact tag (e.g. "add `gemma4:12b-it-qat-128k`") and a
loose/partial name (e.g. "add muse glimmer") that needs resolving against
what's actually on the Ollama host.

1. Resolve `OLLAMA_HOST` as above.
2. Query the live tag list: `curl -s "http://<OLLAMA_HOST>/api/tags"`
   returns JSON with a `models` array of `{name, ...}`. Extract the names,
   e.g. `python3 -c "import json,sys; print('\n'.join(m['name'] for m in json.load(sys.stdin)['models']))"`
   (use `jq -r '.models[].name'` instead if `jq` is available).
3. If given a loose name, match it against that list case-insensitively,
   ignoring `-`, `_`, `:`, and spaces (so "muse glimmer" matches
   `muse-glimmer:30b-mlx`).
   - **Exactly one match** — use it, no need to check in with the user,
     proceed to step 4.
   - **More than one match** — stop and ask the user which tag(s) they
     mean before touching the file. List the candidates.
   - **No match** — tell the user nothing on the host matches; don't
     invent or guess a tag name.
4. Add an entry to `provider.ollama.models` keyed by the exact resolved
   tag, with `name` matching the key and `tool_call: true`.
5. Only change the top-level `model` field if the user wants this new tag
   to become the default.
6. Validate the JSON (see Validate below).

## Remove a model

1. Delete its entry from `provider.ollama.models`.
2. If the removed tag was also the top-level `model` default, pick a
   replacement from what's left in the map and update `model` — don't
   leave the default pointing at a tag no longer declared.
3. Removing the entry does not delete the Ollama model itself; that's a
   separate, out-of-scope step on the Ollama host (`ollama rm <tag>`) and
   should only happen if the user explicitly asks for it.
4. Validate the JSON (see Validate below).

## Create a context-window variant

opencode/Ollama's OpenAI-compatible endpoint does not take context length
as a per-request option — context window (`num_ctx`) is baked into the
Ollama model itself. A "bigger context version" of a model is therefore a
**new Ollama model tag**, created on the Ollama host, then registered in
`opencode.json` like any other model. This repo already follows this
pattern: `gemma4:12b-it-qat` (default context) and
`gemma4:12b-it-qat-128k` (128k context) are separate tags built from the
same base.

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

Also sanity-check that `model` and every `provider.ollama.models` key
agree with each other, and that FABLE_AUDIT.md's known SPEC/opencode.json
drift note (SPEC.md lists a stale model list) isn't being treated as the
source of truth — `opencode.json` itself is authoritative for what's
actually shipped.
