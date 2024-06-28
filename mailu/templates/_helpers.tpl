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
Mailu version. If Values.mailuVersion is not set, using Chart.AppVersion
*/}}
{{- define "mailu.version" -}}
{{- if .Values.mailuVersion -}}
{{- .Values.mailuVersion -}}
{{- else -}}
{{- .Chart.AppVersion -}}
{{- end -}}
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
Helper function to get the correct admin port.
Change was made in Mailu 2.0.22 and the port was switched from 80 to 8080.
This is for retro-compatibility purposes.
We need to perform some error handling in case the version provided is not a valid semver.
Only "master" is allowed to be used as a version other than the semver notation.
*/}}
{{- define "mailu.admin.port" -}}
{{- $semverRegex := `^v?(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)(?:-[\da-zA-Z-]+(?:\.[\da-zA-Z-]+)*)?(?:\+[\da-zA-Z-]+(?:\.[\da-zA-Z-]+)*)?$` -}}
{{- $version := (default (include "mailu.version" .) .Values.admin.image.tag) -}}
{{- if mustRegexMatch $semverRegex $version -}}
    {{- if semverCompare "<2.0.22" $version -}}
        {{- print "80" -}}
    {{- else -}}
        {{- print "8080" -}}
    {{- end -}}
{{- else -}}
    {{- print "8080" -}}
{{- end -}}
{{- end -}}

{{/* Check for deprecated values and raise an error if found (upgrade to v1.0.0) */}}
{{- define "mailu.validateValues.deprecated" -}}
{{- $oldValues := list -}}
{{- $test := "" -}}

{{- if or .Values.database.type .Values.database.roundcubeType -}}
{{- $oldValues = append $oldValues "database" -}}
{{- end -}}

{{- if kindIs "map" .Values.mail -}}
{{- $oldValues = append $oldValues "mail" -}}
{{- end -}}

{{- if kindIs "map" .Values.certmanager -}}
{{- $oldValues = append $oldValues "certmanager" -}}
{{- end -}}

{{- if .Values.front.externalService.pop3 -}}
{{- $oldValues = append $oldValues "front.externalService.pop3" -}}
{{- end -}}

{{- if .Values.front.externalService.imap -}}
{{- $oldValues = append $oldValues "front.externalService.imap" -}}
{{- end -}}

{{- if .Values.front.externalService.smtp -}}
{{- $oldValues = append $oldValues "front.externalService.smtp" -}}
{{- end -}}

{{- if .Values.front.controller -}}
    {{- if .Values.front.controller.kind -}}
    {{- $oldValues = append $oldValues "front.controller.kind" -}}
    {{- end -}}
{{- end -}}

{{- if .Values.ingress.tlsFlavor -}}
{{- $oldValues = append $oldValues "ingress.tlsFlavor" -}}
{{- end -}}

{{- if .Values.ingress.externalIngress -}}
{{- $oldValues = append $oldValues "ingress.externalIngress" -}}
{{- end -}}

{{- $oldValues := without $oldValues "" -}}
{{- $oldValue := join "\n" $oldValues -}}
{{- if $oldValues -}}
Deprecated configuration keys found in Values:
    {{- range $oldValues -}}
    {{- printf "\n    - `%s`" . -}}
    {{- end }}
Are you upgrading from a version < 1.0.0?
Please read the upgrade guide at XXX.
{{- end -}}
{{- end -}}


{{/* Compile all warnings into a single message, and call fail. */}}
{{- define "mailu.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "mailu.validateValues.deprecated" .) -}}
{{- $messages := append $messages (include "mailu.validateValues.domain" .) -}}
{{- $messages := append $messages (include "mailu.validateValues.tika" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}
{{- if $message -}}
{{- printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}


{{/* Validate values - 'domain' needs to be set */}}
{{- define "mailu.validateValues.domain" -}}
{{- if not .Values.domain }}
mailu: domain
    You need to set the domain to be used
{{- end -}}
{{- end -}}

{{/* Check if .Values.tika.enabled and .Values.tika.languages is a non-empty array.
If .Values.tika.enabled is false, then mailu.fullTextSearch should be "off".
If .Values.tika.enabled is true, and .Values.tika.languages is an empty array, throw an error.
If .Values.tika.enabled is true, and .Values.tika.languages is a non-empty array, then mailu.fullTextSearch should be all languages joined by a comma.
*/}}
{{- define "mailu.validateValues.tika" -}}
{{- if .Values.tika.enabled -}}
{{/* Check if .Values.tika.languages is an empty array */}}
{{- if not .Values.tika.languages -}}
mailu: tika
    Tika is enabled but no languages are set (tika.enabled = true, tika.languages = [])
    You need to set at least one language for Tika in tika.languages
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Check if .Values.tika.enabled is false or a comma-separated list of languages in .Values.tika.languages */}}
{{- define "mailu.fullTextSearch" -}}
{{- if .Values.tika.enabled -}}
    {{- if not .Values.tika.languages -}}
        {{- print "off" -}}
    {{- else -}}
        {{- join "," .Values.tika.languages -}}
    {{- end -}}
{{- else -}}
    {{- print "off" -}}
{{- end -}}
{{- end -}}
