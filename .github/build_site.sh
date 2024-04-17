#!/usr/bin/env bash
#
# ci wrapper for building the website. build commands below
#
set -euo pipefail

function build_site {
  pnpm install --frozen-lockfile
  pnpm run ci
  pnpm run build
}


# get the root directory of the project
# (so the parent directory of this script's parent directory)
REPO_DIR="$(readlink -f "$0" | xargs dirname)"/..

cd "$REPO_DIR"
build_site
