{{/*
Expand the name of the chart.
*/}}
{{- define "hello-world-module.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hello-world-module.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create name for fields that have suffix with 7 charts, for example "-volume" or "-config"
We truncate at 56 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hello-world-module.namewithsuffix" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 56  | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 56 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 56 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "hello-world-module.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hello-world-module.labels" -}}
helm.sh/chart: {{ include "hello-world-module.chart" . }}
{{ include "hello-world-module.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hello-world-module.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hello-world-module.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "hello-world-module.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hello-world-module.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
processPodSecurityContext skips certain keys in Values.podSecurityContext
map if running on openshift.
*/}}
{{- define "fybrik.processPodSecurityContext" }}
{{- $podSecurityContext := deepCopy .podSecurityContext }}
{{- if .context.Capabilities.APIVersions.Has "security.openshift.io/v1" }}
  {{- range $k, $v := .podSecurityContext }}
    {{- if or (eq $k "runAsUser") (eq $k "seccompProfile") }}
      {{- $_ := unset $podSecurityContext $k }}
    {{- end }}
   {{- end }}
{{- end }}
{{- $podSecurityContext | toYaml }}
{{- end }}
