{{/*
Admin pod persistent volume claim name
*/}}
{{ define "mailu.admin.claimName" }}
{{- .Values.persistence.single_pvc | ternary (include "mailu.claimName" .) .Values.admin.persistence.claimNameOverride | default (printf "%s-admin" (include "mailu.fullname" .)) }}
{{- end }}

{{/*
Clamav pod persistent volume claim name
*/}}
{{ define "mailu.clamav.claimName" }}
{{- .Values.persistence.single_pvc | ternary (include "mailu.claimName" .) .Values.clamav.persistence.claimNameOverride | default (printf "%s-clamav" (include "mailu.fullname" .)) }}
{{- end }}

{{/*
Dovecot pod persistent volume claim name
*/}}
{{ define "mailu.dovecot.claimName" }}
{{- .Values.persistence.single_pvc | ternary (include "mailu.claimName" .) .Values.dovecot.persistence.claimNameOverride | default (printf "%s-dovecot" (include "mailu.fullname" .)) }}
{{- end }}

{{/*
Postfix pod persistent volume claim name
*/}}
{{ define "mailu.postfix.claimName" }}
{{- .Values.persistence.single_pvc | ternary (include "mailu.claimName" .) .Values.postfix.persistence.claimNameOverride | default (printf "%s-postfix" (include "mailu.fullname" .)) }}
{{- end }}

{{ define "mailu.rspamdClamavClaimName"}}
{{- .Values.persistence.single_pvc | ternary (include "mailu.claimName" .) .Values.rspamd_clamav_persistence.claimNameOverride | default (printf "%s-rspamd-clamav" (include "mailu.fullname" .)) }}
{{- end }}
