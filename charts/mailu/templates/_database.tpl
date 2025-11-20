{{/* Returns the database type (sqlite/mysql/postgresql) */}}
{{- define "mailu.database.type" -}}
{{- if or .Values.postgresql.enabled (and .Values.externalDatabase.enabled (eq .Values.externalDatabase.type "postgresql")) -}}
    {{- print "postgresql" }}
{{- else if or .Values.mariadb.enabled (and .Values.externalDatabase.enabled (eq .Values.externalDatabase.type "mysql")) -}}
    {{- print "mysql" }}
{{- else if not .Values.externalDatabase.enabled -}}
    {{- print "sqlite" }}
{{- else -}}
    {{ fail "Invalid database type. Use correct database type (mysql/postgresql) if using external database." }}
{{- end -}}
{{- end -}}

{{/* Returns the database hostname */}}
{{- define "mailu.database.host" -}}
{{- if .Values.mariadb.enabled -}}
    {{- template "mariadb.primary.fullname" .Subcharts.mariadb -}}
{{- else if .Values.postgresql.enabled -}}
    {{- template "postgresql.v1.primary.fullname" .Subcharts.postgresql -}}
{{- else if .Values.externalDatabase.enabled -}}
    {{- .Values.externalDatabase.host -}}
{{- end -}}
{{- end -}}

{{/* Return the database port */}}
{{- define "mailu.database.port" -}}
{{- if .Values.mariadb.enabled -}}
    {{- print "3306" -}}
{{- else if .Values.postgresql.enabled -}}
    {{- print "5432" -}}
{{- else if .Values.externalDatabase.enabled -}}
    {{- if eq .Values.externalDatabase.type "mysql" -}}
        {{- .Values.externalDatabase.port | default "3306" -}}
    {{- else if eq .Values.externalDatabase.type "postgresql" -}}
        {{- .Values.externalDatabase.port | default "5432" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/* Return the database name for Mailu */}}
{{- define "mailu.database.name" -}}
{{- if .Values.mariadb.enabled -}}
    {{- .Values.mariadb.auth.database | quote -}}
{{- else if .Values.postgresql.enabled -}}
    {{- if .Values.global.postgresql -}}
        {{- if .Values.global.postgresql.auth -}}
            {{- coalesce .Values.global.postgresql.auth.database .Values.postgresql.auth.database | quote -}}
        {{- else -}}
            {{- .Values.postgresql.auth.database | quote -}}
        {{- end -}}
    {{- else -}}
        {{- .Values.postgresql.auth.database | quote -}}
    {{- end -}}
{{- else -}}
    {{- (include "mailu.database.external.database" .) | quote }}
{{- end -}}
{{- end -}}

{{/* Return the database username for Mailu */}}
{{- define "mailu.database.username" -}}
{{- if .Values.mariadb.enabled -}}
    {{- .Values.mariadb.auth.username | quote }}
{{- else if .Values.postgresql.enabled -}}
    {{- if .Values.global.postgresql }}
        {{- if .Values.global.postgresql.auth }}
            {{- coalesce .Values.global.postgresql.auth.username .Values.postgresql.auth.username | quote -}}
        {{- else -}}
            {{- .Values.postgresql.auth.username | quote -}}
        {{- end -}}
    {{- else -}}
        {{- .Values.postgresql.auth.username | quote -}}
    {{- end -}}
{{- else }}
    {{- (include "mailu.database.external.username" .) | quote }}
{{- end -}}
{{- end -}}

{{/* Return the name of the secret for the external database */}}
{{- define "mailu.database.external.secretName" -}}
{{ include "mailu.secrets.name" (dict "existingSecret" .Values.externalDatabase.existingSecret "defaultNameSuffix" "externaldb" "context" .) }}
{{- end -}}

{{/* Return the name of the external database */}}
{{- define "mailu.database.external.database" -}}
{{ (include "mailu.secrets.lookup" (dict "secret" (include "mailu.database.external.secretName" .) "key" .Values.externalDatabase.existingSecretDatabaseKey "defaultValue" .Values.externalDatabase.database "context" .))  | toString | b64dec }}
{{- end -}}

{{/* Return the username of the external database */}}
{{- define "mailu.database.external.username" -}}
{{ (include "mailu.secrets.lookup" (dict "secret" (include "mailu.database.external.secretName" .) "key" .Values.externalDatabase.existingSecretUsernameKey "defaultValue" .Values.externalDatabase.username "context" .))  | toString | b64dec }}
{{- end -}}

{{/* Return the password of the external database */}}
{{- define "mailu.database.external.password" -}}
{{ (include "mailu.secrets.lookup" (dict "secret" (include "mailu.database.external.secretName" .) "key" .Values.externalDatabase.existingSecretPasswordKey "defaultValue" .Values.externalDatabase.password "context" .))  | toString | b64dec }}
{{- end -}}

{{/* Return the name of the mailu database secret with its credentials */}}
{{- define "mailu.database.secretName" -}}
{{- if .Values.mariadb.enabled -}}
    {{- template "mariadb.secretName" .Subcharts.mariadb -}}
{{- else if .Values.postgresql.enabled -}}
    {{- template "postgresql.v1.secretName" .Subcharts.postgresql -}}
{{- else if ne (include "mailu.database.type" .) "sqlite" -}}
    {{- if .Values.externalDatabase.enabled -}}
        {{- include "mailu.database.external.secretName" . -}}
    {{- end -}}
{{- else -}}
    {{- print "" -}}
{{- end -}}
{{- end -}}

{{/* Return the database password key */}}
{{- define "mailu.database.secretKey" -}}
{{- if .Values.mariadb.enabled -}}
    {{- print "mariadb-password" -}}
{{- else if .Values.postgresql.enabled -}}
    {{- print "password" -}}
{{- else -}}
    {{- if .Values.externalDatabase.enabled -}}
        {{- .Values.externalDatabase.existingSecretPasswordKey -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/* Return the database name for Roundcube */}}
{{- define "mailu.database.roundcube.name" -}}
{{- .Values.global.database.roundcube.database }}
{{- end -}}

{{/* Return the database username for Roundcube */}}
{{- define "mailu.database.roundcube.username" -}}
{{- .Values.global.database.roundcube.username }}
{{- end -}}

{{/* Return the database password for Roundcube */}}
{{- define "mailu.database.roundcube.password" -}}
{{- include "mailu.secrets.passwords.manage" (dict "secret" (include "mailu.database.roundcube.secretName" .) "key" (include "mailu.database.roundcube.secretKey" .) "providedValues" (list "global.database.roundcube.password" "database.mysql.roundcubePassword" "database.postgresql.roundcubePassword") "length" 10 "strong" true "context" .) }}
{{- end -}}

{{/* Return the name of the roundcube database secret */}}
{{- define "mailu.database.roundcube.secretName" -}}
{{- if .Values.global.database.roundcube.existingSecret -}}
    {{- .Values.global.database.roundcube.existingSecret }}
{{- else -}}
    {{- print "mailu-roundcube" }}
{{- end -}}
{{- end -}}

{{- define "mariadb.mailu.database.roundcube.secretName" -}}
{{- include "mailu.database.roundcube.secretName" -}}
{{- end -}}


{{/* Return the roundcube database password key */}}
{{- define "mailu.database.roundcube.secretKey" -}}
{{- if .Values.global.database.roundcube.existingSecret -}}
    {{- if .Values.global.database.roundcube.existingSecretPasswordKey -}}
        {{- .Values.global.database.roundcube.existingSecretPasswordKey }}
    {{- else -}}
        {{- print "roundcube-db-password" }}
    {{- end -}}
{{- else -}}
    {{- print "roundcube-db-password" }}
{{- end -}}
{{- end -}}
