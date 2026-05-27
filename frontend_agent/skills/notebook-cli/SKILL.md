---
name: notebook-cli
description: ALWAYS use the `nb` CLI for ALL Jupyter notebook operations instead of built-in tools (Read, NotebookEdit, etc). This includes reading, creating, editing cells, executing, and searching notebooks. Outputs AI-Optimized Markdown format by default with line-oriented sentinels (@@notebook, @@cell, @@output) and JSON metadata for deterministic parsing. Supports both local file-based and remote real-time collaboration modes. REQUIRED for all .ipynb files in this project.
---

# Working with Jupyter Notebooks using nb

**IMPORTANT**: Use the custom `nb` tool for ALL notebook operations instead of built-in tools like Read or NotebookEdit. This includes reading notebooks.

## AI-Optimized Markdown Format

The default output format uses line-oriented sentinels with JSON metadata for reliable parsing:

- `@@notebook {json}` - Notebook header with format and metadata
- `@@cell {json}` - Cell header with index, id, cell_type, execution_count, metadata
- `@@output {json}` - Output header with output_type, mime, name, path (for externalized outputs)

Content includes:
- Code cells: wrapped in fenced code blocks with language
- Markdown cells: raw markdown text
- Outputs: wrapped in fenced code blocks or externalized to files (>4000 chars by default)

Use `--limit` to control externalization threshold and `--output-dir` for externalized file location.

## Quick Reference (Most Common Commands)

```bash
# ALWAYS check --help first if unsure: nb --help, nb cell --help, nb execute --help

# Read entire notebook - this returns AI friendly markdown
nb read notebook.ipynb

# Read specific cell (use --cell-index or -i for index, --cell or -c for ID)
nb read notebook.ipynb --cell-index 2
nb read notebook.ipynb -i -1  # last cell

# Execute entire notebook
nb execute notebook.ipynb

# Update cell (use --cell-index or -i for index)
nb cell update notebook.ipynb --cell-index 2 --source "new code"

# Add cell
nb cell add notebook.ipynb --source "print('hello')"

# Add multiple cells (start with a sentinel: @@code, @@markdown, @@raw,
# or @@cell {"cell_type":"..."})
nb cell add notebook.ipynb -s '@@code
import pandas as pd
@@code
df = pd.read_csv("data.csv")'
```

## Running Python in the Correct Environment

When connected to a Jupyter server (via `nb connect`), the server may be running in a specific Python environment (e.g., uv, pixi). To run Python scripts or commands outside the notebook in the same environment as the Jupyter kernel, use `nb status --python` to get the command prefix:

```bash
# Get the Python command prefix
nb status --python
# Outputs: "uv run" or "pixi run" or "" (empty for direct/system Python)

# Use it to run Python scripts in the correct environment
$(nb status --python) python script.py

# This automatically expands to the correct command:
# - uv run python script.py     (for uv environments)
# - pixi run python script.py   (for pixi environments)
# - python script.py            (for direct/system Python)

# Examples:
$(nb status --python) python -c "import numpy; print(numpy.__version__)"
$(nb status --python) pip list
```

This ensures that any Python code you run has access to the same packages and environment as the Jupyter kernel.

## Create Notebook

```bash
# Create notebook with single empty code cell (default)
nb create notebook.ipynb

# Create notebook with single empty markdown cell
nb create notebook.ipynb --markdown

# Create with specific kernel
nb create notebook.ipynb --kernel python3

# Force overwrite if exists
nb create notebook.ipynb --force

# Output as JSON instead of text (default is text)
nb create notebook.ipynb --json
```

## Read Notebook

Use `nb read notebook.ipynb` in the default output mode for normal notebook reading tasks.

The default output is the preferred agent format:

- Markdown notebook content
- Sentinel lines starting with `@@notebook`, `@@cell`, and `@@output`
- JSON metadata on those sentinel lines for deterministic parsing

This default format should be used for summarization, review, inspection, and understanding notebook
structure and outputs.

While `nb read --json` is available, only use this when you absolutely need the notebook as JSON. Do not use `--json` merely to make parsing easier.

```bash
# Read entire notebook (outputs included by default)
nb read notebook.ipynb

# Read specific cell by index
nb read notebook.ipynb --cell-index 0
nb read notebook.ipynb -i -1  # Last cell

# Read specific cell by ID
nb read notebook.ipynb --cell "abc123"
nb read notebook.ipynb -c "abc123"

# Exclude outputs when you don't need them
nb read notebook.ipynb --no-output
nb read notebook.ipynb -i 0 --no-output

# Control output externalization (default: 4000 chars)
nb read notebook.ipynb --limit 8000
nb read notebook.ipynb --output-dir ./outputs

# Filter by cell type
nb read notebook.ipynb --only-code
nb read notebook.ipynb --only-markdown

# Output as JSON (nbformat-compliant)
nb read notebook.ipynb --json
```

## Read Cell

```bash
# Read specific cell by index (outputs included by default)
nb read notebook.ipynb --cell-index 0
nb read notebook.ipynb -i 2
nb read notebook.ipynb -i -1  # Last cell

# Read specific cell by ID (more stable)
nb read notebook.ipynb --cell "unique-cell-id"
nb read notebook.ipynb -c "unique-cell-id"

# Exclude outputs if not needed
nb read notebook.ipynb -i 0 --no-output
```

## Add Cell

```bash
# Add code cell at end
nb cell add notebook.ipynb --source "print('Hello')"

# Add markdown cell
nb cell add notebook.ipynb --type markdown --source "# Title"

# Add at specific position
nb cell add notebook.ipynb --source "import pandas" --insert-at 0
nb cell add notebook.ipynb -s "code" -i 2

# Add after/before specific cell
nb cell add notebook.ipynb --source "code" --after "cell-id-123"
nb cell add notebook.ipynb --source "code" --before "cell-id-456"

# Add with custom ID
nb cell add notebook.ipynb --source "code" --id "my-custom-id"

# Read from stdin
echo "print('Hello')" | nb cell add notebook.ipynb --source -
```

### Adding Multiple Cells

Start the `--source` string with a sentinel line to add multiple cells in a single call. Multi-cell mode is activated only when the **first non-empty line** is a sentinel; otherwise the entire source is treated as a single cell. This means `@@code`/`@@markdown`/`@@raw` appearing inside cell content (e.g., in documentation) is treated as literal text — no data loss.

Two sentinel formats are supported:

- **Shorthand**: `@@code`, `@@markdown`, `@@raw`
- **Full format** (matches `nb read` output): `@@cell {"cell_type": "code"}` — may include a `"metadata"` object that is loaded into the cell

```bash
# Add multiple code cells (shorthand)
nb cell add notebook.ipynb -s '@@code
x = 1
@@code
y = 2
@@code
print(x + y)'

# Mix cell types
nb cell add notebook.ipynb -s '@@markdown
# Analysis
@@code
import pandas as pd
df = pd.read_csv("data.csv")
@@markdown
## Results
@@code
df.describe()'

# Full @@cell format with metadata
nb cell add notebook.ipynb -s '@@cell {"cell_type": "code", "metadata": {"tags": ["setup"]}}
import pandas as pd
@@cell {"cell_type": "markdown"}
# Analysis'

# Insert multiple cells at a position
nb cell add notebook.ipynb -s '@@code
import numpy as np
@@code
data = np.random.rand(100)' --insert-at 0

# Insert multiple cells after a specific cell
nb cell add notebook.ipynb -s '@@code
step_1()
@@code
step_2()' --after "cell-id-123"

# Via stdin
cat <<'EOF' | nb cell add notebook.ipynb -s -
@@markdown
# Setup
@@code
import pandas as pd
@@code
df = pd.read_csv("data.csv")
EOF
```

When sentinels are present, the `--type` flag is ignored (each sentinel specifies its own type). The `--id` flag cannot be used with multiple cells. Leading and trailing blank lines are stripped from each cell.

When no sentinels are present (first non-empty line is not a sentinel), the source is treated as a single cell using `--type` (backward compatible).

## Update Cell

```bash
# Update cell by index
nb cell update notebook.ipynb --cell-index 0 --source "new code"
nb cell update notebook.ipynb -i -1 -s "updated last cell"

# Update cell by ID
nb cell update notebook.ipynb --cell "abc123" --source "new code"
nb cell update notebook.ipynb -c "abc123" --source "new code"

# Append to existing content
nb cell update notebook.ipynb -i 0 --append "\nprint('more code')"

# Change cell type
nb cell update notebook.ipynb -i 0 --type markdown

# Read from stdin
echo "new content" | nb cell update notebook.ipynb -i 0 --source -
```

## Delete Cell

```bash
# Delete by index
nb cell delete notebook.ipynb --cell-index 0
nb cell delete notebook.ipynb -i -1  # Last cell

# Delete by cell ID
nb cell delete notebook.ipynb --cell "abc123"
nb cell delete notebook.ipynb -c "abc123"

# Delete range (exclusive end)
nb cell delete notebook.ipynb --range 0:3  # Deletes cells 0, 1, 2

# Delete multiple cells by index
nb cell delete notebook.ipynb -i 0 -i 2 -i 5
```

## Execute Notebook

```bash
# Execute entire notebook
nb execute notebook.ipynb

# Execute with specific kernel
nb execute notebook.ipynb --kernel python3

# Execute with custom timeout per cell
nb execute notebook.ipynb --timeout 60

# Continue on errors
nb execute notebook.ipynb --allow-errors

# Execute cell range
nb execute notebook.ipynb --start 0 --end 5

# Execute with remote server
nb execute notebook.ipynb --server http://localhost:8888 --token "token123"

# Output as JSON (default is text)
nb execute notebook.ipynb --json
```

## Execute Cell

```bash
# Execute cell by index
nb execute notebook.ipynb --cell-index 0
nb execute notebook.ipynb -i -1  # Last cell

# Execute cell by ID
nb execute notebook.ipynb --cell "abc123"
nb execute notebook.ipynb -c "abc123"

# Execute with specific kernel
nb execute notebook.ipynb -i 0 --kernel python3

# Execute with custom timeout
nb execute notebook.ipynb -i 0 --timeout 60

# Continue on errors
nb execute notebook.ipynb -i 0 --allow-errors

# Execute with remote server
nb execute notebook.ipynb -i 0 --server http://localhost:8888 --token "token123"
```

## Clear Outputs

```bash
# Clear all outputs (default behavior)
nb output clear notebook.ipynb

# Clear specific cell by index
nb output clear notebook.ipynb --cell-index 0
nb output clear notebook.ipynb -i -1  # Last cell

# Clear specific cell by ID
nb output clear notebook.ipynb --cell "abc123"
nb output clear notebook.ipynb -c "abc123"

# Preserve execution count when clearing
nb output clear notebook.ipynb --keep-execution-count
```

## Search Notebook

```bash
# Search in source code (default)
nb search notebook.ipynb "pattern"

# Search in outputs
nb search notebook.ipynb "pattern" --scope output

# Search in both source and outputs
nb search notebook.ipynb "pattern" --scope all

# Case-insensitive search
nb search notebook.ipynb "pattern" --ignore-case

# Filter by cell type
nb search notebook.ipynb "pattern" --cell-type code
nb search notebook.ipynb "pattern" --cell-type markdown

# Find cells with errors
nb search notebook.ipynb --with-errors

# Return only cell IDs/indices
nb search notebook.ipynb "pattern" --list-only
```

## Cell Referencing

- **By index**: `--cell-index N` or `-i N` (0-based, supports negative like `-1` for last)
- **By ID**: `--cell "id"` or `-c "id"` (stable, doesn't change when cells move)

## Output Format

All commands default to AI-Optimized Markdown format for reliable parsing by AI agents:

- **Default**: AI-Optimized Markdown with line-oriented sentinels (@@notebook, @@cell, @@output)
  - Uses JSON metadata for deterministic parsing
  - Cell index field for reliable positional references
  - Content-based hashing (SHA256) for externalized outputs
  - Absolute paths for all externalized files
  - nbformat v4.5 compliant property names

- **JSON** (`--json`): nbformat-compliant JSON for programmatic use

## Output Externalization

Large outputs (>4000 chars by default) are automatically externalized to separate files:

```bash
# Control externalization threshold (default: 4000)
nb read notebook.ipynb --limit 8000

# Specify output directory for externalized files
nb read notebook.ipynb --output-dir ./notebook-outputs

# Exclude all outputs if not needed
nb read notebook.ipynb --no-output
```

Externalized files use content-based SHA256 hashing for filenames:
- Prevents AI agents from guessing filenames
- Same content always maps to same file (automatic deduplication)
- Returns absolute paths in `@@output` headers
