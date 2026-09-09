<!-- markdownlint-disable -->

# Hardening Report: rlespinasse--slugify-value/v1.4.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **rlespinasse--slugify-value/v1.4.1** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

In slugify.sh, the variable CS_VALUE (derived from INPUT_VALUE, which is set from the caller-controlled input ${{ inputs.value }}) and the computed slug values are written directly to $GITHUB_OUTPUT (line 67) and $GITHUB_ENV (line 83) without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). An attacker can supply a value containing newline characters to inject arbitrary key=value pairs into the runner's environment or output context. The same applies to PREFIX and KEY (from inputs.prefix and inputs.key respectively) written to $GITHUB_ENV at line 78.

Locations:

- `slugify.sh:62`
- `slugify.sh:67`
- `slugify.sh:78`
- `slugify.sh:83`

### script-injection (severity: high)

Multiple run: blocks in slugify-value.yaml directly interpolate ${{ }} expressions inside shell command strings (sub-rule a). Specifically, ${{ env.KEY_ONLY }}, ${{ env.KEY_ONLY_SLUG }}, ${{ steps.slugify-key-only.outputs.value }}, ${{ steps.slugify-key-only.outputs.slug }}, and similar expressions from env.* and steps.*.outputs.* contexts are interpolated directly into [[ ... ]] test commands across all eight Validate run: blocks. These values flow through YAML template substitution before the shell sees them, enabling shell metacharacter injection if any value contains special characters. Example offending line: `[[ "${{ env.KEY_ONLY }}" == "refs/head/$-Key_Only.test--value-%-+" ]]`

Locations:

- `.github/workflows/slugify-value.yaml:33`
- `.github/workflows/slugify-value.yaml:55`
- `.github/workflows/slugify-value.yaml:75`
- `.github/workflows/slugify-value.yaml:95`
- `.github/workflows/slugify-value.yaml:115`
- `.github/workflows/slugify-value.yaml:135`
- `.github/workflows/slugify-value.yaml:155`
- `.github/workflows/slugify-value.yaml:175`

### unpinned-uses (severity: high)

Multiple workflow files reference actions using mutable tags or version strings instead of full 40-character SHA digests, making them vulnerable to supply-chain attacks if the tag is moved. Failing references: linter.yml — `actions/checkout@v7` and `super-linter/super-linter@v8`; slugify-value.yaml — `actions/checkout@v7` (appears twice) and `rlespinasse/release-that@v1`. The only pinned reference is `dependabot/fetch-metadata@25dd0e34f4fe68f24cc83900b1fe3fe149efef98` in dependabot-auto-merge.yml, which correctly uses a SHA.

Locations:

- `.github/workflows/linter.yml:14`
- `.github/workflows/linter.yml:21`
- `.github/workflows/slugify-value.yaml:21`
- `.github/workflows/slugify-value.yaml:196`
- `.github/workflows/slugify-value.yaml:200`

### broad-permissions (severity: medium)

The workflow file slugify-value.yaml sets a top-level `permissions: read-all`, which grants read access to all available scopes rather than declaring only the specific minimal permissions required. This should be replaced with an explicit list of only the permissions actually needed by each job.

Locations:

- `.github/workflows/slugify-value.yaml:8`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection, script-injection, unpinned-uses, broad-permissions

**Notes:**

Fixed all four findings:
1. slugify.sh: Added sanitize() function using printf+tr to strip newlines from all values before writing to $GITHUB_OUTPUT and $GITHUB_ENV (CS_VALUE, slug values, PREFIX, KEY).
2. slugify-value.yaml: Moved all ${{ env.* }} and ${{ steps.*.outputs.* }} expressions from run: shell strings into env: blocks on each of the 8 Validate steps; shell scripts now reference plain $VAR_NAME environment variables.
3. Pinned all unpinned actions to full commit SHAs: actions/checkout@v7→3d3c42e5..., super-linter/super-linter@v8→4ce20838..., rlespinasse/release-that@v1→f4912d40...
4. Replaced broad permissions: read-all in slugify-value.yaml with specific 'contents: read', and in linter.yml with 'permissions: {}' at top level (job-level permissions already specify the needed scopes).

