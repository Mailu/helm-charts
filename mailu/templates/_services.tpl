{{/*
Mailu services:
- admin
- clamav
- dovecot
- fetchmail
- front
- postfix
- redis
- roundcube
- rspamd
- webmail
- webdav

Service name can be retrieved with `mailu.SERVICE.serviceName`
Service fqdn (within cluster) can be retrieved with `mailu.SERVICE.serviceFqdn`
*/}}

{{/* Returns admin internal service name. */}}
{{- define "mailu.admin.serviceName" -}}
{{- printf "%s-admin" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns admin internal service fqdn. */}}
{{- define "mailu.admin.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.admin.serviceName" . ) (include "common.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns clamav internal service name. */}}
{{- define "mailu.clamav.serviceName" -}}
{{- printf "%s-clamav" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns clamav internal service fqdn. */}}
{{- define "mailu.clamav.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.clamav.serviceName" . ) (include "common.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns dovecot internal service name. */}}
{{- define "mailu.dovecot.serviceName" -}}
{{- printf "%s-dovecot" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns dovecot internal service fqdn. */}}
{{- define "mailu.dovecot.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.dovecot.serviceName" . ) (include "common.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns fetchmail internal service name. */}}
{{- define "mailu.fetchmail.serviceName" -}}
{{- printf "%s-fetchmail" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns fetchmail internal service fqdn. */}}
{{- define "mailu.fetchmail.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.fetchmail.serviceName" . ) (include "common.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns front internal service name. */}}
{{- define "mailu.front.serviceName" -}}
{{- printf "%s-front" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns front internal service fqdn. */}}
{{- define "mailu.front.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.front.serviceName" . ) (include "common.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns postfix internal service name. */}}
{{- define "mailu.postfix.serviceName" -}}
{{- printf "%s-postfix" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns postfix internal service fqdn. */}}
{{- define "mailu.postfix.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.postfix.serviceName" . ) (include "common.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns redis internal service name. */}}
{{- define "mailu.redis.serviceName" -}}
{{- printf "%s-redis-headless" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns redis internal service fqdn. */}}
{{- define "mailu.redis.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.redis.serviceName" . ) (include "common.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns roundcube internal service name. */}}
{{- define "mailu.roundcube.serviceName" -}}
{{- printf "%s-roundcube" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns roundcube internal service fqdn. */}}
{{- define "mailu.roundcube.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.roundcube.serviceName" . ) (include "common.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns rspamd internal service name. */}}
{{- define "mailu.rspamd.serviceName" -}}
{{- printf "%s-rspamd" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns rspamd internal service fqdn. */}}
{{- define "mailu.rspamd.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.rspamd.serviceName" . ) (include "common.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns webmail internal service name. */}}
{{- define "mailu.webmail.serviceName" -}}
{{- printf "%s-webmail" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns webmail internal service fqdn. */}}
{{- define "mailu.webmail.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.webmail.serviceName" . ) (include "common.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns webdav internal service name. */}}
{{- define "mailu.webdav.serviceName" -}}
{{- printf "%s-webdav" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns webdav internal service fqdn. */}}
{{- define "mailu.webdav.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.webdav.serviceName" . ) (include "common.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}
