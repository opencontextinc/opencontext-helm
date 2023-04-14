<!---
  This README.md is generated using https://github.com/norwoodj/helm-docs.
  Do not modify this directly! Instead modify either the README.md.gotmpl or the values.yaml file.
--->
# OpenContext Helm Charts

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.10.2](https://img.shields.io/badge/AppVersion-v0.10.2-informational?style=flat-square)

[OpenContext](https://opencontext.com) helps get DevSecOps on the same page by untangling the complex relationships between people, code, and services with shared context.

## How to use OpenContext Helm repository

You need to add this repository to your Helm repositories:

```
helm repo add opencontext https://helm.opencontext.com
helm repo update
```

## Prerequisites

- Helm 3 -- See the [Installing Helm docs](https://helm.sh/docs/intro/install) for more information.
- imagePullSecret -- Please contact sales@opencontext.com to create this if you don't already have a registry key.
- [GitHub credentials](https://docs.opencontext.com/docs/configuration/github-credentials) -- Decide whether to use a token or a GitHub app credential. If you're working with multiple organizations, then it's preferable to use a token.

## Requirements

Kubernetes: `>=1.21.0`

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | postgresql | 11.9.13 |

## Quick Start

### Namespace

It is highly recommended for you to create a namespace for OpenContext. In this document we will use the `opencontext` namespace.

```shell
kubectl create namespace opencontext
```

### Image Pull Secret

The OpenContext Helm chart uses a private Docker registry. In order to pull the image from this Docker registry, you'll need a key for the registry. This can be obtained from sales@opencontext.com if you don't already have one.

Once you have a key, run the following command to create an `imagePullSecret` called `opencontext-artifact-registry`:

```shell
kubectl create secret docker-registry opencontext-artifact-registry \
--docker-server=https://us-docker.pkg.dev \
--docker-email=sa-opencontext-registry@vpc-host-prod-345521.iam.gserviceaccount.com \
--docker-username=_json_key --docker-password="$(cat $PATH_TO_REGISTRY_JSON_KEY)" \
--namespace opencontext
```

### Add the OpenContext Helm repository

```shell
helm repo add opencontext https://helm.opencontext.com
helm repo update
```

### Installing the OpenContext chart

To install the chart in the `opencontext` namespace with the release name `<RELEASE_NAME>`, GitHub token `<GH_TOKEN>`, GitHub org `<GH_ORG>`, and org name `<YOUR_ORG>` run:

```shell
helm install  --namespace opencontext --name-template=<RELEASE_NAME> \
  --set "app.orgName=<YOUR_ORG>" \
  --set app.github.token=<GH_TOKEN> \
  --set "app.catalog.locations.githubOrg[0]=https://github.com/<GH_ORG>" \
  --set "app.catalog.locations.githubDiscovery[0]=https://github.com/<GH_ORG>" \
  opencontext/opencontext
```

After installing the chart follow the instructions to port-forward the OpenContext service. Then visit http://localhost:8080 in your browser to use the application.

### Uninstalling OpenContext

To uninstall the OpenContext `<RELEASE_NAME>` release from the namespace `opencontext`:

```shell
NAMESPACE=opencontext
RELEASE_NAME=<release-name> # use `helm list` to find out the name
helm uninstall --namespace ${NAMESPACE} ${RELEASE_NAME}
kubectl --namespace ${NAMESPACE} delete secret opencontext-github-app-auth opencontext-google-cloud-storage opencontext-postgresql opencontext-postgresql-certs opencontext-postgresql-initdb opencontext-tls ${RELEASE_NAME}-opencontext-auth
kubectl --namespace ${NAMESPACE} delete configmap ${RELEASE_NAME}-opencontext-db-pool ${RELEASE_NAME}-opencontext-locations ${RELEASE_NAME}-opencontext-postgres-ca ${RELEASE_NAME}-opencontext-config
kubectl --namespace ${NAMESPACE} delete pvc data-${RELEASE_NAME}-opencontext-postgresql-0
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

As a best practice, a YAML file that specifies the values for the chart parameters should be used to configure the chart. Any parameters not specified in this file will default to those set in [values.yaml](https://github.com/opencontextinc/opencontext-helm/blob/main/charts/opencontext/values.yaml) file.  To install the chart in the `opencontext` namespace with the release name `<RELEASE_NAME>`, GitHub token `<GH_TOKEN>`, GitHub org `<GH_ORG>`, and org name `<YOUR_ORG>` do the following:

1. Create an empty `opencontext-values.yaml` file.
2. Set the following parameters in your `opencontext-values.yaml` file.

```yaml
app:
  orgName: <YOUR_ORG>
  github:
    authType: token
    token: <GH_TOKEN>
  catalog:
    locations:
      githubOrg:
        - https://github.com/<GH_ORG>
      githubDiscovery:
        - https://github.com/<GH_ORG>
```

3. Install or upgrade the OpenContext Helm chart with the new `opencontext-values.yaml` file:

```shell
helm install --namespace opencontext --name-template=<RELEASE_NAME>
  -f opencontext-values.yaml opencontext/opencontext
```

OR

```shell
helm upgrade --namespace opencontext --name-template=<RELEASE_NAME>
  -f opencontext-values.yaml opencontext/opencontext
```

See the [All configuration options](#all-configuration-options) section to discover all the possibilities in the OpenContext chart.

## All configuration options

The following table lists the configurable parameters of the OpenContext chart and their default values. Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
helm install  --namespace opencontext --name-template=<RELEASE_NAME> \
  --set "app.orgName=<YOUR_ORG>" \
  --set app.github.token=<GH_TOKEN> \
  --set "app.catalog.locations.githubOrg[0]=https://github.com/<GH_ORG>" \
  --set "app.catalog.locations.githubDiscovery[0]=https://github.com/<GH_ORG>" \
  opencontext/opencontext
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Configure [affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) rules for pods. |
| app.auth | object | `{"enabled":false,"provider":{"google":{"clientId":null,"clientSecret":null}}}` | Auth configuration |
| app.auth.enabled | bool | `false` | If true, enable Google OAuth for authentication. For more details see our [docs](https://docs.opencontext.com/docs/getting-started/onprem-install#auth). |
| app.auth.provider.google.clientId | string | `nil` | Google OAuth client id |
| app.auth.provider.google.clientSecret | string | `nil` | Google OAuth client secret |
| app.bitbucket | object | `{"appAuth":{"appPassword":null,"username":null},"authType":"appPassword","enabled":false,"host":null,"token":null}` | Bitbucket configuration |
| app.bitbucket.appAuth | object | `{"appPassword":null,"username":null}` | Bitbucket app password credentials to use if `authType` is set to `appPassword` |
| app.bitbucket.appAuth.appPassword | string | `nil` | Bitbucker app password |
| app.bitbucket.appAuth.username | string | `nil` | Bitbucket username |
| app.bitbucket.authType | string | `"appPassword"` | Bitbucket authentication type. Must be one of `appPassword` or `token` For more details see our [docs](https://docs.opencontext.com/docs/configuration/bitbucket-credentials). |
| app.bitbucket.enabled | bool | `false` | If true, enable Bitbucket integration |
| app.bitbucket.host | string | bitbucket.org | Bitbucket host |
| app.bitbucket.token | string | `nil` | Bitbucket token to use if `authType` is set to `token` |
| app.catalog.intervalSecs | int | `200` | Seconds between catalog refreshes |
| app.catalog.locations | object | `{"bitbucketDiscovery":[],"gcsDiscovery":[],"githubDiscovery":[],"githubOrg":[],"url":[]}` | Catalog locations. For details see our [docs](https://docs.opencontext.com/docs/getting-started/onprem-install#catalog-locations). |
| app.catalog.locations.bitbucketDiscovery | list | `[]` | List of Bitbucket URLs. <br/><br/> Workspaces should be referenced using the workspace ID and projects should use the project key. <br/><br/> **Discover all repositories in a workspace** <br/><br/> URL Format: `https://bitbucket.org/workspaces/${WORKSPACE_ID}` <br/><br/> For example, <br/> `- https://bitbucket.org/workspaces/scatterly` <br/><br/> **Discover all repositories in a project** <br/><br/> URL Format: `https://bitbucket.org/workspaces/${WORKSPACE_ID}/projects/${PROJECT_KEY}` <br/><br/> For example, <br/> `- https://bitbucket.org/workspaces/scatterly/projects/CRATES` <br/><br/> **Select only a specific repository** <br/><br/> URL Format: `https://bitbucket.org/workspaces/${WORKSPACE_ID}/${MY_REPO}` <br/><br/> For example, <br/> `- https://bitbucket.org/workspaces/scatterly/crates-frontend` <br/><br/> **Search for OpenContext catalog YAML file in all repositories in a project** <br/><br/> URL Format: `https://bitbucket.org/workspaces/${WORKSPACE_ID}/projects/${PROJECT_KEY}/repos/*?search=true&catalogPath=my/nested/path/catalog.yaml` <br/><br/> For example, <br/> `- https://bitbucket.org/workspaces/scatterly/projects/CRATES/repos/*?search=true&catalogPath=my/nested/path/catalog.yaml` |
| app.catalog.locations.gcsDiscovery | list | `[]` | List of Google Cloud Storage (GCS) URLs <br/><br/> **Discover all OpenContext YAML files in a Google Cloud Storage bucket** <br/><br/> URL Format: `https://storage.cloud.google.com/${GCS_BUCKET}/${GCS_BUCKET_PATH_TO_YAML}/*` <br/><br/> For example, <br/> `- https://storage.cloud.google.com/scatterly/yaml/uploads/*` |
| app.catalog.locations.githubDiscovery | list | `[]` | List of GitHub repositories <br/><br/> **Discover codepaths and other associated artifacts in a GitHub repo.** <br/><br/> NOTE: The trailing slash is required! <br/> URL Format: `https://github.com/${GITHUB_ORG}/${MY_REPO}/` <br/><br/> For example, <br/> `- https://github.com/scatter-ly/publictest/` <br/><br/> **Discover OpenContext catalog YAML file in a GitHub repository.** <br/><br/> URL Format: `https://github.com/${GITHUB_ORG}/${MY_REPO}/blob/${MY_BRANCH}/*.yaml` <br/><br/> For example, <br/> `- https://github.com/scatter-ly/scatter.ly/blob/main/*.yaml` |
| app.catalog.locations.githubOrg | list | `[]` | List of GitHub organization URLs used to discover people and teams in GitHub. <br /><br /> URL Format: `https://github.com/${GITHUB_ORG}` <br/><br/> For example, <br/> `- https://github.com/scatter-ly` |
| app.catalog.locations.url | list | `[]` | List of URLs <br/><br/> **Discover OpenContext catalog YAML file in a GitHub repository** <br/><br/> For example, <br/> `- https://github.com/scatter-ly/publictest/blob/main/oc-catalog.yaml` <br/><br/> **Discover all OpenContext YAML files in a specific BitBucket repo** <br/><br/> NOTE: Bitbucket must be enabled. <br/> URL Format: `https://bitbucket.org/${WORKSPACE_ID}/${MY_REPO}/src/${MY_BRANCH}/*.yaml` <br/><br/> For example, <br/> `- https://bitbucket.org/scatter-ly/scatter.ly/src/main/*.yaml` |
| app.database.connection | object | `{"host":null,"password":null,"pool":{"max":20,"min":0},"port":null,"ssl":{"enabled":true,"rejectUnauthorized":false},"user":null}` | PostgreSQL database connection info |
| app.database.connection.host | string | `nil` | PostgreSQL database host |
| app.database.connection.password | string | `nil` | PostgreSQL database password |
| app.database.connection.pool | object | `{"max":20,"min":0}` | PostgreSQL database pool configuration |
| app.database.connection.pool.max | int | `20` | PostgreSQL database pool maximum size |
| app.database.connection.pool.min | int | `0` | PostgreSQL database pool minimum size |
| app.database.connection.port | string | `nil` | PostgreSQL database port |
| app.database.connection.ssl | object | `{"enabled":true,"rejectUnauthorized":false}` | PostgreSQL database SSL/TLS configuration |
| app.database.connection.ssl.enabled | bool | `true` | Whether the PostgreSQL database has SSL/TLS enabled |
| app.database.connection.ssl.rejectUnauthorized | bool | `false` | If true, the server certificate is verified against the list of supplied CAs. An error event is emitted if verification fails |
| app.database.connection.user | string | `nil` | PostgreSQL database user |
| app.database.prefix | string | `"opencontext_"` | Prefix for the application to use when generating databases in PostgreSQL |
| app.github | object | `{"appAuth":{"appAuthSecret":"opencontext-github-app-auth","createAppAuthFromFile":null},"authType":"token","host":null,"token":"MY_TOKEN"}` | GitHub configuration |
| app.github.appAuth | object | `{"appAuthSecret":"opencontext-github-app-auth","createAppAuthFromFile":null}` | GitHub app credentials to use if `authType` is set to `app`. |
| app.github.appAuth.appAuthSecret | string | `"opencontext-github-app-auth"` | Name of secret that contains the GitHub app credentials. |
| app.github.appAuth.createAppAuthFromFile | path | `nil` | Path to GitHub app credentials file the chart should use to create the `appAuthSecret`. **NOTE**: Only works when chart is downloaded and run locally. |
| app.github.authType | string | `"token"` | GitHub authentication type. Must be one of `token` or `app` for GitHub app. For more details see our [docs](https://docs.opencontext.com/docs/configuration/github-credentials). |
| app.github.host | string | github.com | GitHub host |
| app.github.token | string | `"MY_TOKEN"` | GitHub token to use if `authType` is set to `token`. |
| app.googleCloudStorage | object | `{"createServiceAccountFromFile":null,"enabled":false,"serviceAccountSecret":"opencontext-google-cloud-storage","useServiceAccount":false}` | Google Cloud Storage (GCS) configuration |
| app.googleCloudStorage.createServiceAccountFromFile | path | `nil` | Path to Google Cloud service account key file the chart should use to create the `serviceAccountSecret`. **NOTE**: Only works when chart is downloaded and run locally. |
| app.googleCloudStorage.enabled | bool | `false` | If true, enable Google Cloud Storage (GCS) integration |
| app.googleCloudStorage.serviceAccountSecret | string | `"opencontext-google-cloud-storage"` | Name of secret that contains the service account credentials. |
| app.googleCloudStorage.useServiceAccount | bool | `false` | If true, application will use `serviceAccountSecret` to authenticate with Google. This can be set to false if running on Google Cloud infrastructure. i.e. GKE |
| app.orgName | string | `nil` | Organization name to be displayed in the app. |
| app.pagerDuty | object | `{"enabled":false,"token":null}` | PagerDuty configuration |
| app.pagerDuty.enabled | bool | `false` | If true, enable PagerDuty integration |
| app.pagerDuty.token | string | `nil` | PagerDuty API token. For more details see our [docs](https://docs.opencontext.com/docs/configuration/pagerduty-credentials). |
| app.url | string | `"http://localhost:8080"` | URL to access the application. If Ingress is disabled use `kubectl port-forward` to forward the OpenContext service to port 8080. You will then be able to access it at http://localhost:8080. |
| autoscaling.enabled | bool | `false` | Create a [HorizontalPodAutoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) |
| autoscaling.maxReplicas | int | `10` | Maximum replicas for the HPA |
| autoscaling.minReplicas | int | `1` | Minimum replicas for the HPA |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization for HPA |
| autoscaling.targetMemoryUtilizationPercentage | int | `nil` | Target memory utilization for HPA |
| fullnameOverride | string | `""` | Override the full name of resources |
| global.nodeSelector | object | `{}` |  |
| global.postgresql | object | `{"auth":{"existingSecret":"opencontext-postgresql","username":"opencontext"},"caFilename":"ca.crt"}` | Global configuration for PostgreSQL |
| global.postgresql.auth | object | `{"existingSecret":"opencontext-postgresql","username":"opencontext"}` | Configuration from the [Global parameters section](https://artifacthub.io/packages/helm/bitnami/postgresql#global-parameters) of the Bitnami PostgreSQL subchart. |
| global.postgresql.auth.existingSecret | string | `"opencontext-postgresql"` | Name of existing secret to use for PostgreSQL credentials. Need an entry for `password` and `postgres-password`. See [docs](https://docs.bitnami.com/kubernetes/infrastructure/apache-airflow/administration/use-existing-secrets/) for more instructions. |
| global.postgresql.auth.username | string | `"opencontext"` | Name for a custom user to create |
| global.postgresql.caFilename | string | `"ca.crt"` | PostgreSQL CA certificate filename |
| image.pullPolicy | string | `"Always"` | Image pull policy |
| image.repository | string | `"us-docker.pkg.dev/vpc-host-prod-345521/oc-docker/opencontext"` | OpenContext image |
| image.tag | string | `"latest"` | Image tag |
| imagePullSecrets[0] | object | `{"name":"opencontext-artifact-registry"}` | The [imagePullSecrets](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod) to reference for the opencontext app |
| ingress.annotations | string | `nil` | Set annotations on the Ingress. If `issuer.clusterIssuer` is set then add the annotation `cert-manager.io/cluster-issuer` here. |
| ingress.className | string | `nil` | Specify the [ingressClassName](https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#specifying-the-class-of-an-ingress) |
| ingress.enabled | bool | `false` | If true, create and use an Ingress resource. |
| ingress.hosts | list | `[]` | Configure the hosts and paths for the Ingress. Make sure to change the `app.url` to match the host set |
| ingress.tls | list | `[]` | Configure the TLS for the Ingress. |
| issuer.clusterIssuer | string | `"selfsigned-issuer"` | ClusterIssuer. Must be one of `selfsigned-issuer`, `letsencrypt-staging`, or `letsencrypt-prod` |
| issuer.email | string | `nil` | Required if `issuer.clusterIssuer` is not `selfsigned-issuer` |
| nameOverride | string | `""` | Override the name of resources |
| nodeSelector | object | `{}` | Configure a [nodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) |
| podAnnotations | object | `{}` | Set annotations on pods |
| podSecurityContext | object | `{"fsGroup":1000,"fsGroupChangePolicy":"OnRootMismatch","runAsGroup":1000,"runAsUser":1000}` | Allows you to overwrite the default [PodSecurityContext](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| postgresql | object | `{"commonLabels":{"app.kubernetes.io/part-of":"opencontext-server"},"enabled":true,"nameOverride":"opencontext-postgresql","primary":{"initdb":{"scriptsSecret":"opencontext-postgresql-initdb"},"persistence":{"enabled":true,"size":"10Gi"}},"service":{"port":5432},"tls":{"certFilename":"tls.crt","certKeyFilename":"tls.key","certificatesSecret":"opencontext-postgresql-certs","enabled":true},"volumePermissions":{"enabled":true}}` | Configuration for the Bitnami PostgreSQL subchart. [Values](https://artifacthub.io/packages/helm/bitnami/postgresql) for the subchart can be found on [ArtifactHUB.io](https://artifacthub.io/packages/helm/bitnami/postgresql). |
| postgresql.commonLabels | object | `{"app.kubernetes.io/part-of":"opencontext-server"}` | Additional labels added to the postgresql resources. |
| postgresql.enabled | bool | `true` | if true, use Bitnami PostgreSQL subchart to create a database. |
| postgresql.nameOverride | string | `"opencontext-postgresql"` | Override the name of the postgresql resources. |
| postgresql.primary.initdb.scriptsSecret | string | `"opencontext-postgresql-initdb"` | Secret with scripts to be run at first boot for the primary database (in case it contains sensitive information) |
| postgresql.primary.persistence.enabled | bool | `true` | Enable primary PostgreSQL data persistence using PVC |
| postgresql.primary.persistence.size | string | `"10Gi"` | PVC Storage Request for primary PostgreSQL volume |
| postgresql.service.port | int | `5432` | PostgreSQL service port |
| postgresql.tls.certFilename | string | `"tls.crt"` | Certificate filename |
| postgresql.tls.certKeyFilename | string | `"tls.key"` | Certificate key filename |
| postgresql.tls.certificatesSecret | string | `"opencontext-postgresql-certs"` | Name of an secret that contains the certificates |
| postgresql.tls.enabled | bool | `true` | Enable TLS traffic support |
| postgresql.volumePermissions.enabled | bool | `true` | Enable init container that changes the owner and group of the persistent volume |
| replicaCount | int | `1` | Number of pods to create |
| resources | object | `{}` | Set resource requests and limits. |
| securityContext | object | `{"allowPrivilegeEscalation":false,"runAsGroup":1000,"runAsNonRoot":true,"runAsUser":1000}` | Allows you to overwrite the default [SecurityContext](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | Configure pods to be scheduled on [tainted](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) nodes. |

