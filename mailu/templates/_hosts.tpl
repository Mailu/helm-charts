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

{{/*
Returns rspamd internal hostname.
*/}}
{{- define "mailu.hosts.rspamd" -}}
{{- printf "%s-rspamd.%s" (include "mailu.fullname" . ) (include "common.names.namespace" . ) -}}
{{- end -}}

{{/*
Returns admin internal hostname.
*/}}
{{- define "mailu.hosts.admin" -}}
{{- printf "%s-admin.%s" (include "mailu.fullname" . ) (include "common.names.namespace" . ) -}}
{{- end -}}

{{/*
Returns webmail internal hostname.
*/}}
{{- define "mailu.hosts.webmail" -}}
{{- printf "%s-webmail.%s" (include "mailu.fullname" . ) (include "common.names.namespace" . ) -}}
{{- end -}}

{{/*
Returns front internal hostname.
*/}}
{{- define "mailu.hosts.front" -}}
{{- printf "%s-front.%s" (include "mailu.fullname" . ) (include "common.names.namespace" . ) -}}
{{- end -}}

{{/*
Returns webdav internal hostname.
*/}}
{{- define "mailu.hosts.webdav" -}}
{{- printf "%s-webdav.%s" (include "mailu.fullname" . ) (include "common.names.namespace" . ) -}}
{{- end -}}
