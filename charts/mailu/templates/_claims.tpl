{{/* Admin pod persistent volume claim name */}}
{{ define "mailu.admin.claimName" }}
{{- .Values.persistence.single_pvc | ternary (include "mailu.claimName" .) .Values.admin.persistence.claimNameOverride | default (printf "%s-admin" (include "mailu.fullname" .)) -}}
{{- end -}}

{{/* Dovecot pod persistent volume claim name */}}
{{ define "mailu.dovecot.claimName" }}
{{- .Values.persistence.single_pvc | ternary (include "mailu.claimName" .) .Values.dovecot.persistence.claimNameOverride | default (printf "%s-dovecot" (include "mailu.fullname" .)) -}}
{{- end -}}

{{/* Postfix pod persistent volume claim name */}}
{{ define "mailu.postfix.claimName" }}
{{- .Values.persistence.single_pvc | ternary (include "mailu.claimName" .) .Values.postfix.persistence.claimNameOverride | default (printf "%s-postfix" (include "mailu.fullname" .)) -}}
{{- end -}}

{{/* Rspamd pod persistent volume claim name */}}
{{ define "mailu.rspamd.claimName" }}
{{- .Values.persistence.single_pvc | ternary (include "mailu.claimName" .) .Values.rspamd.persistence.claimNameOverride | default (printf "%s-rspamd" (include "mailu.fullname" .)) -}}
{{- end -}}

{{/* Roundcube pod persistent volume claim name */}}
{{ define "mailu.webmail.claimName" }}
{{- .Values.persistence.single_pvc | ternary (include "mailu.claimName" .) .Values.webmail.persistence.claimNameOverride | default (printf "%s-webmail" (include "mailu.fullname" .)) -}}
{{- end -}}

{{/* Fetchmail pod persistent volume claim name */}}
{{ define "mailu.fetchmail.claimName" }}
{{- .Values.persistence.single_pvc | ternary (include "mailu.claimName" .) .Values.fetchmail.persistence.claimNameOverride | default (printf "%s-fetchmail" (include "mailu.fullname" .)) -}}
{{- end -}}

{{/* Webdav pod persistent volume claim name */}}
{{ define "mailu.webdav.claimName" }}
{{- .Values.persistence.single_pvc | ternary (include "mailu.claimName" .) .Values.webdav.persistence.claimNameOverride | default (printf "%s-webdav" (include "mailu.fullname" .)) -}}
{{- end -}}
