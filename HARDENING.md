<!-- markdownlint-disable -->

# Hardening Report: rlespinasse--slugify-value/v1.4.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **rlespinasse--slugify-value/v1.4.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

slugify.sh writes values derived from untrusted inputs directly to $GITHUB_OUTPUT and $GITHUB_ENV without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). The env vars INPUT_VALUE, INPUT_KEY, and INPUT_PREFIX are set from `${{ inputs.value }}`, `${{ inputs.key }}`, and `${{ inputs.prefix }}` respectively in action.yml. In slugify.sh, CS_VALUE (from INPUT_VALUE), KEY (from INPUT_KEY), PREFIX (from INPUT_PREFIX), and their slugified derivatives are written unsanitized to $GITHUB_OUTPUT (e.g. `echo "value=${CS_VALUE}" >> "$GITHUB_OUTPUT"`) and to $GITHUB_ENV (e.g. `echo "${PREFIX}${KEY}=${CS_VALUE}" >> "$GITHUB_ENV"`). A newline character in any of these inputs could allow injection of arbitrary environment variables or output values.

Locations:

- `slugify.sh:57`
- `slugify.sh:58`
- `slugify.sh:59`
- `slugify.sh:60`
- `slugify.sh:61`
- `slugify.sh:70`
- `slugify.sh:71`
- `slugify.sh:72`
- `slugify.sh:73`
- `slugify.sh:74`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Added a `sanitize()` helper function in slugify.sh that strips newline and carriage return characters using `printf '%s' "$1" | tr -d '\n\r'`. Applied it to all values derived from user inputs (CS_VALUE, SLUG_VALUE, SLUG_CS_VALUE, SLUG_URL_VALUE, SLUG_URL_CS_VALUE, PREFIX, KEY) before writing to $GITHUB_OUTPUT and $GITHUB_ENV. The sanitized versions (SAFE_*) are used in all echo statements that write to these files, preventing newline injection attacks.

