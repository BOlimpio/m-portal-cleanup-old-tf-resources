# Cleanup old tf resources 

This bash script is designed to update tf files by commenting out resources that are older than 90 days based on the `creationDate` tag. It works for both resources created directly and those created through modules. **For additional resources, examples, and community engagement**, check out the portal [Cloudymos](https://cloudymos.com) :cloud:.

## Prerequisites

- [Terraform](https://www.terraform.io/) installed
- [jq](https://stedolan.github.io/jq/) installed
- Bash shell environment

## Usage

1. Clone this repository:

   ```bash
   git clone https://github.com/yourusername/terraform-state-update-script.git
   cd terraform-state-update-script
   ```

2. Make the script executable:

   ```bash
   chmod +x update_terraform_state.sh
   ```

3. Run the script:

   ```bash
   ./update_terraform_state.sh
   ```

## How it Works

1. **Getting Resource Blocks:**
   - Collects resource blocks for resources created without a module, excluding data sources.
   - Collects resource blocks for resources created via a module, excluding data sources.

2. **Filtering by Age:**
   - Filters resource blocks based on the `creationDate` tag, excluding resources created within the last **90 days**.

3. **Commenting Out Resources:**
   - Iterates over the filtered resource blocks and comments out the corresponding blocks in the Terraform files.

4. **Cleanup:**
   - Removes temporary files created by the script.

## Limitations

- The script assumes the `creationDate` tag is in the format `mm/dd/yyyy`.
- The script assumes that terraform codes are indented according to terraform best practice

## Contributing

Contributions are welcome! Please follow the guidance below for details on how to contribute to this project:
1. Fork the repository
2. Create a new branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a pull request
