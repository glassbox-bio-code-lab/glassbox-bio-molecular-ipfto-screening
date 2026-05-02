{{- define "glassbox-ipfto-screening.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "glassbox-ipfto-screening.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "glassbox-ipfto-screening.labels" -}}
app.kubernetes.io/name: {{ include "glassbox-ipfto-screening.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: glassbox-marketplace
{{- end -}}

{{- define "glassbox-ipfto-screening.selectorLabels" -}}
app.kubernetes.io/name: {{ include "glassbox-ipfto-screening.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "glassbox-ipfto-screening.serviceAccountName" -}}
{{- if .Values.serviceAccount.name -}}
{{- .Values.serviceAccount.name -}}
{{- else -}}
{{- printf "%s-sa" (include "glassbox-ipfto-screening.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "glassbox-ipfto-screening.image" -}}
{{- if .Values.image.digest -}}
{{ printf "%s@%s" .Values.image.repository .Values.image.digest }}
{{- else -}}
{{ printf "%s:%s" .Values.image.repository .Values.image.tag }}
{{- end -}}
{{- end -}}

{{- define "glassbox-ipfto-screening.ubbagentImage" -}}
{{- if .Values.billing.ubbagent.image.digest -}}
{{ printf "%s@%s" .Values.billing.ubbagent.image.repository .Values.billing.ubbagent.image.digest }}
{{- else -}}
{{ printf "%s:%s" .Values.billing.ubbagent.image.repository .Values.billing.ubbagent.image.tag }}
{{- end -}}
{{- end -}}

{{- define "glassbox-ipfto-screening.dataMountPath" -}}
{{- if eq .Values.storage.type "gcs" -}}
{{- .Values.storage.gcs.mountPath -}}
{{- else -}}
/data
{{- end -}}
{{- end -}}
