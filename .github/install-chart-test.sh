#!/usr/bin/env bash

#------------------------------------------------------------------------------------
# PURPOSE:
#   Custom script to test chart installation since cleanup of PVC among other things
#   are not happening correctly which then causes failures
#------------------------------------------------------------------------------------

set -euo pipefail

CHANGED_CHARTS=${CHANGED_CHARTS:-${1:-}}
if [ -n "$CHANGED_CHARTS" ];
then
  CHART_DIRS=$CHANGED_CHARTS
else
  CHART_DIRS=$(ls -d charts/*)
fi

# install charts
for CHART_DIR in ${CHART_DIRS}; do
  echo
  echo "INFO: Running chart-testing for chart ${CHART_DIR}"
  # Can't configure chart-testing to use another directory other than the ci directory
  # So moving ci folder aside
  mv "${CHART_DIR}/ci" "${CHART_DIR}/ci.old"
  mkdir "${CHART_DIR}/ci"

  # Iterate through *-values.yaml files in example directory
  for f in "${CHART_DIR}"/examples/*-values.yaml; do
    cp "${f}" "${CHART_DIR}/ci/${f##*/}"
    # Run the test and if it errors out stop testing
    if ! ct install --config .github/ct.yaml --upgrade --namespace opencontext --charts "${CHART_DIR}"; then
      echo "ERROR: Chart testing encountered errors while testing ${CHART_DIR} with ${f} !"
      exit 1
    fi

    # Figure out Helm release name by getting the PostgreSQL PVC which always needs to be cleaned up
    RELEASE_NAME=$(kubectl --namespace opencontext get pvc | grep "data-opencontext-" | awk '{print $1}' | cut -d'-' -f3)

    # remove file in ci and run uninstall script
    rm "${CHART_DIR}/ci/${f##*/}"
    .github/uninstall-chart.sh opencontext "opencontext-${RELEASE_NAME}"
  done
done
