#!/usr/bin/env bash
#
# CI wrapper for building the website
#
set -euo pipefail

pnpm run build
