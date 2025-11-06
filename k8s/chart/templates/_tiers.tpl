{{- define "apps.tiers" -}}
basic:
  replicas:
    min: 1
    max: 5
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: "workload-kind"
            operator: In
            values:
            - "balanced"
  tolerations:
  - key: "instance-kind"
    operator: "Equal"
    value: "spot"
    effect: "NoSchedule"
concurrent:
  replicas:
    min: 2
    max: 10
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: "workload-kind"
            operator: In
            values:
            - "balanced"
            - "cpu"
            - "mem"
            - "net"
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: "workload-kind"
            operator: In
            values:
            - "balanced"  #TODO: add the one selected for this app, else default balanced
  tolerations:
  - key: "instance-kind"
    operator: "Equal"
    value: "spot"
    effect: "NoSchedule"
  - key: "instance-kind"
    operator: "Equal"
    value: "reserved"
    effect: "NoSchedule"
tolerant:
  replicas:
    min: 3
    max: 15
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: "workload-kind"
            operator: In
            values:
            - "cpu"
            - "mem"
            - "net"
            - "gpu"
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: "workload-kind"
            operator: In
            values:
            - "gpu"  #TODO: add the one selected for this app, else default balanced
  tolerations:
  - key: "instance-kind"
    operator: "Equal"
    value: "reserved"
    effect: "NoSchedule"
  - key: "instance-kind"
    operator: "Equal"
    value: "ondemand"
    effect: "NoSchedule"
{{- end -}}

{{/*  App redundancy level(tiers)  */}}
{{- define "apps.getReplicas" -}}
{{- $tier := .tier | default "concurrent" -}}
  {{- $tiers := (include "apps.tiers" .) | fromYaml -}}
replicas: {{ toYaml (get (get (get $tiers $tier) "replicas") "min") -}}
{{- end -}}

{{/*  App min and max replicas  */}}
{{- define "apps.getAutoscalingReplicas" -}}
{{- $tier := .tier | default "concurrent" -}}
  {{- $tiers := (include "apps.tiers" .) | fromYaml -}}
  {{- $replicas := get (get $tiers $tier) "replicas" -}}
minReplicas: {{ toYaml (get $replicas "min") }}
maxReplicas: {{ toYaml (get $replicas "max") }}
{{- end -}}
