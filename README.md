# ReadMe - YET TO BE DONE, IN DRAFT

# Content
This repo holds the code to build, run, package and deploy Golang and PHP apps along with their required infrastructure.

It mainly focus on creating an environment that promotes good practices and fast iterations.

# Motivations

1. Ease of development.
2. Promote good practices (goss, docker linter, ...)
3. Reduce cognitive load while enabling power users (chart)
4. Enables local testing of the app with no environment (build and run, make), minimal environment (docker composer, helm chart) or fully automated close-to-cloud (TILT)
5. Extendable and easy to deploy infrastructure.

# Premises

- As the two apps are in the same repo, I am treating the project as a monorepo.
- As there is no way I can create another account for production, both dev and prod will be created in the monorepo.

# How to run apps locally

The suggested method is to use from most integrated environment to more standalone way in this order:
- TILT: `tilt up` from project root.

TODO: move alternatives to another document.
- Docker Composer: `docker-compose up -d` from project root.
- Makefile: `make run`, use `make help` for more options.
- Single App Runs: `./build_and_run_docker.sh` from each app folder.

# Features

- Standalone build scripts
- GOSS container tests
- Docker Composer alternative
- TILT local environment

# Network
Single: 2 AZ, 2 Public and 2 Private subnet, ~1000 IPs each
Failover: 2 AZ, 2 Public and 2 Private subnet, ~2000 IPs each
Robust: 3 AZ, 3 Public and 3 Private subnet, ~3000 IPs each

# Compute
Single: 1 NodeGroup (Spot)
Failover: 2 NodeGroups (Spot & Reserved)*
Robust: 2 NodeGroup (Reserved & OnDemand)*

`*` *note: Reserved and OnDemand type of nodegroups are not implemented to avoid extra costs, but left here for sketching the idea*
 
# Database
Single: no multi-az, no read replica
Failover: multi-az, no read replica
Robust: multi-az, read replica

# Requirements
- golang sdk
- php sdk
- terraform
- terragrunt
- checkov
- a container runtime (optional)
- a k8s distribution (optional)
- TILT(optional)
- Makefile tools (optional)
- curl (optional)


# Collab

`helm install -f k8s/dev.values.yaml "devops-demo" k8s/chart --namespace devops-demo --create-namespace`

`terragrunt hcl fmt --filter './live/**/*.hcl' --experiment-mode`

`terraform fmt ./modules -recursive`

`helm lint k8s/chart/`

`kubeconform`

# Wishlist

- Create a single config file that parametrizes both Chart and Infra
- Reduce cognitive load on infra environments, e.g. use a "Tier" and a "Traffic" oa alike to derive redundancy: subnets, replicas, database size, etc
- Cluster database option, maybe even using ACK
- Create Custom policies to enforce taggging, naming and other conventions (https://terraform-compliance.com)



# Missing


- CI/CD Pipeline
- Implement database secret using KMS(`master_user_secret_kms_key_id = aws_kms_key.this.key_id`) or Vault
- Restrict Database access further: Pod Identity, stronger Security Groups
- Embed checkov in Terragrunt as a before apply hook
- Extend Module Variable values validations (only network has it)
- Separate DB type, sizes, etc
- Cost management: alerts, limits, etc
- PDB for deployments
- Separate Namespace per application



# Known issues

- `make kill-apps` does not work properly, the sub-process for each app is not captured, to fix if there is time, as it is non-critical.

# Tech Debt
`checkov --framework terraform --directory infra/modules --download-external-modules true  | grep FAILED -B1 | grep Check`
```
Check: CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
Check: CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
Check: CKV_AWS_39: "Ensure Amazon EKS public endpoint disabled"
Check: CKV_AWS_58: "Ensure EKS Cluster has Secrets Encryption Enabled"
Check: CKV_AWS_38: "Ensure Amazon EKS public endpoint not accessible to 0.0.0.0/0"
Check: CKV_AWS_37: "Ensure Amazon EKS control plane logging is enabled for all log types"
Check: CKV_AWS_382: "Ensure no security groups allow egress from 0.0.0.0:0 to port -1"
Check: CKV_AWS_161: "Ensure RDS database has IAM authentication enabled"
Check: CKV_AWS_353: "Ensure that RDS instances have performance insights enabled"
Check: CKV_AWS_157: "Ensure that RDS instances have Multi-AZ enabled"
Check: CKV_AWS_226: "Ensure DB instance gets all minor upgrades automatically"
Check: CKV_AWS_118: "Ensure that enhanced monitoring is enabled for Amazon RDS instances"
Check: CKV_AWS_149: "Ensure that Secrets Manager secret is encrypted using KMS CMK"
Check: CKV_AWS_184: "Ensure resource is encrypted by KMS using a customer managed Key (CMK)"
```

####################################

# devops-sample-apps

## golang

Application in runtime needs p12 file(filename: file.p12) next to application binary.

## php

Application to run on production needs env `APP_ENV=prod` and file `config` next to index.php, 
repository contains `config.prod` and `config.dev`, for production purposes `config.prod` needs to be renamed to `config`. 






