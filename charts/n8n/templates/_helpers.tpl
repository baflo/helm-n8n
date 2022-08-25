{{/*
Expand the name of the chart.
*/}}
{{- define "n8n.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "n8n.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "n8n.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "n8n.labels" -}}
helm.sh/chart: {{ include "n8n.chart" . }}
{{ include "n8n.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "n8n.selectorLabels" -}}
app.kubernetes.io/name: {{ include "n8n.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Main app selector labels
*/}}
{{- define "n8n.mainAppSelectorLabels" -}}
{{ include "n8n.selectorLabels" . }}
app.kubernetes.io/role: main
{{- end }}

{{/*
Worker selector labels
*/}}
{{- define "n8n.workerAppSelectorLabels" -}}
{{ include "n8n.selectorLabels" . }}
app.kubernetes.io/role: worker
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "n8n.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "n8n.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the basic auth secret to use
*/}}
{{- define "n8n.basicAuthSecretName" -}}
{{- include "n8n.fullname" . }}-basic-auth
{{- end }}


{{- define "n8n.app.envvars" }}
- name: DB_TYPE
  value: postgresdb
- name: DB_POSTGRESDB_HOST
  value: n8n-postgresql
- name: DB_POSTGRESDB_PORT
  value: "5432"
- name: DB_POSTGRESDB_PASSWORD
  value: postgres
- name: DB_POSTGRESDB_USER
  valueFrom:
    secretKeyRef:
      key: postgres-password
      name: n8n-postgresql
{{- end }}

{{ define "n8n.serviceFullName" -}}
{{ with (include "n8n.fullname" .) }}{{ eq . "n8n"  | ternary "n8n-svc" . }}{{ end }}
{{- end }}