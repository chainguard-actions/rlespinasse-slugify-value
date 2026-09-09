#!/usr/bin/env bash

if [[ "$OSTYPE" == "darwin"* ]]; then
  # On MacOS,
  # bash don't support substitution, so we use 'tr'
  KEY=$(echo "$INPUT_KEY" | tr '[:lower:]' '[:upper:]')
  CS_VALUE=${INPUT_VALUE:-${!INPUT_KEY}}
  VALUE=$(echo "$CS_VALUE" | tr '[:upper:]' '[:lower:]')
  PREFIX=$(echo "$INPUT_PREFIX" | tr '[:lower:]' '[:upper:]')
else
  KEY=${INPUT_KEY^^}
  CS_VALUE=${INPUT_VALUE:-${!INPUT_KEY}}
  VALUE=${CS_VALUE,,}
  PREFIX=${INPUT_PREFIX^^}
fi

MAX_LENGTH=""
if [ -z "${INPUT_SLUG_MAXLENGTH}" ]; then
  echo "::error ::slug-maxlength cannot be empty"
  exit 1
elif [ "${INPUT_SLUG_MAXLENGTH}" -eq "${INPUT_SLUG_MAXLENGTH}" ] 2>/dev/null; then
  MAX_LENGTH="${INPUT_SLUG_MAXLENGTH}"
elif [ "${INPUT_SLUG_MAXLENGTH}" == "nolimit" ]; then
  MAX_LENGTH="${INPUT_SLUG_MAXLENGTH}"
else
  echo "::error ::slug-maxlength must be a number or equals to 'nolimit'"
  exit 1
fi

slug() {
  # 1st : Remove refs prefix
  # 2d : Replace unwanted characters
  # 3d : Remove leading hypens
  output=$(sed -E 's#refs/[^\/]*/##;s/[^a-zA-Z0-9._-]+/-/g;s/^-*//' <<<"$1")
  reduce "$output"
}

slug_url() {
  # 1st : Remove refs prefix
  # 2d : Replace unwanted characters
  # 3d : Remove leading hypens
  output=$(sed -E 's#refs/[^\/]*/##;s/[^a-zA-Z0-9-]+/-/g;s/^-*//' <<<"$1")
  reduce "$output"
}

reduce() {
  reduced_value="$1"
  if [ "${MAX_LENGTH}" != "nolimit" ]; then
    reduced_value=$(cut -c1-"${MAX_LENGTH}" <<<"$reduced_value")
  fi
  # 1st : Remove trailing hypens
  sed -E 's/-*$//' <<<"$reduced_value"
}

sanitize() {
  printf '%s' "$1" | tr -d '\n\r'
}

SLUG_VALUE=$(slug "$VALUE")
SLUG_CS_VALUE=$(slug "$CS_VALUE")
SLUG_URL_VALUE=$(slug_url "$VALUE")
SLUG_URL_CS_VALUE=$(slug_url "$CS_VALUE")

# Sanitize all values before writing to GITHUB_OUTPUT / GITHUB_ENV
SAFE_CS_VALUE=$(sanitize "$CS_VALUE")
SAFE_SLUG_VALUE=$(sanitize "$SLUG_VALUE")
SAFE_SLUG_CS_VALUE=$(sanitize "$SLUG_CS_VALUE")
SAFE_SLUG_URL_VALUE=$(sanitize "$SLUG_URL_VALUE")
SAFE_SLUG_URL_CS_VALUE=$(sanitize "$SLUG_URL_CS_VALUE")
SAFE_PREFIX=$(sanitize "$PREFIX")
SAFE_KEY=$(sanitize "$KEY")

if [ -f "$GITHUB_OUTPUT" ]; then
  {
    echo "value=${SAFE_CS_VALUE}"
    echo "slug=${SAFE_SLUG_VALUE}"
    echo "slug-cs=${SAFE_SLUG_CS_VALUE}"
    echo "slug-url=${SAFE_SLUG_URL_VALUE}"
    echo "slug-url-cs=${SAFE_SLUG_URL_CS_VALUE}"
  } >> "$GITHUB_OUTPUT"
else
  echo "::set-output name=value::${SAFE_CS_VALUE}"
  echo "::set-output name=slug::${SAFE_SLUG_VALUE}"
  echo "::set-output name=slug-cs::${SAFE_SLUG_CS_VALUE}"
  echo "::set-output name=slug-url::${SAFE_SLUG_URL_VALUE}"
  echo "::set-output name=slug-url-cs::${SAFE_SLUG_URL_CS_VALUE}"
fi

if [ "${INPUT_PUBLISH_ENV}" == "true" ]; then
  {
    echo "${SAFE_PREFIX}${SAFE_KEY}=${SAFE_CS_VALUE}"
    echo "${SAFE_PREFIX}${SAFE_KEY}_SLUG=${SAFE_SLUG_VALUE}"
    echo "${SAFE_PREFIX}${SAFE_KEY}_SLUG_CS=${SAFE_SLUG_CS_VALUE}"
    echo "${SAFE_PREFIX}${SAFE_KEY}_SLUG_URL=${SAFE_SLUG_URL_VALUE}"
    echo "${SAFE_PREFIX}${SAFE_KEY}_SLUG_URL_CS=${SAFE_SLUG_URL_CS_VALUE}"
  } >>"$GITHUB_ENV"
fi
