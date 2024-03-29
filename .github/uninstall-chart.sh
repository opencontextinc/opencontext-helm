#!/bin/bash
NAMESPACE=${1-opencontext}
RELEASE_NAME=${2-oc1}

echo
echo "========================================================================================================================"
echo "INFO: Uninstalling release ${RELEASE_NAME} from namespace ${NAMESPACE}"

helm uninstall --namespace ${NAMESPACE} ${RELEASE_NAME}
kubectl --namespace ${NAMESPACE} delete secret opencontext-github-app-auth opencontext-google-cloud-storage opencontext-postgresql opencontext-postgresql-certs opencontext-postgresql-initdb opencontext-tls ${RELEASE_NAME}-opencontext-auth --force --grace-period=0
kubectl --namespace ${NAMESPACE} delete configmap ${RELEASE_NAME}-opencontext-db-pool ${RELEASE_NAME}-opencontext-locations ${RELEASE_NAME}-opencontext-postgres-ca ${RELEASE_NAME}-opencontext-config --force --grace-period=0
kubectl --namespace ${NAMESPACE} delete pvc data-${RELEASE_NAME}-opencontext-postgresql-0 --force --grace-period=0
kubectl --namespace ${NAMESPACE} wait --for=delete pvc/data-${RELEASE_NAME}-opencontext-postgresql-0 --timeout=60s

echo "========================================================================================================================"
echo ""

# always exit 0 since we only care if the script ran but not the exit code of each individual command
exit 0
