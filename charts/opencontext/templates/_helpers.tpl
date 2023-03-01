{{/*
Expand the name of the chart.
*/}}
{{- define "opencontext.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "opencontext.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "opencontext.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "opencontext.labels" -}}
app.kubernetes.io/name: {{ include "opencontext.name" . }}
helm.sh/chart: {{ include "opencontext.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/component: opencontext-server
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "opencontext.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opencontext.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use for the app
*/}}
{{- define "opencontext.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "opencontext.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Name for PostgreSQL dependency
See https://github.com/helm/helm/issues/3920#issuecomment-686913512
*/}}
{{- define "opencontext.postgresql.fullname" -}}
{{ printf "%s-%s" .Release.Name .Values.postgresql.nameOverride }}
{{- end -}}

{{/*
Path to the PostgreSQL CA certificate file
*/}}
{{- define "opencontext.postgresCaFilename" -}}
{{ include "opencontext.postgresCaDir" . }}/{{- required "The name for the CA certificate file for postgresql is required" .Values.global.postgresql.caFilename }}
{{- end -}}
{{/*

{{/*
Directory path to the PostgreSQL CA certificate
*/}}
{{- define "opencontext.postgresCaDir" -}}
{{- if .Values.app.database.connection.ssl.ca -}}
    {{ .Values.app.database.connection.ssl.ca }}
{{- else -}}
/etc/postgresql
{{- end -}}
{{- end -}}

{{/*
Generate ca for postgresql
*/}}
{{- define "opencontext.postgresql.generateCA" -}}
{{- $ca := .ca | default (genCA (include "opencontext.postgresql.fullname" .) 365) -}}
{{- $_ := set . "ca" $ca -}}
{{- $ca.Cert -}}
{{- end -}}

{{/*
Generate certificates for postgresql
*/}}
{{- define "opencontext.postgresql.generateCerts" -}}
{{- $postgresName := (include "opencontext.postgresql.fullname" .) }}
{{- $altNames := list $postgresName ( printf "%s.%s" $postgresName .Release.Namespace ) ( printf "%s.%s.svc" ( $postgresName ) .Release.Namespace ) -}}
{{- $ca := .ca | default (genCA (include "opencontext.postgresql.fullname" .) 365) -}}
{{- $_ := set . "ca" $ca -}}
{{- $cert := genSignedCert ( $postgresName ) nil $altNames 365 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end -}}

{{/*
Generate a password for the postgres user used for the connections
*/}}
{{- define "postgresql.generateUserPassword" -}}
{{- $pgPassword := .pgPassword | default ( randAlphaNum 12 ) -}}
{{- $_ := set . "pgPassword" $pgPassword -}}
{{ $pgPassword}}
{{- end -}}


{{/*
Name of the postgresql service
*/}}
{{- define "postgresql.serviceName" -}}
{{- include "opencontext.postgresql.fullname" . }}
{{- end -}}

{{/*
Postgres host
*/}}
{{- define "postgresql.host" -}}
{{- if .Values.postgresql.enabled }}
{{- include "postgresql.serviceName" . }}
{{- else -}}
{{- required "A valid .Values.app.database.connection.host is required when postgresql is not enabled" .Values.app.database.connection.host -}}
{{- end -}}
{{- end -}}

{{/*
Postgres port
*/}}
{{- define "postgresql.port" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.service.port }}
{{- else if .Values.app.database.connection.port -}}
{{- .Values.app.database.connection.port }}
{{- else -}}
5432
{{- end -}}
{{- end -}}

{{/*
Postgres user
*/}}
{{- define "postgresql.user" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.global.postgresql.auth.username }}
{{- else -}}
{{- required "A valid .Values.app.database.connection.user is required when postgresql is not enabled" .Values.app.database.connection.user -}}
{{- end -}}
{{- end -}}

{{/*
Postgres password secret
*/}}
{{- define "postgresql.passwordSecret" -}}
{{- if .Values.postgresql.enabled }}
{{- template "opencontext.postgresql.fullname" . }}
{{- else -}}
{{ $secretName := (printf "%s-postgresql" (include "opencontext.fullname" . )) }}
{{- required "A valid .Values.app.database.connection.password is required when postgresql is not enabled" $secretName -}}
{{- end -}}
{{- end -}}

{{/*
PostgreSQL Common labels
*/}}
{{- define "opencontext.postgresql.labels" -}}
app.kubernetes.io/name: {{ include "opencontext.postgresql.fullname" . }}
helm.sh/chart: {{ include "opencontext.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/component: opencontext-postgresql
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "opencontext.var_dump" -}}
{{- . | mustToPrettyJson | printf "\n\nThe JSON output of the dumped var is: \n%s\n" | fail }}
{{- end -}}
