{{/*
Admin pod persistent volume claim name
*/}}
{{ define "mailu.admin.claimName"}}
{{- .Values.persistence.single_pvc | ternary (include "mailu.claimName" .) .Values.admin.persistence.claimNameOverride | default (printf "%s-admin" (include "mailu.fullname" .)) }}
{{- end }}

{{/*
Clamav pod persistent volume claim name
*/}}
{{ define "mailu.clamav.claimName"}}
{{- .Values.persistence.single_pvc | ternary (include "mailu.claimName" .) .Values.clamav.persistence.claimNameOverride | default (printf "%s-clamav" (include "mailu.fullname" .)) }}
{{- end }}
