#!/usr/bin/env bash

# Display message with yellow text to sdterr
function warn() {
    echo -ne '\x1b[33m' >&2
    echo "${@}" >&2
    echo -ne '\x1b[0m' >&2
}

# Display message with red text to sdterr
function err() {
    echo -ne '\x1b[31m' >&2
    echo "${@}" >&2
    echo -ne '\x1b[0m' >&2
}

function debug() {
    echo -ne '\x1b[1;30m' >&2
    echo "${@}" >&2
    echo -ne '\x1b[0m' >&2
}

# Sanity check for curl – https://curl.se
if ! command -v curl &>/dev/null; then
    err "curl executable not found"
    exit 1
fi

# Sanity check for jq – https://stedolan.github.io/jq/
if ! command -v jq &>/dev/null; then
    err "jq executable not found"
    exit 1
fi

# Sanity check for GNU Privacy Guard - https://gnupg.org/
if ! command -v gpg &>/dev/null; then
    err "gnupg executable not found"
    exit 1
fi

# Display usage if no GitHub usernames specified
if [[ $# -lt 1 ]]; then
    warn "No GitHub user names specified!"
    echo
    echo "Usage: $0 <GitHub user name #1> [ <GitHub user name #2> ... <GitHub user name #N> ]"
    echo
    exit 1
fi

# Get the directory where this script is installed, in case that's where the token file lives
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Look for $GITHUB_TOKEN, and if not in the current environment, look for a file named
# .github_token containing the variable, e.g.:
#
# GITHUB_TOKEN=<whatever>
if [[ -z "${GITHUB_TOKEN}" ]]; then

    if [[ -f "${SCRIPT_DIR}/.github_token" ]]; then

        # shellcheck source=.github_token
        . "${SCRIPT_DIR}/.github_token"

    elif [[ -f ~/.github_token ]]; then

        # shellcheck source=.github_token
        . ~/.github_token

    else
        err "GITHUB_TOKEN environment variable not set!"
        exit 1
    fi
fi


TMPFILE="$(mktemp)"
trap "rm -f ${TMPFILE}" 0 1 2 15

# Debug info
#debug "Github token is ${GITHUB_TOKEN}"
#debug "Name of temp file is ${TMPFILE}"

for GH_USER in "${@}"; do
    curl -sL \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "https://api.github.com/users/${GH_USER}/gpg_keys" | jq -r '.[]|.raw_key' >>"${TMPFILE}"
done

# Display key info for informational purposes
echo -ne '\x1b[36m'
gpg --import --import-options show-only "${TMPFILE}"
echo -ne '\x1b[0m'

warn "Do you wish to import these keys?"
read -n 1 -s -p '(y/N)'
echo

if [[ ${REPLY} =~ ^[yY] ]]; then
    gpg --import --import-options 'import-clean=yes,repair-keys=yes' "${TMPFILE}"
fi
