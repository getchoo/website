#!/usr/bin/env bash
#
# ci wrapper for building the website. build commands below
#
set -euo pipefail

function build_site {
    asdf plugin add zola https://github.com/salasrod/asdf-zola
    asdf install zola 0.17.2
    asdf global zola 0.17.2
    zola build --output-dir dist
}


# get the root directory of the project
# (so the parent directory of this script's parent directory)
REPO_DIR="$(readlink -f "$0" | xargs dirname)"/..

cd "$REPO_DIR"
build_site
