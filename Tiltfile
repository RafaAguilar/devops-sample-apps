# Deploy the Helm chart from k8s/chart

# you can comment this if you are using a k8s distro that already provides Metrics API
k8s_yaml(kustomize('./k8s/local/metrics-server'))

k8s_yaml('k8s/local/namespace.yaml')

# simulating secrets provides by other integrations in the cloud
k8s_yaml('k8s/local/db-secret.yaml')
k8s_yaml('k8s/local/p12-secret.yaml')

docker_build(
  'golang:v0.1',
  './golang',
  dockerfile='./golang/go.containerfile'
)

docker_build(
  'php:v0.1',
  './php',
  dockerfile='./php/php.containerfile'
)

k8s_yaml(helm(
    './k8s/chart',
    name='devops-sample-apps',
    namespace='devops-demo',
    set=['global.namespace=devops-demo'],
))

k8s_resource(
    'golang',
    labels=['golang-app']
)

k8s_resource(
    'php',
    labels=['php-app']
)


local_resource(
    'golang-service-port-fwd',
    serve_cmd='kubectl port-forward -n devops-demo svc/golang-service 9191:8080',
    labels=['golang-app'],
    resource_deps=['golang']
)

local_resource(
    'php-service-port-fwd',
    serve_cmd='kubectl port-forward -n devops-demo svc/php-service 9090:8080',
    labels=['php-app'],
    resource_deps=['php']
)

print('=== devops-sample-apps Tilt Configuration ===')
print('Namespace: devops-demo')
print('Golang app: http://localhost:9191')
print('PHP app: http://localhost:9090')
print('===========================================')
