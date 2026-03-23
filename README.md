# JFC E-Commerce - Infraestructura AWS con Terraform

## Descripción del Proyecto

Infraestructura como Código (IaC) para una aplicación e-commerce de tres capas (Frontend, Backend, Datos) en AWS, diseñada para ser **altamente disponible, escalable y segura**.

### Componentes Principales

| **Capa** | **Servicios** |
|----------|---------------|
| **Redes** | VPC, Subnets (públicas/privadas/aisladas), NAT Gateway, IGW, Route Tables |
| **Seguridad** | WAF, Shield, Cognito, Secrets Manager, KMS, Security Groups |
| **Frontend** | CloudFront, S3 (hosting estático) |
| **Backend** | API Gateway, Lambda, ALB, ECS Fargate, ECR |
| **Datos** | Aurora PostgreSQL Serverless v2, DynamoDB, ElastiCache Redis |
| **Observabilidad** | CloudWatch, X-Ray, SNS, Grafana, CloudTrail |
| **CI/CD** | ECR, GitHub Actions (IAM Role) |

---

## Requisitos Previos

| **Requisito** | **Versión** | **Instalación** |
|---------------|-------------|-----------------|
| Terraform | >= 1.14.0 | [Descargar](https://developer.hashicorp.com/terraform/downloads) |
| AWS CLI | >= 2.0 | [Instalar](https://aws.amazon.com/cli/) |
| AWS Account | - | Con permisos de administrador |
| Git | - | [Descargar](https://git-scm.com/) |

---

## Estructura del Proyecto

terraform-JFC/
├── backend.tf # Configuración de estado remoto (S3 + DynamoDB)
├── providers.tf # Providers de AWS
├── variables.tf # Variables globales
├── outputs.tf # Outputs de la infraestructura
├── main.tf # Orquestación de módulos
├── modules/
│ ├── networking/ # VPC, subnets, NAT, IGW
│ ├── security/ # WAF, Cognito, Security Groups
│ ├── storage/ # S3 buckets (frontend, media, logs)
│ ├── compute/ # ALB, ECS Fargate, Auto Scaling
│ ├── database/ # Aurora, DynamoDB, Redis
│ ├── api/ # API Gateway, Lambda
│ ├── observability/ # CloudWatch, X-Ray, SNS, Grafana
│ └── ci-cd/ # ECR, GitHub Actions Role