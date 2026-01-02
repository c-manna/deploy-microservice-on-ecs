# Deploy microservice on ECS

To run the spring boot app
$mvn spring-boot:run
mvn clean package ensures a fresh, clean build and generates the latest deployable JAR/WAR artifact for deployment.
$mvn clean package

✅ GitHub Actions + Terraform Deployment
PRE-REQUISITES (Must exist BEFORE running workflow)
1️⃣ AWS Account & IAM (MANDATORY)
A. IAM User or Role for GitHub Actions

You must have one IAM principal used by GitHub Actions.

Required permissions (minimum for now):

AmazonEC2FullAccess
AmazonECSFullAccess
AmazonElasticLoadBalancingFullAccess
AmazonRoute53FullAccess
AWSCloudMapFullAccess
CloudWatchLogsFullAccess
IAMFullAccess
AmazonS3FullAccess   (for Terraform backend)


🔴 Later you can restrict, but for now use these to avoid false failures.

B. GitHub Secrets (MANDATORY)

In GitHub → Repo → Settings → Secrets → Actions:

Secret Name	Value
AWS_ACCESS_KEY_ID	IAM access key
AWS_SECRET_ACCESS_KEY	IAM secret key
2️⃣ Terraform Backend (MANDATORY)

Terraform state backend must exist before deployment.

A. S3 Bucket (one-time)
aws s3 mb s3://terraform-state-dev-ap-south-1

B. DynamoDB (optional but recommended)
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

C. backend.tfvars
bucket         = "terraform-state-dev-ap-south-1"
key            = "hello-service/terraform.tfstate"
region         = "ap-south-1"
dynamodb_table = "terraform-locks"
encrypt        = true

3️⃣ AWS Networking (MANDATORY)
A. VPC

✔ Default VPC is OK
✔ You already confirmed VPC exists

B. Subnets (CRITICAL)

Default VPC subnets:

Are public

DO NOT have *Public* or *Private* name tags

✅ You must pass subnet IDs explicitly to Terraform.

Example:

public_subnet_ids = [
  "subnet-aaa",
  "subnet-bbb",
  "subnet-ccc"
]


🔴 Without this, ECS fails with subnets can not be empty

4️⃣ ECS Cluster (MANDATORY)

Terraform does not create it in your current module.

You must create it once:

aws ecs create-cluster \
  --cluster-name dev-cluster \
  --region ap-south-1


Confirm:

aws ecs describe-clusters --clusters dev-cluster

5️⃣ Application Load Balancer (MANDATORY)

Your module reads existing ALB:

data "aws_lb" "alb" { name = var.lb_name }

ALB requirements:
Item	Value
Type	Application
Scheme	Internet-facing
Subnets	At least 2 public subnets
Listener	Port 80
Region	ap-south-1
Name	dev-alb

Confirm:

aws elbv2 describe-load-balancers --names dev-alb

6️⃣ Cloud Map (Service Discovery) Namespace (MANDATORY)

Terraform expects private DNS namespace to already exist.

Create once:
aws servicediscovery create-private-dns-namespace \
  --name corp.internal \
  --vpc vpc-xxxxxxxx \
  --region ap-south-1


Confirm:

aws servicediscovery list-namespaces


🔴 corp ≠ corp.internal
Must match exact name in terraform.tfvars

7️⃣ ECR (PUBLIC) Repository (MANDATORY)

Your workflow pushes here:

public.ecr.aws/j9e2f6x4/hello-svc


Confirm exists:

aws ecr-public describe-repositories

8️⃣ Terraform Variables (MANDATORY)
dev/terraform.tfvars
region              = "ap-south-1"
vpc_id              = "vpc-xxxx"
ecs_cluster         = "dev-cluster"
lb_name             = "dev-alb"
cloudmap_namespace  = "corp.internal"

application         = "hello"
environment         = "dev"

public_subnet_ids = [
  "subnet-aaa",
  "subnet-bbb",
  "subnet-ccc"
]

port                = 80
health_check_path   = "/hello"
path_pattern        = "/hello"
desired_count       = 1

9️⃣ GitHub Actions (FINAL CHECK)
Must be true:

✔ aws-region = ap-south-1

✔ Docker image pushed before Terraform

✔ TF_VAR_container_version set to github.sha

✔ Terraform backend bucket exists

🔥 Minimal Prerequisite Summary (TL;DR)

You must already have:

✅ VPC
✅ Public Subnets (IDs passed explicitly)
✅ ECS Cluster
✅ ALB + Listener 80
✅ Cloud Map Private DNS Namespace
✅ ECR Repository
✅ S3 Backend Bucket
✅ IAM Permissions
✅ GitHub Secrets

What I strongly recommend next

Once this works, next improvements:

1️⃣ Create core-infra Terraform (VPC, ALB, ECS cluster, Cloud Map)
2️⃣ Keep service Terraform only for ECS services
3️⃣ Add rollback & health-check based deployment
4️⃣ Add GitHub Action validation step (fail early)

If you want, I can:

Refactor your Terraform into infra vs service

Make ALB/ECS/CloudMap auto-created cleanly

Add canary deployment

