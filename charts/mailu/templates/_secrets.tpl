
{{/* Return mailu secretKey */}}
{{- define "mailu.secretKey" -}}
{{- include "common.secrets.passwords.manage" (dict "secret" (include "mailu.secretName" .) "key" "secret-key" "providedValues" (list "secretKey") "length" 10 "strong" true "context" .) }}
{{- end -}}

{{/* Get the mailu secret name. */}}
{{- define "mailu.secretName" -}}
{{- include "common.secrets.name" (dict "existingSecret" .Values.existingSecret "defaultNameSuffix" "secret" "context" .) }}
{{- end -}}

{{/* Return mailu initialAccount.password */}}
{{- define "mailu.initialAccount.password" -}}
{{- include "common.secrets.passwords.manage" (dict "secret" (include "mailu.initialAccount.secretName" .) "key" (include "mailu.initialAccount.secretKey" .) "providedValues" (list "initialAccount.password") "length" 10 "strong" true "context" .) }}
{{- end -}}

{{/* Returns the mailu initialAccount secret name */}}
{{- define "mailu.initialAccount.secretName" -}}
{{- include "common.secrets.name" (dict "existingSecret" .Values.initialAccount.existingSecret "defaultNameSuffix" "initial-account" "context" .) }}
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
{{- include "common.secrets.name" (dict "existingSecret" .Values.ingress.existingSecret "defaultNameSuffix" "certificates" "context" .) }}
{{- end -}}

{{/* Get the mailu externalRelay secret */}}
{{- define "mailu.externalRelay.secretName" -}}
{{- include "common.secrets.name" (dict "existingSecret" .Values.externalRelay.existingSecret "defaultNameSuffix" "external-relay" "context" .) }}
{{- end -}}

{{/* Get the mailu externalRelay username value */}}
{{- define "mailu.externalRelay.username" -}}
{{- include "common.secrets.passwords.manage" (dict "secret" (include "mailu.externalRelay.secretName" .) "key" .Values.externalRelay.usernameKey "providedValues" (list "externalRelay.username") "length" 10 "strong" false "context" .) }}
{{- end -}}

{{/* Get the mailu externalRelay password value */}}
{{- define "mailu.externalRelay.password" -}}
{{- include "common.secrets.passwords.manage" (dict "secret" (include "mailu.externalRelay.secretName" .) "key" .Values.externalRelay.passwordKey "providedValues" (list "externalRelay.password") "length" 24 "strong" true "context" .) }}
{{- end -}}


{{/* Return mailu api.token */}}
{{- define "mailu.api.token" -}}
{{- include "common.secrets.passwords.manage" (dict "secret" (include "mailu.api.secretName" .) "key" (include "mailu.api.secretKey" .) "providedValues" (list "api.token") "length" 16 "strong" true "context" .) }}
{{- end -}}

{{/* Returns the mailu api secret name */}}
{{- define "mailu.api.secretName" -}}
{{- include "common.secrets.name" (dict "existingSecret" .Values.api.existingSecret "defaultNameSuffix" "api" "context" .) }}
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
