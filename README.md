# devops-sample-apps

## Overview

This repository contains the code and configuration for building, running, packaging, and deploying Golang and PHP applications, along with their supporting infrastructure. The primary goals are to facilitate rapid development, promote best practices, and provide a scalable and maintainable deployment pipeline.

## Premises

* As the two apps are in the same repo, I am treating the project as a monorepo.
* As there is no way I can create another account for production, both dev and prod will be created in the monorepo.

## Goals & Principles

This project prioritizes:

* **Ease of Development:** Streamlined workflows for local development and testing.
* **Best Practices:**  Adherence to industry standards and the use of tools like linters and container testing.
* **Reduced Cognitive Load:**  Clear and consistent configuration, enabling both quick experimentation and robust production deployments.
* **Flexible Environments:** Support for local testing (build & run, Docker Compose, Helm Chart) and automated cloud deployments (TILT).
* **Extensibility & Scalability:**  Infrastructure designed for easy expansion and adaptation.

## Architecture & Design

High level, low resolution, overview of the problem statement:
![](./docs/overview.jpg)

### Environment Strategy

The project supports three distinct environments:

* **Single:** A minimal environment for basic testing and development.
* **Failover:**  A more resilient environment with multi-AZ deployment and redundancy.
* **Robust:** A highly available and scalable environment with multi-AZ deployment, read replicas, and advanced monitoring.

_note: More details at Network, Compute and Database sections below._

## Getting Started

### Prerequisites

* Golang SDK
* PHP SDK
* Terraform
* Terragrunt
* Checkov
* Container Runtime (Docker, Podman, etc.) - *Optional*
* Kubernetes Distribution (e.g., Minikube, Kind, AKS, EKS) - *Optional*
* TILT - *Optional*
* Makefile tools - *Optional*
* curl - *Optional*

### Running the Applications Locally

The recommended approach is to use TILT for the most integrated experience.  Alternatives are provided for different levels of isolation and complexity.

1. **TILT:** `tilt up` from the project root.
2. **Docker Compose:** `docker-compose up -d` from the project root.
3. **Makefile:** `make run-image`. Use `make help` for a list of available commands.
4. **Single App Runs:** Navigate to each app's directory and run `./build_and_run_docker.sh`.

## Infrastructure Configuration

### Modules

The infrastructure is defined using Terraform modules to promote reusability and maintainability.

```sh
./infra/modules
	├── networking    : VPC, Subnet, Gateways and Routes definition
	├── compute       : Mainly Kubernetes cluster and nodgroups and OIDC and PodIdentity
	├── communications: Load Balancer Controller and NGINX Ingress
	├── compute-extras: AWS Autoscaler
	├── storage       : EFS setup
	├── security      : Secrets CSI driver and provider
	└── database      : RDS Postgres setup
```

[DIAGRAM SUGGESTION: A diagram illustrating the relationships between the different infrastructure modules.]

### Environments

The infrastructure is deployed to different environments using Terragrunt.

```sh
./infra/live
	└── eu-north-1
	    ├── dev
	    │	├── communications/
	    │ 	├── compute/
	    │	├── compute-extras/
	    │	├── database/
	    │	├── networking/
	    │	├── security/
	    │	├── storage/
	    │   └── locals.hcl     // dev shared values
	    ├── prod
	    │	├── communications
	    │	├── compute
	    │	├── compute-extras
	    │	├── database
	    │	├── networking
	    │	├── security
	    │	├── storage
	    │	└── locals.hcl     // prod shared values
	    ├── registry
	    │	 └── terragrunt.hcl 
	    └── terragrunt.hcl      // main provider definitions
```


## Network & Compute Resources

The following table summarizes the network and compute configurations for each environment:

| Environment | Network Configuration | Compute Configuration |
|---|---|---|
| **Single** | 2 AZ, 2 Public & 2 Private Subnets (~1000 IPs each) | 1 NodeGroup (Spot) |
| **Failover** | 2 AZ, 2 Public & 2 Private Subnets (~2000 IPs each) | 2 NodeGroups (Spot & Reserved)* |
| **Robust** | 3 AZ, 3 Public & 3 Private Subnets (~3000 IPs each) | 2 NodeGroups (Reserved & OnDemand)* |

*Note: Reserved and OnDemand node group types are not implemented to avoid extra costs, but are included in the design for future consideration.*

![](./docs/network.jpg)

## Database Configuration

| Environment | Database Configuration |
|---|---|
| **Single** | No multi-AZ, no read replica |
| **Failover** | Multi-AZ, no read replica |
| **Robust** | Multi-AZ, read replica |

![](./docs/database.jpg)

## Collaboration & Linting

The following commands can be used to ensure code quality and consistency:

* `helm install -f k8s/dev.values.yaml "devops-demo" k8s/chart --namespace devops-demo --create-namespace`
* `terragrunt hcl fmt --filter './live/**/*.hcl' --experiment-mode`
* `terraform fmt ./modules -recursive`
* `helm lint k8s/chart/`
* `helm template k8s/chart/ --debug |  kubeconform`

## Known Issues & Tech Debt

* **`make kill-apps`:**  The `make kill-apps` command does not reliably terminate all application processes. This is a non-critical issue and will be addressed if time permits.

* **Checkov Findings:** The following Checkov findings represent areas for improvement in the infrastructure configuration:

```sh
checkov --framework terraform --directory infra/modules --download-external-modules true  | grep FAILED -B1 | grep Check

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


## Application Specifics

### Golang Application

The Golang application requires a `file.p12` certificate file to be placed next to the application binary at runtime.

### PHP Application

The PHP application requires the `APP_ENV` environment variable to be set to `prod` for production deployments.  The `config.prod` file should be renamed to `config` in the application directory.

## Future Enhancements (Wishlist)

* **Unified Configuration:** Create a single configuration file to parameterize both the Helm chart and infrastructure configuration.
* **Tiered Infrastructure:** Reduce cognitive load by using a "Tier" and "Traffic" abstraction to derive redundancy settings (subnets, replicas, database size, etc.).
* **Clustered Database:** Explore options for clustering the database, potentially using Amazon Aurora.
* **Custom Policies:** Implement custom policies to enforce tagging, naming conventions, and other standards using tools like Terraform Compliance.


## Left out of Demo

* **Manage Secrets Securely and Reliably:** Use KMS, Vault or alike to create, rotate, audit and provide secrets, e.g. `.p12` secret provided to Golang app. 
* **CI/CD Pipeline**: Implement a robust CI/CD pipeline for automated building, testing, and deployment.
* **Database Access Control:** Enhance database access control by leveraging Pod Identity and strengthening Security Group rules.
* **Automated Security Checks:** Integrate Checkov into the Terragrunt workflow as a pre-apply hook to enforce security best practices.
* **Variable Validation:** Extend validation of module variable values beyond the network module to ensure data integrity and prevent misconfigurations.
* **Database Flexibility:** Enable support for different database types and sizes to accommodate varying application requirements.
* **Cost Management:** Implement cost monitoring, alerting, and limits to optimize resource utilization and control expenses.
* **Pod Disruption Budgets (PDBs):** Implement PDBs to minimize downtime during deployments and ensure application availability.
* **Namespace Isolation:** Separate applications into distinct Kubernetes namespaces for improved isolation and resource management.
* **Roles Separation to Manage infra:** Create limited roles each environment to be assumed by the deployer user. 

