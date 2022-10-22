{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mailu.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mailu.fullname" -}}
{{- include "common.names.fullname" . -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mailu.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get the cluster domain name or default to cluster.local
*/}}
{{- define "mailu.clusterDomain" -}}
{{- if .Values.clusterDomain -}}
    {{- .Values.clusterDomain -}}
{{- else -}}
    {{- print "cluster.local" -}}
{{- end -}}
{{- end -}}

{{/*
Get MailU domain name or throw an error if not set
*/}}
{{- define "mailu.domain" -}}
{{- if .Values.domain -}}
{{- .Values.domain -}}
{{- else -}}
{{- fail "You must set a domain name for Mailu (`domain:`)" -}}
{{- end -}}
{{- end -}}

{{/* Get the MailU TLS Flavor */}}
{{- define "mailu.tlsFlavor" -}}
{{- if .Values.ingress.tlsFlavorOverride -}}
{{- .Values.ingress.tlsFlavorOverride -}}
{{- else -}}
    {{- if .Values.ingress.tls -}}
        {{- print "cert" -}}
    {{- else -}}
        {{- print "notls" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*


{{/*

# {{/*
# Compile all warnings into a single message, and call fail.
# */}}
# {{- define "mailu.validateValues" -}}
# {{- $messages := list -}}
# {{- $messages := append $messages (include "mailu.validateValues.domain" .) -}}
# # {{- $messages := append $messages (include "postgresql.validateValues.psp" .) -}}
# # {{- $messages := append $messages (include "postgresql.validateValues.tls" .) -}}
# {{- $messages := without $messages "" -}}
# {{- $message := join "\n" $messages -}}

# {{- if $message -}}
# {{- printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
# {{- end -}}
# {{- end -}}

# {{/*
# Validate values - 'domain' needs to be set
# */}}
# {{- define "mailu.validateValues.domain" -}}
# {{- if not .Values.domain }}
# mailu: domain
#     You need to set the domain to be used
# {{- end -}}
# {{- end -}}.
