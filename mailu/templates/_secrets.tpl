
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
