ScaleOps: API Infrastructure
Project Overview
ScaleOps is a production-ready Node.js API infrastructure automated through Terraform and AWS. It features a robust CI/CD pipeline designed for scalable and high-availability deployments. The project integrates automated testing, containerization, and Infrastructure as Code (IaC) to ensure a seamless deployment lifecycle.

Technical Stack
Backend: Node.js, Express.js

Infrastructure: Terraform (AWS)

Containerization: Docker

CI/CD: GitHub Actions

Testing: Jest, Supertest

Infrastructure Architecture (Terraform)
The infrastructure is provisioned using Terraform to create a custom, isolated environment on AWS Mumbai (ap-south-1). Key components include:

Virtual Private Cloud (VPC): A custom network with a CIDR block of 10.0.0.0/16.

Public Subnet: Configured with 10.0.1.0/24 to host public-facing resources.

Internet Gateway & Route Tables: Established to provide internet connectivity for the public subnet.

Security Groups: A virtual firewall allowing inbound traffic on Port 80 (HTTP) and Port 22 (SSH).

Compute: A t3.micro EC2 instance running Ubuntu 22.04, dynamically selected via an AMI data source.

Bootstrapping: Automated OS updates and software installation via user_data scripts.

Application Layer
The application consists of a lightweight Node.js/Express API:

Server Entry: server.js manages the application's entry point and port configuration (defaulting to Port 3000).

Application Logic: app.js defines middleware and API routes.

Monitoring: Includes a standardized /api/health endpoint.

Automated Testing: A "Pipeline Quality Gate" is implemented using Jest and Supertest to verify API health before deployment.

CI/CD Pipeline
The deployment is fully automated using GitHub Actions. The workflow consists of two primary stages:

Continuous Integration (CI): Executes automated Jest unit tests on an ubuntu-latest runner to ensure code quality.

Continuous Deployment (CD): Upon successful test execution, the pipeline securely connects to the AWS EC2 instance via SSH to pull the latest code updates, build a new Docker image, and replace the existing container.
