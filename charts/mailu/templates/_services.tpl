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
- tika

Service name can be retrieved with `mailu.SERVICE.serviceName`
Service fqdn (within cluster) can be retrieved with `mailu.SERVICE.serviceFqdn`
*/}}

{{/* Returns admin internal service name. */}}
{{- define "mailu.admin.serviceName" -}}
{{- printf "%s-admin" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns admin internal service fqdn. */}}
{{- define "mailu.admin.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.admin.serviceName" . ) (include "mailu.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns clamav internal service name. */}}
{{- define "mailu.clamav.serviceName" -}}
{{- printf "%s-clamav" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns clamav internal service fqdn. */}}
{{- define "mailu.clamav.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.clamav.serviceName" . ) (include "mailu.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
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
{{- printf "%s.%s.svc.%s" (include "mailu.dovecot.serviceName" . ) (include "mailu.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns fetchmail internal service name. */}}
{{- define "mailu.fetchmail.serviceName" -}}
{{- printf "%s-fetchmail" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns fetchmail internal service fqdn. */}}
{{- define "mailu.fetchmail.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.fetchmail.serviceName" . ) (include "mailu.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns front internal service name. */}}
{{- define "mailu.front.serviceName" -}}
{{- printf "%s-front" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns front internal service fqdn. */}}
{{- define "mailu.front.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.front.serviceName" . ) (include "mailu.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns postfix internal service name. */}}
{{- define "mailu.postfix.serviceName" -}}
{{- printf "%s-postfix" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns postfix internal service fqdn. */}}
{{- define "mailu.postfix.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.postfix.serviceName" . ) (include "mailu.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns redis internal service name. */}}
{{- define "mailu.redis.serviceName" -}}
{{- printf "%s-master" (include "mailu.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $)) -}}
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
    {{- printf "%s.%s.svc.%s" (include "mailu.redis.serviceName" . ) (include "mailu.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
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
{{- printf "%s.%s.svc.%s" (include "mailu.webmail.serviceName" . ) (include "mailu.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns rspamd internal service name. */}}
{{- define "mailu.rspamd.serviceName" -}}
{{- printf "%s-rspamd" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns rspamd internal service fqdn. */}}
{{- define "mailu.rspamd.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.rspamd.serviceName" . ) (include "mailu.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns webdav internal service name. */}}
{{- define "mailu.webdav.serviceName" -}}
{{- printf "%s-webdav" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns webdav internal service fqdn. */}}
{{- define "mailu.webdav.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.webdav.serviceName" . ) (include "mailu.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}


{{/* Returns oletools internal service name. */}}
{{- define "mailu.oletools.serviceName" -}}
{{- printf "%s-oletools" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns oletools internal service fqdn. */}}
{{- define "mailu.oletools.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.oletools.serviceName" . ) (include "mailu.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}

{{/* Returns tika internal service name. */}}
{{- define "mailu.tika.serviceName" -}}
{{- printf "%s-tika" (include "mailu.fullname" .) -}}
{{- end -}}
{{/* Returns tika internal service fqdn. */}}
{{- define "mailu.tika.serviceFqdn" -}}
{{- printf "%s.%s.svc.%s" (include "mailu.tika.serviceName" . ) (include "mailu.names.namespace" . ) (include "mailu.clusterDomain" . ) -}}
{{- end -}}


{{/* Combine the enabled ports that should be exposed into a comma-separated string */}}
{{- define "mailu.enabledPorts" -}}
{{- $enabledPorts := list -}}

{{- if .Values.ingress.enabled -}}
    {{- $enabledPorts = append $enabledPorts "80" -}}
    {{- $enabledPorts = append $enabledPorts "443" -}}
{{- end -}}

{{- if .Values.front.hostPort.enabled -}}
    {{- $enabledPorts = append $enabledPorts "4190" -}}
{{- end -}}

{{- if .Values.front.externalService.enabled -}}
    {{- if .Values.front.externalService.ports.pop3 -}}
        {{- $enabledPorts = append $enabledPorts "110" -}}
    {{- end -}}
    {{- if .Values.front.externalService.ports.pop3s -}}
        {{- $enabledPorts = append $enabledPorts "995" -}}
    {{- end -}}
    {{- if .Values.front.externalService.ports.imap -}}
        {{- $enabledPorts = append $enabledPorts "143" -}}
    {{- end -}}
    {{- if .Values.front.externalService.ports.imaps -}}
        {{- $enabledPorts = append $enabledPorts "993" -}}
    {{- end -}}
    {{- if .Values.front.externalService.ports.smtp -}}
        {{- $enabledPorts = append $enabledPorts "25" -}}
    {{- end -}}
    {{- if .Values.front.externalService.ports.smtps -}}
        {{- $enabledPorts = append $enabledPorts "465" -}}
    {{- end -}}
    {{- if .Values.front.externalService.ports.submission -}}
        {{- $enabledPorts = append $enabledPorts "587" -}}
    {{- end -}}
    {{- if .Values.front.externalService.ports.manageSieve -}}
        {{- $enabledPorts = append $enabledPorts "4190" -}}
    {{- end -}}
{{- end -}}

{{- $enabledPortsString := join "," $enabledPorts -}}
{{- printf "%s" $enabledPortsString -}}
{{- end -}}

{{/* Combine the ports for which PROXY protocol should be enabled into a comma-separated string */}}
{{- define "mailu.proxyProtocolPorts" -}}
{{- $proxyProtocolPorts := list -}}

{{- if .Values.front.externalService.enabled -}}
    {{- if and .Values.front.externalService.ports.pop3 .Values.ingress.proxyProtocol.pop3 -}}
        {{- $proxyProtocolPorts = append $proxyProtocolPorts "110" -}}
    {{- end -}}
    {{- if and .Values.front.externalService.ports.pop3s .Values.ingress.proxyProtocol.pop3s -}}
        {{- $proxyProtocolPorts = append $proxyProtocolPorts "995" -}}
    {{- end -}}
    {{- if and .Values.front.externalService.ports.imap .Values.ingress.proxyProtocol.imap -}}
        {{- $proxyProtocolPorts = append $proxyProtocolPorts "143" -}}
    {{- end -}}
    {{- if and .Values.front.externalService.ports.imaps .Values.ingress.proxyProtocol.imaps -}}
        {{- $proxyProtocolPorts = append $proxyProtocolPorts "993" -}}
    {{- end -}}
    {{- if and .Values.front.externalService.ports.smtp .Values.ingress.proxyProtocol.smtp -}}
        {{- $proxyProtocolPorts = append $proxyProtocolPorts "25" -}}
    {{- end -}}
    {{- if and .Values.front.externalService.ports.smtps .Values.ingress.proxyProtocol.smtps -}}
        {{- $proxyProtocolPorts = append $proxyProtocolPorts "465" -}}
    {{- end -}}
    {{- if and .Values.front.externalService.ports.submission .Values.ingress.proxyProtocol.submission -}}
        {{- $proxyProtocolPorts = append $proxyProtocolPorts "587" -}}
    {{- end -}}
    {{- if and .Values.front.externalService.ports.manageSieve .Values.ingress.proxyProtocol.manageSieve -}}
        {{- $proxyProtocolPorts = append $proxyProtocolPorts "4190" -}}
    {{- end -}}
{{- end -}}

{{- $proxyProtocolPortsString := join "," $proxyProtocolPorts -}}
{{/* if any ports are enabled and .ingress.realIpFrom is empty, fail */}}
{{- if and (gt (len $proxyProtocolPorts) 0) (not .Values.ingress.realIpFrom) -}}
    {{- fail "PROXY protocol is enabled for some ports, but ingress.realIpFrom is not set" -}}
{{- end -}}

{{/* if any ports are enabled and .ingress.realIpHeader is set, fail */}}
{{- if and (gt (len $proxyProtocolPorts) 0) .Values.ingress.realIpHeader -}}
    {{- fail "PROXY protocol is enabled for some ports, but ingress.realIpHeader is set" -}}
{{- end -}}

{{- printf "%s" $proxyProtocolPortsString -}}
{{- end -}}
