{{- define "apps.resourceProfiles" -}}
light:
  limits: {cpu: "0.5", memory: 96Mi}
  requests: {cpu: "0.25", memory: 64Mi}
medium:
  limits: {cpu: "1", memory: 192Mi}
  requests: {cpu: "0.5", memory: 128Mi}
heavy:
  limits: {cpu: "2", memory: 768Mi}
  requests: {cpu: "1.5", memory: 512Mi}
{{- end -}}

{{/*  Resources for a container – profile or full custom block  */}}
{{- define "apps.getResources" -}}
{{- $profile := .profile | default "medium" -}}
{{- if eq $profile "custom" -}}
  {{- /* Custom block must be supplied in the chart consumer */}}
  {{- if not .custom -}}
    {{- fail "custom profile selected but .custom block is missing" -}}
  {{- end -}}
  {{- toYaml .custom | nindent 0 -}}
{{- else -}}
  {{- $profiles := (include "apps.resourceProfiles" .) | fromYaml -}}
{{- toYaml (get $profiles $profile) -}}
{{- end -}}
{{- end -}}