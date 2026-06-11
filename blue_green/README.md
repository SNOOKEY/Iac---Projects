# AWS Elastic Beanstalk Blue-Green Deployment with Terraform

This project demonstrates a **Blue-Green Deployment** strategy using AWS Elastic Beanstalk and Terraform. It allows for zero-downtime deployments by maintaining two identical environments (Blue and Green) and swapping their CNAMEs to redirect traffic.

## 🏗️ Architecture

The following diagram illustrates the Blue-Green deployment workflow:

```mermaid
graph TD
    subgraph "AWS Cloud"
        S3[S3 Bucket: App Versions]
        
        subgraph "Elastic Beanstalk Application"
            Blue[Blue Environment - v1.0]
            Green[Green Environment - v2.0]
        end
        
        ALB_Blue[Application Load Balancer - Blue]
        ALB_Green[Application Load Balancer - Green]
        
        CNAME_Blue{CNAME: production.elasticbeanstalk.com}
        CNAME_Green{CNAME: staging.elasticbeanstalk.com}
        
        CNAME_Blue --> ALB_Blue --> Blue
        CNAME_Green --> ALB_Green --> Green
        
        S3 -.-> Blue
        S3 -.-> Green
    end
    
    User((User Traffic)) --> CNAME_Blue
    
    style Blue fill:#e1f5fe,stroke:#01579b
    style Green fill:#e8f5e9,stroke:#1b5e20
    style User fill:#fff3e0,stroke:#e65100
```

### Key Components:
- **Terraform**: Provisions all AWS infrastructure.
- **AWS Elastic Beanstalk**: Manages the application environments.
- **Application Load Balancer (ALB)**: Distributes traffic within each environment.
- **S3**: Stores application version artifacts (.zip files).
- **CNAME Swap**: The mechanism used to switch traffic between environments.

## 🚀 Getting Started

### Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) (>= 1.0)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- `zip` utility (for packaging apps)

### 1. Package the Applications
Before deploying, you need to package the Node.js applications into ZIP files:

```bash
# Using the provided script
./package-apps.sh
# OR on Windows
.\package-apps.ps1
```

### 2. Initialize and Deploy
```bash
terraform init
terraform plan
terraform apply
```

### 3. Perform Blue-Green Swap
Once both environments are healthy, you can swap the traffic:

```bash
./swap-environments.sh
# OR on Windows
.\swap-environments.ps1
```

## 📂 Project Structure

- `main.tf`: Core EB application and IAM configurations.
- `blue-environment.tf`: Configuration for the "Blue" (Production) environment.
- `green-environment.tf`: Configuration for the "Green" (Staging) environment.
- `variables.tf`: Input variables.
- `outputs.tf`: Useful outputs including environment URLs and swap instructions.
- `app-v1/`, `app-v2/`: Sample Node.js applications.
- `package-apps.*`: Scripts to zip the application code.
- `swap-environments.*`: Scripts to perform the CNAME swap via AWS CLI.

## 🧹 Cleanup
To avoid ongoing charges, destroy the resources when finished:

```bash
terraform destroy
```

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
