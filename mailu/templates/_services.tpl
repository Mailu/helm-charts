{{/*
Mailu services:
- admin
- clamav
- dovecot
- fetchmail
- front
- postfix
- redis
- webmail
- rspamd
- webdav
- oletools

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
{{/* Returns clamav internal headless service name. */}}
{{- define "mailu.clamav.serviceNameHeadless" -}}
{{- printf "%s-headless" (include "mailu.clamav.serviceName" .) -}}
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
{{- printf "%s-master" (include "common.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $)) -}}
{{- end -}}
{{/* Returns redis service fqdn. */}}
{{- define "mailu.redis.serviceFqdn" -}}
{{- if .Values.externalRedis.enabled -}}
    {{- if not .Values.externalRedis.host -}}
        {{- fail "externalRedis.host must be set when externalRedis.enabled is true" -}}
    {{- else -}}
        {{- printf "%s" .Values.externalRedis.host -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s.%s.svc.%s" (include "mailu.redis.serviceName" . ) (include "common.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}
{{- end -}}
{{/* Returns redis port */}}
{{- define "mailu.redis.port" -}}
{{- if .Values.externalRedis.enabled -}}
    {{- if not .Values.externalRedis.port -}}
        {{- fail "externalRedis.port must be set when externalRedis.enabled is true" -}}
    {{- else -}}
        {{- printf "%d" (.Values.externalRedis.port | int) -}}
    {{- end -}}
{{- else -}}
    {{- printf "6379" -}}
{{- end -}}
{{- end -}}
{{/* Returns Redis database ID for the quota storage on the admin pod */}}
{{- define "mailu.redis.db.adminQuota" -}}
{{- if .Values.externalRedis.enabled -}}
    {{- printf "%d" (.Values.externalRedis.adminQuotaDbId | int) -}}
{{- else -}}
    {{- printf "1" -}}
{{- end -}}
{{- end -}}
{{/* Returns Redis database ID for the rate limit storage on the admin pod */}}
{{- define "mailu.redis.db.rateLimit" -}}
{{- if .Values.externalRedis.enabled -}}
    {{- printf "%d" (.Values.externalRedis.adminRateLimitDbId | int) -}}
{{- else -}}
    {{- printf "2" -}}
{{- end -}}
{{- end -}}


{{/* Returns webmail internal service name. */}}
{{- define "mailu.webmail.serviceName" -}}
{{- printf "%s-webmail" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns webmail internal service fqdn. */}}
{{- define "mailu.webmail.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.webmail.serviceName" . ) (include "common.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns rspamd internal service name. */}}
{{- define "mailu.rspamd.serviceName" -}}
{{- printf "%s-rspamd" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns rspamd internal service fqdn. */}}
{{- define "mailu.rspamd.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.rspamd.serviceName" . ) (include "common.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns webdav internal service name. */}}
{{- define "mailu.webdav.serviceName" -}}
{{- printf "%s-webdav" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns webdav internal service fqdn. */}}
{{- define "mailu.webdav.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.webdav.serviceName" . ) (include "common.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}


{{/* Returns oletools internal service name. */}}
{{- define "mailu.oletools.serviceName" -}}
{{- printf "%s-oletools" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns oletools internal service fqdn. */}}
{{- define "mailu.oletools.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.oletools.serviceName" . ) (include "common.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}
