
{{/* Return mailu secretKey */}}
{{- define "mailu.secretKey" -}}
{{- include "mailu.secrets.passwords.manage" (dict "secret" (include "mailu.secretName" .) "key" "secret-key" "providedValues" (list "secretKey") "length" 10 "strong" true "context" .) }}
{{- end -}}

{{/* Get the mailu secret name. */}}
{{- define "mailu.secretName" -}}
{{- include "mailu.secrets.name" (dict "existingSecret" .Values.existingSecret "defaultNameSuffix" "secret" "context" .) }}
{{- end -}}

{{/* Return mailu initialAccount.password */}}
{{- define "mailu.initialAccount.password" -}}
{{- include "mailu.secrets.passwords.manage" (dict "secret" (include "mailu.initialAccount.secretName" .) "key" (include "mailu.initialAccount.secretKey" .) "providedValues" (list "initialAccount.password") "length" 10 "strong" true "context" .) }}
{{- end -}}

{{/* Returns the mailu initialAccount secret name */}}
{{- define "mailu.initialAccount.secretName" -}}
{{- include "mailu.secrets.name" (dict "existingSecret" .Values.initialAccount.existingSecret "defaultNameSuffix" "initial-account" "context" .) }}
{{- end -}}

{{/* Returns the mailu initialAccount key that contains the password in the secret */}}
{{- define "mailu.initialAccount.secretKey" -}}
{{ if .Values.initialAccount.existingSecretPasswordKey }}
{{- .Values.initialAccount.existingSecretPasswordKey -}}
{{- else -}}
{{- print "initial-account-password" -}}
{{- end -}}
{{- end -}}

{{/* Get the certificates secret name */}}
{{- define "mailu.certificatesSecretName" -}}
{{- include "mailu.secrets.name" (dict "existingSecret" .Values.ingress.existingSecret "defaultNameSuffix" "certificates" "context" .) }}
{{- end -}}

{{/* Get the mailu externalRelay secret */}}
{{- define "mailu.externalRelay.secretName" -}}
{{- include "mailu.secrets.name" (dict "existingSecret" .Values.externalRelay.existingSecret "defaultNameSuffix" "external-relay" "context" .) }}
{{- end -}}

{{/* Get the mailu externalRelay username value */}}
{{- define "mailu.externalRelay.username" -}}
{{- include "mailu.secrets.passwords.manage" (dict "secret" (include "mailu.externalRelay.secretName" .) "key" .Values.externalRelay.usernameKey "providedValues" (list "externalRelay.username") "length" 10 "strong" false "context" .) }}
{{- end -}}

{{/* Get the mailu externalRelay password value */}}
{{- define "mailu.externalRelay.password" -}}
{{- include "mailu.secrets.passwords.manage" (dict "secret" (include "mailu.externalRelay.secretName" .) "key" .Values.externalRelay.passwordKey "providedValues" (list "externalRelay.password") "length" 24 "strong" true "context" .) }}
{{- end -}}


{{/* Return mailu api.token */}}
{{- define "mailu.api.token" -}}
{{- include "mailu.secrets.passwords.manage" (dict "secret" (include "mailu.api.secretName" .) "key" (include "mailu.api.secretKey" .) "providedValues" (list "api.token") "length" 16 "strong" true "context" .) }}
{{- end -}}

{{/* Returns the mailu api secret name */}}
{{- define "mailu.api.secretName" -}}
{{- include "mailu.secrets.name" (dict "existingSecret" .Values.api.existingSecret "defaultNameSuffix" "api" "context" .) }}
{{- end -}}

{{/* Returns the mailu api key that contains the token in the secret */}}
{{- define "mailu.api.secretKey" -}}
{{ if .Values.api.existingSecretTokenKey }}
{{- .Values.api.existingSecretTokenKey -}}
{{- else -}}
{{- print "api-token" -}}
{{- end -}}
{{- end -}}

{{/* Get the mailu env vars secrets */}}
{{- define "mailu.envvars.secrets" -}}
- name: SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ template "mailu.secretName" . }}
      key: secret-key
{{- if .Values.initialAccount.enabled }}
- name: INITIAL_ADMIN_PW
  valueFrom:
    secretKeyRef:
      name: {{ include "mailu.initialAccount.secretName" . }}
      key: {{ include "mailu.initialAccount.secretKey" . }}
{{- end }}
{{- if not (eq (include "mailu.database.type" .) "sqlite") }}
- name: DB_PW
  valueFrom:
    secretKeyRef:
      name: {{ include "mailu.database.secretName" . }}
      key: {{ include "mailu.database.secretKey" . }}
{{- end }}
{{- if .Values.webmail.enabled }}
- name: ROUNDCUBE_DB_PW
  valueFrom:
    secretKeyRef:
      name: {{ include "mailu.database.roundcube.secretName" . }}
      key: {{ include "mailu.database.roundcube.secretKey" . }}
{{- end }}
{{- if .Values.externalRelay.host }}
- name: RELAYUSER
  valueFrom:
    secretKeyRef:
      name: {{ include "mailu.externalRelay.secretName" . }}
      key: {{ .Values.externalRelay.usernameKey }}
- name: RELAYPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "mailu.externalRelay.secretName" . }}
      key: {{ .Values.externalRelay.passwordKey }}
{{- end }}
{{- if .Values.api.enabled }}
- name: API_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ include "mailu.api.secretName" . }}
      key: {{ include "mailu.api.secretKey" . }}
{{- end }}
{{- end -}}

{{/*
Generate secret name.

Usage:
{{ include "mailu.secrets.name" (dict "existingSecret" .Values.path.to.the.existingSecret "defaultNameSuffix" "mySuffix" "context" $) }}

Params:
  - existingSecret - ExistingSecret/String - Optional. The path to the existing secrets in the values.yaml given by the user
    to be used instead of the default one. Allows for it to be of type String (just the secret name) for backwards compatibility.
    +info: https://github.com/bitnami/charts/tree/main/bitnami/common#existingsecret
  - defaultNameSuffix - String - Optional. It is used only if we have several secrets in the same deployment.
  - context - Dict - Required. The context for the template evaluation.
*/}}
{{- define "mailu.secrets.name" -}}
{{- $name := (include "mailu.names.fullname" .context) -}}

{{- if .defaultNameSuffix -}}
{{- $name = printf "%s-%s" $name .defaultNameSuffix | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- with .existingSecret -}}
{{- if not (typeIs "string" .) -}}
{{- with .name -}}
{{- $name = . -}}
{{- end -}}
{{- else -}}
{{- $name = . -}}
{{- end -}}
{{- end -}}

{{- printf "%s" $name -}}
{{- end -}}

{{/*
Generate secret password or retrieve one if already created.

Usage:
{{ include "mailu.secrets.passwords.manage" (dict "secret" "secret-name" "key" "keyName" "providedValues" (list "path.to.password1" "path.to.password2") "length" 10 "strong" false "chartName" "chartName" "honorProvidedValues" false "context" $) }}

Params:
  - secret - String - Required - Name of the 'Secret' resource where the password is stored.
  - key - String - Required - Name of the key in the secret.
  - providedValues - List<String> - Required - The path to the validating value in the values.yaml, e.g: "mysql.password". Will pick first parameter with a defined value.
  - length - int - Optional - Length of the generated random password.
  - strong - Boolean - Optional - Whether to add symbols to the generated random password.
  - chartName - String - Optional - Name of the chart used when said chart is deployed as a subchart.
  - context - Context - Required - Parent context.
  - failOnNew - Boolean - Optional - Default to true. If set to false, skip errors adding new keys to existing secrets.
  - skipB64enc - Boolean - Optional - Default to false. If set to true, no the secret will not be base64 encrypted.
  - skipQuote - Boolean - Optional - Default to false. If set to true, no quotes will be added around the secret.
  - honorProvidedValues - Boolean - Optional - Default to false. If set to true, the values in providedValues have higher priority than an existing secret
The order in which this function returns a secret password:
  1. Password provided via the values.yaml if honorProvidedValues = true
     (If one of the keys passed to the 'providedValues' parameter to this function is a valid path to a key in the values.yaml and has a value, the value of the first key with a value will be returned)
  2. Already existing 'Secret' resource
     (If a 'Secret' resource is found under the name provided to the 'secret' parameter to this function and that 'Secret' resource contains a key with the name passed as the 'key' parameter to this function then the value of this existing secret password will be returned)
  3. Password provided via the values.yaml if honorProvidedValues = false
     (If one of the keys passed to the 'providedValues' parameter to this function is a valid path to a key in the values.yaml and has a value, the value of the first key with a value will be returned)
  4. Randomly generated secret password
     (A new random secret password with the length specified in the 'length' parameter will be generated and returned)

*/}}
{{- define "mailu.secrets.passwords.manage" -}}

{{- $password := "" }}
{{- $subchart := "" }}
{{- $chartName := default "" .chartName }}
{{- $passwordLength := default 10 .length }}
{{- $providedPasswordKey := include "mailu.utils.getKeyFromList" (dict "keys" .providedValues "context" $.context) }}
{{- $providedPasswordValue := include "mailu.utils.getValueFromKey" (dict "key" $providedPasswordKey "context" $.context) }}
{{- $secretData := (lookup "v1" "Secret" (include "mailu.names.namespace" .context) .secret).data }}
{{- if $secretData }}
  {{- if hasKey $secretData .key }}
    {{- $password = index $secretData .key | b64dec }}
  {{- else if not (eq .failOnNew false) }}
    {{- printf "\nPASSWORDS ERROR: The secret \"%s\" does not contain the key \"%s\"\n" .secret .key | fail -}}
  {{- end -}}
{{- end }}

{{- if and $providedPasswordValue .honorProvidedValues }}
  {{- $password = tpl ($providedPasswordValue | toString) .context }}
{{- end }}

{{- if not $password }}
  {{- if $providedPasswordValue }}
    {{- $password = tpl ($providedPasswordValue | toString) .context }}
  {{- else }}
    {{- if .context.Values.enabled }}
      {{- $subchart = $chartName }}
    {{- end -}}

    {{- if not (eq .failOnNew false) }}
      {{- $requiredPassword := dict "valueKey" $providedPasswordKey "secret" .secret "field" .key "subchart" $subchart "context" $.context -}}
      {{- $requiredPasswordError := include "mailu.validations.values.single.empty" $requiredPassword -}}
      {{- $passwordValidationErrors := list $requiredPasswordError -}}
      {{- include "mailu.errors.upgrade.passwords.empty" (dict "validationErrors" $passwordValidationErrors "context" $.context) -}}
    {{- end }}

    {{- if .strong }}
      {{- $subStr := list (lower (randAlpha 1)) (randNumeric 1) (upper (randAlpha 1)) | join "_" }}
      {{- $password = randAscii $passwordLength }}
      {{- $password = regexReplaceAllLiteral "\\W" $password "@" | substr 5 $passwordLength }}
      {{- $password = printf "%s%s" $subStr $password | toString | shuffle }}
    {{- else }}
      {{- $password = randAlphaNum $passwordLength }}
    {{- end }}
  {{- end -}}
{{- end -}}
{{- if not .skipB64enc }}
{{- $password = $password | b64enc }}
{{- end -}}
{{- if .skipQuote -}}
{{- printf "%s" $password -}}
{{- else -}}
{{- printf "%s" $password | quote -}}
{{- end -}}
{{- end -}}

{{/*
Reuses the value from an existing secret, otherwise sets its value to a default value.

Usage:
{{ include "mailu.secrets.lookup" (dict "secret" "secret-name" "key" "keyName" "defaultValue" .Values.myValue "context" $) }}

Params:
  - secret - String - Required - Name of the 'Secret' resource where the password is stored.
  - key - String - Required - Name of the key in the secret.
  - defaultValue - String - Required - The path to the validating value in the values.yaml, e.g: "mysql.password". Will pick first parameter with a defined value.
  - context - Context - Required - Parent context.

*/}}
{{- define "mailu.secrets.lookup" -}}
{{- $value := "" -}}
{{- $secretData := (lookup "v1" "Secret" (include "mailu.names.namespace" .context) .secret).data -}}
{{- if and $secretData (hasKey $secretData .key) -}}
  {{- $value = index $secretData .key -}}
{{- else if .defaultValue -}}
  {{- $value = .defaultValue | toString | b64enc -}}
{{- end -}}
{{- if $value -}}
{{- printf "%s" $value -}}
{{- end -}}
{{- end -}}
