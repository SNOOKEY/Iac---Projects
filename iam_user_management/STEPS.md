# Implementation Steps for IAM User Management

Follow these steps to build or modify this project:

### Step 1: Data Preparation
Create a `users.csv` file. This serves as your single source of truth. Ensure columns are correctly named as the Terraform code depends on these specific keys.

### Step 2: Data Parsing
In `local.tf`, use the `csvdecode()` function to read the file. This converts the CSV rows into a list of maps, making them easy to iterate over with `for_each`.

### Step 3: Resource Definition (Users)
In `main.tf`, use `aws_iam_user` with a `for_each` loop.
- **Naming Convention**: Use `lower()` and `substr()` to create standardized usernames (e.g., `mscott`).
- **Tagging**: Map the CSV columns to AWS tags. This is crucial for the dynamic membership logic in the next step.

### Step 4: Login & Security
Create `aws_iam_user_login_profile` for each user.
- Set `password_reset_required = true` to ensure security compliance.
- Use a `lifecycle` block to ignore changes to the password settings after initial creation, preventing Terraform from trying to reset passwords on every run.

### Step 5: Group & Membership Logic
In `groups.tf`:
- Define your `aws_iam_group` resources.
- Use `aws_iam_group_membership` with complex `for` expressions.
- **Filtering**: Use `if` statements within the `for` loop to filter users by their tags (e.g., `user.tags["Department"] == "Engineering"`).

### Step 6: Validation and Output
Use `output.tf` to output the AWS Account ID and perhaps a list of created usernames. This helps in verifying that the automation worked as expected.

### Step 7: Deployment
Run the standard Terraform workflow: `init` -> `plan` -> `apply`.
