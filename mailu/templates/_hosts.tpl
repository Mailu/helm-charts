{{/*
Returns dovecot internal hostname.
*/}}
{{- define "mailu.hosts.dovecot" -}}
{{- printf "%s-dovecot.%s" (include "mailu.fullname" . ) (include "common.names.namespace" . ) -}}
{{- end -}}

{{/*
Returns postfix internal hostname.
*/}}
{{- define "mailu.hosts.postfix" -}}
{{- printf "%s-postfix.%s" (include "mailu.fullname" . ) (include "common.names.namespace" . ) -}}
{{- end -}}

{{/*
Returns redis internal hostname.
*/}}
{{- define "mailu.hosts.redis" -}}
{{- printf "%s-redis.%s" (include "mailu.fullname" . ) (include "common.names.namespace" . ) -}}
{{- end -}}
