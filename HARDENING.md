<!-- markdownlint-disable -->

# Hardening Report: rlespinasse--slugify-value/v1.4.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **rlespinasse--slugify-value/v1.4.0** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

slugify.sh writes user-controlled values to $GITHUB_OUTPUT and $GITHUB_ENV without sanitization. The variables CS_VALUE, SLUG_VALUE, SLUG_CS_VALUE, SLUG_URL_VALUE, and SLUG_URL_CS_VALUE are all derived from INPUT_VALUE and INPUT_KEY (which come from inputs.value and inputs.key via the action's env: block). An attacker can embed newline characters in these inputs to inject arbitrary key=value pairs into the runner's environment or output context. No `printf '%s' ... | tr -d '\n\r'` sanitization is applied before any of these writes.

Locations:

- `slugify.sh:48`
- `slugify.sh:62`

### script-injection (severity: high)

Multiple run: blocks in the workflow directly interpolate ${{ env.* }}, ${{ steps.*.outputs.* }}, and ${{ steps.*.outcome }} expressions inside shell commands (e.g., `[[ "${{ env.KEY_ONLY }}" == ... ]]`). These expressions are substituted by the GitHub Actions YAML template engine before the shell parses the command, allowing any workflow-controllable value to inject shell metacharacters. All validate steps across Tests 1–8 are affected.

Locations:

- `.github/workflows/slugify-value.yaml:24`
- `.github/workflows/slugify-value.yaml:37`
- `.github/workflows/slugify-value.yaml:51`
- `.github/workflows/slugify-value.yaml:64`
- `.github/workflows/slugify-value.yaml:78`
- `.github/workflows/slugify-value.yaml:96`
- `.github/workflows/slugify-value.yaml:113`
- `.github/workflows/slugify-value.yaml:130`

### missing-permissions (severity: medium)

The workflow file .github/workflows/slugify-value.yaml has no top-level permissions: key, and neither the os-testing job nor the release job defines a job-level permissions: block. This means the workflow runs with the default (potentially broad) GITHUB_TOKEN permissions.

Locations:

- `.github/workflows/slugify-value.yaml:1`

### unpinned-uses (severity: high)

The workflow uses action references pinned to mutable tags rather than immutable full-length SHA digests, making the workflow vulnerable to supply-chain attacks if the tag is moved: `actions/checkout@v3` (used twice) and `rlespinasse/release-that@v1`.

Locations:

- `.github/workflows/slugify-value.yaml:15`
- `.github/workflows/slugify-value.yaml:136`
- `.github/workflows/slugify-value.yaml:139`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection, script-injection, missing-permissions, unpinned-uses

**Notes:**

Fixed all four findings:

1. **github-env-injection** (slugify.sh lines 48, 62): Added `printf '%s' "$VAR" | tr -d '\n\r'` sanitization for all user-controlled values (CS_VALUE, SLUG_VALUE, SLUG_CS_VALUE, SLUG_URL_VALUE, SLUG_URL_CS_VALUE, PREFIX, KEY) before writing to $GITHUB_OUTPUT and $GITHUB_ENV. Safe versions stored in SAFE_* variables.

2. **script-injection** (.github/workflows/slugify-value.yaml, 8 locations): Moved all `${{ env.* }}`, `${{ steps.*.outputs.* }}`, and `${{ steps.*.outcome/conclusion }}` expressions from `run:` shell scripts into `env:` blocks for each validate step. Shell scripts now reference plain environment variables.

3. **missing-permissions** (.github/workflows/slugify-value.yaml line 1): Added `permissions: {}` at the top level, `permissions: contents: read` for the os-testing job, and `permissions: contents: write` for the release job.

4. **unpinned-uses** (.github/workflows/slugify-value.yaml lines 15, 136, 139): Pinned `actions/checkout@v3` → `@a37ce9120846195fa4ece8f58b268e6043cb2f26 # v3` (both occurrences) and `rlespinasse/release-that@v1` → `@f4912d4053839003bb368e9c7067b071ccb1c146 # v1`.

