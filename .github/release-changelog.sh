#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

cd "$(dirname "${BASH_SOURCE[0]}")/.."
set -x

chartVersion=$(yq eval .version "charts/vector/Chart.yaml")
git cliff --config .github/cliff.toml --tag "v${chartVersion}" --prepend CHANGELOG.md --unreleased
