{{/*
HPA Strategy Behavior Block
*/}}

{{- define "autoscaling.strategies" -}}
passive:
  stabilizationWindow: 300
  percentPolicy:
    policyType: Percent
    policyValue: 20
    policyPeriod: 90
  podPolicy:
    policyType: Pods
    policyValue: 1
    policyPeriod: 180

balanced:
  stabilizationWindow: 240
  percentPolicy:
    policyType: Percent
    policyValue: 25
    policyPeriod: 60
  podPolicy:
    policyType: Pods
    policyValue: 2
    policyPeriod: 90

aggressive:
  stabilizationWindow: 120
  percentPolicy:
    policyType: Percent
    policyValue: 80
    policyPeriod: 30
  podPolicy:
    policyType: Pods
    policyValue: 10
    policyPeriod: 15
{{- end -}}

{{- define "autoscaling.renderPolicy" -}}
- type: {{ .policyType }}
  value: {{ .policyValue }}
  periodSeconds: {{ .policyPeriod }}
{{- end -}}

{{- /*  Render the down‑scale part of the HPA. */ -}}
{{- define "autoscaling.behaviorDownscale" }}
scaleDown:
  {{ $strategy := index (include "autoscaling.strategies" . | fromYaml) .strategy -}}
  {{- if eq .strategy "custom" -}}
    {{- $strategy = dict "stabilizationWindow" .behavior.downscale.stabilizationWindow }}
    {{- if hasKey .behavior.downscale "percentPolicy" -}}
      {{- $strategy = merge $strategy (dict "percentPolicy" (dict "policyType" "Percent"
                                                          "policyValue" .behavior.downscale.percentPolicy.value
                                                          "policyPeriod" .behavior.downscale.percentPolicy.period)) -}}
    {{- end -}}
    {{- if hasKey .behavior.downscale "podPolicy" -}}
      {{- $strategy = merge $strategy (dict "podPolicy" (dict "policyType" "Pods"
                                                     "policyValue" .behavior.downscale.podPolicy.value
                                                     "policyPeriod" .behavior.downscale.podPolicy.period)) -}}
    {{- end -}}
  {{- end -}}

  stabilizationWindowSeconds: {{ $strategy.stabilizationWindow }}
  policies:
    {{- include "autoscaling.renderPolicy" $strategy.percentPolicy | nindent 2 }}
    {{- include "autoscaling.renderPolicy" $strategy.podPolicy | nindent 2}}
{{- end -}}

{{- /*  Render the up‑scale part of the HPA. */ -}}
{{- define "autoscaling.behaviorUpscale" }}
scaleUp:
  {{ $strategy := index (include "autoscaling.strategies" . | fromYaml) .strategy -}}

  {{- if eq .strategy "custom" -}}
    {{- $strategy = dict "stabilizationWindow" .behavior.upscale.stabilizationWindow }}
    {{- if hasKey .behavior.upscale "percentPolicy" -}}
      {{- $strategy = merge $strategy (dict "percentPolicy" (dict "policyType" "Percent"
                                                          "policyValue" .behavior.upscale.percentPolicy.value
                                                          "policyPeriod" .behavior.upscale.percentPolicy.period)) -}}
    {{- end -}}
    {{- if hasKey .behavior.upscale "podPolicy" -}}
      {{- $strategy = merge $strategy (dict "podPolicy" (dict "policyType" "Pods"
                                                     "policyValue" .behavior.upscale.podPolicy.value
                                                     "policyPeriod" .behavior.upscale.podPolicy.period)) -}}
    {{- end -}}
  {{- end -}}
  stabilizationWindowSeconds: {{ $strategy.stabilizationWindow }}
  policies:
    {{- include "autoscaling.renderPolicy" $strategy.percentPolicy | nindent 2 }}
    {{- include "autoscaling.renderPolicy" $strategy.podPolicy | nindent 2}}
{{- end -}}