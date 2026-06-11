# Project Completion Steps

Follow these steps to successfully deploy and test the Blue-Green deployment project.

## Phase 1: Preparation
1. **Configure AWS Credentials**: Ensure your AWS CLI is configured with `aws configure`.
2. **Review Variables**: Check `variables.tf` and adjust `aws_region` or `app_name` if desired.
3. **Install Dependencies**: Ensure you have `terraform` and a `zip` utility installed.

## Phase 2: Packaging
1. **Run Packaging Script**:
   ```bash
   ./package-apps.sh
   ```
   This creates `app-v1.zip` and `app-v2.zip` which Terraform will upload to S3.

## Phase 3: Infrastructure Deployment
1. **Initialize Terraform**:
   ```bash
   terraform init
   ```
2. **Review Plan**:
   ```bash
   terraform plan
   ```
3. **Apply Configuration**:
   ```bash
   terraform apply -auto-approve
   ```
   *Note: This process may take 10-15 minutes as AWS provisions two Elastic Beanstalk environments.*

## Phase 4: Verification
1. **Get Environment URLs**: Run `terraform output instructions` to see the URLs.
2. **Test Blue (v1.0)**: Open the Blue URL in your browser. You should see "Welcome to Version 1.0".
3. **Test Green (v2.0)**: Open the Green URL in your browser. You should see "Welcome to Version 2.0".

## Phase 5: Blue-Green Swap
1. **Execute Swap**:
   ```bash
   ./swap-environments.sh
   ```
2. **Wait for Propagation**: It usually takes 1-2 minutes for the CNAME swap to propagate.
3. **Verify Swap**:
   - Refresh the **Blue URL**. It should now display **Version 2.0**.
   - Refresh the **Green URL**. It should now display **Version 1.0**.

## Phase 6: Maintenance & Cleanup
1. **Updates**: To deploy a new version, update the code in `app-v1` or `app-v2`, re-package, and run `terraform apply`.
2. **Destroy**: When finished, run:
   ```bash
   terraform destroy -auto-approve
   ```
