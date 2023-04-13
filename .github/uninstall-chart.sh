#!/bin/bash
NAMESPACE=${1-opencontext}
RELEASE_NAME=${2-oc1}

helm uninstall --namespace ${NAMESPACE} ${RELEASE_NAME}
kubectl --namespace ${NAMESPACE} delete secret opencontext-github-app-auth opencontext-google-cloud-storage opencontext-postgresql opencontext-postgresql-certs opencontext-postgresql-initdb opencontext-tls ${RELEASE_NAME}-opencontext-auth
kubectl --namespace ${NAMESPACE} delete configmap ${RELEASE_NAME}-opencontext-db-pool ${RELEASE_NAME}-opencontext-locations ${RELEASE_NAME}-opencontext-postgres-ca ${RELEASE_NAME}-opencontext-config
kubectl --namespace ${NAMESPACE} delete pvc data-${RELEASE_NAME}-opencontext-postgresql-0