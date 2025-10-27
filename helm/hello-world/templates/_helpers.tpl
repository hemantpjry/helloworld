{{- define "hello-world.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "hello-world.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end }}
