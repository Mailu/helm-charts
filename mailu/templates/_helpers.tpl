{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mailu.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mailu.fullname" -}}
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
Create the claimName: existingClaim if provided, otherwise claimNameOverride if provided, otherwise mailu-storage (or other fullname if overriden)
*/}}
{{- define "mailu.claimName" -}}
{{- if .Values.persistence.existingClaim -}}
{{- .Values.persistence.existingClaim -}}
{{- else if .Values.persistence.claimNameOverride -}}
{{- .Values.persistence.claimNameOverride -}}
{{- else -}}
{{ include "mailu.fullname" . }}-storage
{{- end -}}
{{- end -}}


{{- define "mailu.deployClaimName" -}}
{{- $deployValues := index .Values .deploy }}
{{- if $deployValues.persistence.claimEnabled -}}
{{- if $deployValues.persistence.existingClaim -}}
{{- $deployValues.persistence.existingClaim -}}
{{- else if $deployValues.persistence.claimNameOverride -}}
{{- $deployValues.persistence.claimNameOverride -}}
{{- else -}}
{{ include "mailu.fullname" . }}-{{.deploy}}-storage
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mailu.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "mailu.labels" -}}
app.kubernetes.io/name: {{ include "mailu.name" . }}
helm.sh/chart: {{ include "mailu.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Certmanager secretName template
*/}}
{{- define "mailu.certificateSecretName" -}}
{{- if .Values.certificateSecretName -}}
{{- .Values.certificateSecretName | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $fullname := include "mailu.fullname" . -}}
{{- printf "%s-%s" $fullname "certificates" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
