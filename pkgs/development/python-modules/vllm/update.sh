#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl sd ripgrep jaq common-updater-scripts nix-prefetch
# shellcheck shell=bash

# Updates the main vLLM package and three external dependencies:
# - CUTLASS (NVIDIA's CUDA Templates for Linear Algebra Subroutines)
# - FlashMLA (vLLM's Flash Memory Layer Attention implementation)
# - flash-attention (vLLM's fork of Dao-AILab's FlashAttention)
#
# Modern tools used for better ergonomics and error messages:
# - jaq: Fast and correct jq implementation in Rust with better error handling
# - sd: Intuitive sed replacement in Rust with sane regex syntax and UTF-8 support
# - rg (ripgrep): Fast grep replacement in Rust with multiline support and better UX

set -euo pipefail

# Warn about potential GitHub API rate limiting without authentication
if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    echo "Warning: No GITHUB_TOKEN set - may hit GitHub API rate limits" >&2
fi

readonly root="$(dirname "$(readlink --canonicalize "$0")")"

# Validate nix file exists
if [[ ! -f "$root/default.nix" ]]; then
    echo "error: default.nix not found at $root/default.nix" >&2
    exit 1
fi

# Fetch latest vLLM release version from GitHub API
readonly vllm_version=$(curl --silent \
    --header "Accept: application/vnd.github.v3+json" \
    ${GITHUB_TOKEN:+ --header "Authorization: bearer $GITHUB_TOKEN"} \
    https://api.github.com/repos/vllm-project/vllm/releases/latest \
    | jaq --raw-output .tag_name \
    | sd '^v' '')

# Base URLs for fetching upstream configuration files
readonly vllm_project_base_url=https://raw.githubusercontent.com/vllm-project
readonly versioned_vllm_url=$vllm_project_base_url/vllm/v$vllm_version

# Update hardcoded version strings in the nix file by parsing actual source files
# Dependencies like FlashMLA have both a git revision AND a separate version string
# that must be kept in sync with what's declared in their setup.py or __init__.py
update_version_string() {
    if (($# != 2)); then
        echo "error: update_version_string expected 2 arguments, got $#" >&2
        exit 1
    fi

    local -r github_repo="$1"
    local -r new_revision="$2"
    local source_file version_pattern nix_search_pattern new_version

    # Map repository names to their version source files and patterns
    case "${github_repo##*/}" in
        FlashMLA)
            source_file="setup.py"
            version_pattern='"([0-9]+\.[0-9]+\.[0-9]+)"'
            nix_search_pattern="flashmla = stdenv.mkDerivation"
            ;;
        flash-attention)
            source_file="vllm_flash_attn/__init__.py"
            version_pattern='__version__\s*=\s*"([^"]+)"'
            nix_search_pattern="vllm-flash-attn' = lib.defaultTo"
            ;;
        *)
            return 0
            ;;
    esac

    # Extract version from the actual source file at the specified revision
    new_version=$(curl --silent "$vllm_project_base_url"/"${github_repo##*/}"/"$new_revision"/"$source_file" \
        | rg --only-matching "$version_pattern" --replace '$1')

    if [[ -n "$new_version" ]]; then
        # Update the hardcoded version string in the nix file using multiline regex
        local -r nix_update_pattern='('"$nix_search_pattern"'.*?version = ")[^"]+(";)'
        local -r nix_replacement='${1}'"$new_version"'${2}'
        sd --flags ms "$nix_update_pattern" "$nix_replacement" "$root/default.nix"
    fi
}

# Update git dependency by parsing CMake external project configurations
# Coordinates revision, hash, and version string updates for git-based dependencies
update_git_dep() {
    if (($# != 5)); then
        echo "error: update_git_dep expected 5 arguments, got $#" >&2
        exit 1
    fi

    local -r upstream_file="$1"
    local -r upstream_pattern="$2"
    local -r nix_search_pattern="$3"
    local -r github_repo="$4"
    local -r field="$5"
    local new_revision current_revision hash sri

    # Extract new revision from upstream CMake configuration
    new_revision=$(curl --silent "$versioned_vllm_url/$upstream_file" \
        | rg --only-matching "$upstream_pattern" --replace '$1')

    # Find current revision in nix file using multiline regex (crucial for spanning rev/hash)
    current_revision=$(rg --multiline --multiline-dotall \
        "$nix_search_pattern"'.*?'"$field"' = "([^"]+)"' \
        --only-matching --replace '$1' "$root/default.nix")

    if [[ "$current_revision" != "$new_revision" ]]; then
        # Prefetch new archive and convert to SRI format
        hash=$(nix-prefetch-url --unpack \
            https://github.com/"$github_repo"/archive/"$new_revision".tar.gz 2>/dev/null)
        sri=$(nix hash convert --hash-algo sha256 "$hash")

        # Update both revision and hash in one atomic operation
        local -r nix_update_pattern='('"$nix_search_pattern"'.*?'"$field"' = ")[^"]+(".*?hash = ")[^"]+(";)'
        local -r nix_replacement='${1}'"$new_revision"'${2}'"$sri"'${3}'
        sd --flags ms "$nix_update_pattern" "$nix_replacement" "$root/default.nix"

        # Update any associated hardcoded version strings
        update_version_string "$github_repo" "$new_revision"
    fi
}

# Update main vLLM package version using nixpkgs common-updater-scripts
update-source-version python3Packages.vllm "$vllm_version"

# Update CUTLASS dependency (NVIDIA's CUDA linear algebra templates)
update_git_dep \
    "CMakeLists.txt" \
    'CUTLASS_REVISION "([^"]+)"' \
    "cutlass = fetchFromGitHub" \
    "NVIDIA/cutlass" \
    "tag"

# Update FlashMLA dependency (vLLM's Flash Memory Layer Attention)
update_git_dep \
    "cmake/external_projects/flashmla.cmake" \
    'GIT_TAG ([a-f0-9]+)' \
    "flashmla = stdenv.mkDerivation" \
    "vllm-project/FlashMLA" \
    "rev"

# Update flash-attention dependency (vLLM's FlashAttention fork)
update_git_dep \
    "cmake/external_projects/vllm_flash_attn.cmake" \
    'GIT_TAG ([a-f0-9]+)' \
    "vllm-flash-attn' = lib.defaultTo" \
    "vllm-project/flash-attention" \
    "rev"
