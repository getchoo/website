#!/usr/bin/env bash
#
# ci wrapper for building the website. build commands below
#
set -euo pipefail

function build_site {
    curl -fsSL https://deno.land/x/install/install.sh | sh && /opt/buildhome/.deno/bin/deno task build --dest dist/
}


# get the root directory of the project
# (so the parent directory of this script's parent directory)
REPO_DIR="$(readlink -f "$0" | xargs dirname)"/..

cd "$REPO_DIR"
build_site
