#!/usr/bin/env bash

# Requires jq

set -euo pipefail

if sed --version 2>/dev/null | grep -q "GNU sed"; then
    SED="sed"
elif gsed --version 2>/dev/null | grep -q "GNU sed"; then
    SED="gsed"
fi

cd "$(dirname "${BASH_SOURCE[0]}")/.."
set -x

# get opencontext app version
OC_VERSION=$(curl -H "Authorization: token ${TOKEN}" -L -sS https://api.github.com/repos/opencontextinc/opencontext/releases/latest | jq -r .tag_name)
CHART_APP_VERSION=$(cat charts/opencontext/Chart.yaml | grep appVersio | awk -F': ' '{print $2}')
if [[ ${OC_VERSION} != ${CHART_APP_VERSION} ]]; then
  echo "INFO: Updating chart appVersion ..."
  # edit opencontext chart appVersion
  ${SED:-sed} -i -E "s/^appVersion: .*/appVersion: $OC_VERSION/" charts/opencontext/Chart.yaml
  git add charts/opencontext/Chart.yaml
  git commit -m "Updated opencontext appVersion"
  git push
else
  echo "INFO: Chart appVersion does not need to be changed."
fi

