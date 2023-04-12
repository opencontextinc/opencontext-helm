#!/usr/bin/env bash
set -euo pipefail

SCHEMA_LOCATION="https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/" # Up-to-date fork of instrumenta/kubernetes-json-schema

CHANGED_CHARTS=${CHANGED_CHARTS:-${1:-}}
if [ -n "$CHANGED_CHARTS" ];
then
  CHART_DIRS=$CHANGED_CHARTS
else
  CHART_DIRS=$(ls -d charts/*)
fi

# validate charts
for CHART_DIR in ${CHART_DIRS}; do
  echo "Running kubeconform for folder: '$CHART_DIR'"
  #helm dep up "${CHART_DIR}" && helm template --values "${CHART_DIR}"/ci/kvalidate.yaml "${CHART_DIR}" | ./kubeconform --strict --ignore-missing-schemas --kubernetes-version "${KUBERNETES_VERSION#v}" --schema-location "${SCHEMA_LOCATION}"
  helm dep up "${CHART_DIR}" && helm kubeconform -f "${CHART_DIR}/ci/kvalidate.yaml" --strict --ignore-missing-schemas --kubernetes-version "${KUBERNETES_VERSION#v}" --schema-location "${SCHEMA_LOCATION}" --verbose --summary "${CHART_DIR}"
done
