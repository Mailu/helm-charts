{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mailu.name" -}}
{{- include "mailu.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mailu.fullname" -}}
{{- include "mailu.names.fullname" . -}}
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


{{/* If .Values.dovecot.serviceMonitor.enabled is true and .Values.dovecot.overrides is an empty object, throw an alert message as it would not work */}}
{{- define "mailu.dovecot.validateServiceMonitor" -}}
{{- if and .Values.dovecot.serviceMonitor.enabled (eq (len .Values.dovecot.overrides) 0) -}}
mailu: dovecot
    You need to set at least one override for Dovecot's service monitor
{{- end -}}
{{- end -}}

{{/*
Gets a value from .Values given
Usage:
{{ include "mailu.utils.getValueFromKey" (dict "key" "path.to.key" "context" $) }}
*/}}
{{- define "mailu.utils.getValueFromKey" -}}
{{- $splitKey := splitList "." .key -}}
{{- $value := "" -}}
{{- $latestObj := $.context.Values -}}
{{- range $splitKey -}}
  {{- if not $latestObj -}}
    {{- printf "please review the entire path of '%s' exists in values" $.key | fail -}}
  {{- end -}}
  {{- $value = ( index $latestObj . ) -}}
  {{- $latestObj = $value -}}
{{- end -}}
{{- printf "%v" (default "" $value) -}}
{{- end -}}

{{/*
Returns first .Values key with a defined value or first of the list if all non-defined
Usage:
{{ include "mailu.utils.getKeyFromList" (dict "keys" (list "path.to.key1" "path.to.key2") "context" $) }}
*/}}
{{- define "mailu.utils.getKeyFromList" -}}
{{- $key := first .keys -}}
{{- $reverseKeys := reverse .keys }}
{{- range $reverseKeys }}
  {{- $value := include "mailu.utils.getValueFromKey" (dict "key" . "context" $.context ) }}
  {{- if $value -}}
    {{- $key = . }}
  {{- end -}}
{{- end -}}
{{- printf "%s" $key -}}
{{- end -}}

{{/*
Build env var name given a field
Usage:
{{ include "mailu.utils.fieldToEnvVar" dict "field" "my-password" }}
*/}}
{{- define "mailu.utils.fieldToEnvVar" -}}
  {{- $fieldNameSplit := splitList "-" .field -}}
  {{- $upperCaseFieldNameSplit := list -}}

  {{- range $fieldNameSplit -}}
    {{- $upperCaseFieldNameSplit = append $upperCaseFieldNameSplit ( upper . ) -}}
  {{- end -}}

  {{ join "_" $upperCaseFieldNameSplit }}
{{- end -}}

{{/*
Print instructions to get a secret value.
Usage:
{{ include "mailu.utils.secret.getvalue" (dict "secret" "secret-name" "field" "secret-value-field" "context" $) }}
*/}}
{{- define "mailu.utils.secret.getvalue" -}}
{{- $varname := include "mailu.utils.fieldToEnvVar" . -}}
export {{ $varname }}=$(kubectl get secret --namespace {{ include "mailu.names.namespace" .context | quote }} {{ .secret }} -o jsonpath="{.data.{{ .field }}}" | base64 -d)
{{- end -}}

{{/*
Validate a value must not be empty.

Usage:
{{ include "mailu.validations.value.empty" (dict "valueKey" "mariadb.password" "secret" "secretName" "field" "my-password" "subchart" "subchart" "context" $) }}

Validate value params:
  - valueKey - String - Required. The path to the validating value in the values.yaml, e.g: "mysql.password"
  - secret - String - Optional. Name of the secret where the validating value is generated/stored, e.g: "mysql-passwords-secret"
  - field - String - Optional. Name of the field in the secret data, e.g: "mysql-password"
  - subchart - String - Optional - Name of the subchart that the validated password is part of.
*/}}
{{- define "mailu.validations.values.single.empty" -}}
  {{- $value := include "mailu.utils.getValueFromKey" (dict "key" .valueKey "context" .context) }}
  {{- $subchart := ternary "" (printf "%s." .subchart) (empty .subchart) }}

  {{- if not $value -}}
    {{- $varname := "my-value" -}}
    {{- $getCurrentValue := "" -}}
    {{- if and .secret .field -}}
      {{- $varname = include "mailu.utils.fieldToEnvVar" . -}}
      {{- $getCurrentValue = printf " To get the current value:\n\n        %s\n" (include "mailu.utils.secret.getvalue" .) -}}
    {{- end -}}
    {{- printf "\n    '%s' must not be empty, please add '--set %s%s=$%s' to the command.%s" .valueKey $subchart .valueKey $varname $getCurrentValue -}}
  {{- end -}}
{{- end -}}
