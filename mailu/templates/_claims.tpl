{{/* Admin pod persistent volume claim name */}}
{{ define "mailu.admin.claimName" }}
{{- if .Values.persistence.single_pvc -}}
{{- (include "mailu.claimName" .) -}}
{{- else if .Values.admin.persistence.existingClaim -}}
{{- .Values.admin.persistence.existingClaim -}}
{{- else if .Values.admin.persistence.claimNameOverride -}}
{{- .Values.admin.persistence.claimNameOverride -}}
{{- else -}}
{{ printf "%s-admin" (include "mailu.fullname" .) }}
{{- end -}}
{{- end -}}

{{/* Dovecot pod persistent volume claim name */}}
{{ define "mailu.dovecot.claimName" }}
{{- if .Values.persistence.single_pvc -}}
{{- (include "mailu.claimName" .) -}}
{{- else if .Values.dovecot.persistence.existingClaim -}}
{{- .Values.dovecot.persistence.existingClaim -}}
{{- else if .Values.dovecot.persistence.claimNameOverride -}}
{{- .Values.dovecot.persistence.claimNameOverride -}}
{{- else -}}
{{ printf "%s-dovecot" (include "mailu.fullname" .) }}
{{- end -}}
{{- end -}}

{{/* Postfix pod persistent volume claim name */}}
{{ define "mailu.postfix.claimName" }}
{{- if .Values.persistence.single_pvc -}}
{{- (include "mailu.claimName" .) -}}
{{- else if .Values.postfix.persistence.existingClaim -}}
{{- .Values.postfix.persistence.existingClaim -}}
{{- else if .Values.postfix.persistence.claimNameOverride -}}
{{- .Values.postfix.persistence.claimNameOverride -}}
{{- else -}}
{{ printf "%s-postfix" (include "mailu.fullname" .) }}
{{- end -}}
{{- end -}}

{{/* Rspamd pod persistent volume claim name */}}
{{ define "mailu.rspamd.claimName" }}
{{- if .Values.persistence.single_pvc -}}
{{- (include "mailu.claimName" .) -}}
{{- else if .Values.rspamd.persistence.existingClaim -}}
{{- .Values.rspamd.persistence.existingClaim -}}
{{- else if .Values.rspamd.persistence.claimNameOverride -}}
{{- .Values.rspamd.persistence.claimNameOverride -}}
{{- else -}}
{{ printf "%s-rspamd" (include "mailu.fullname" .) }}
{{- end -}}
{{- end -}}

{{/* Roundcube pod persistent volume claim name */}}
{{ define "mailu.webmail.claimName" }}
{{- if .Values.persistence.single_pvc -}}
{{- (include "mailu.claimName" .) -}}
{{- else if .Values.webmail.persistence.existingClaim -}}
{{- .Values.webmail.persistence.existingClaim -}}
{{- else if .Values.webmail.persistence.claimNameOverride -}}
{{- .Values.webmail.persistence.claimNameOverride -}}
{{- else -}}
{{ printf "%s-webmail" (include "mailu.fullname" .) }}
{{- end -}}
{{- end -}}

{{/* Fetchmail pod persistent volume claim name */}}
{{ define "mailu.fetchmail.claimName" }}
{{- if .Values.persistence.single_pvc -}}
{{- (include "mailu.claimName" .) -}}
{{- else if .Values.fetchmail.persistence.existingClaim -}}
{{- .Values.fetchmail.persistence.existingClaim -}}
{{- else if .Values.fetchmail.persistence.claimNameOverride -}}
{{- .Values.fetchmail.persistence.claimNameOverride -}}
{{- else -}}
{{ printf "%s-fetchmail" (include "mailu.fullname" .) }}
{{- end -}}
{{- end -}}

{{/* Webdav pod persistent volume claim name */}}
{{ define "mailu.webdav.claimName" }}
{{- if .Values.persistence.single_pvc -}}
{{- (include "mailu.claimName" .) -}}
{{- else if .Values.webdav.persistence.existingClaim -}}
{{- .Values.webdav.persistence.existingClaim -}}
{{- else if .Values.webdav.persistence.claimNameOverride -}}
{{- .Values.webdav.persistence.claimNameOverride -}}
{{- else -}}
{{ printf "%s-webdav" (include "mailu.fullname" .) }}
{{- end -}}
{{- end -}}
