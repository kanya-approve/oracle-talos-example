# Oracle Cloud Talos Example

## Prerequisites

- Access to a Terminal/Command Line: You need access to a command-line interface (CLI) on your local machine to execute various commands.
- Basic Understanding of Cloud and Infrastructure as Code: Familiarity with cloud computing concepts and Terraform is essential to follow along with the tutorial.
- Git: Install Git for version control and repository management. You can download it from Git's official site.
- GitHub Account: Create or have access to a GitHub account where you can create repositories and generate personal access tokens.
- Python: Ensure you have Python (3.6 or later) for running a Python script in this repo.
- Talos CLI: Install the Talos CLI (osctl) for interacting with Talos-managed Kubernetes clusters. Instructions can be found on the Talos website.
- Terraform CLI: Install the Terraform CLI on your local machine to manage infrastructure as code. You can download it from the official Terraform website.

## Steps

1. [Follow this tutorial until the "Convert your trial to PAYG" step](https://mattscott.cloud/kubernetes-on-oracle-cloud-for-free/)
2. Use this repository as a template repository to make your own
3. Clone the repository
4. Create a bucket on Oracle and note the name
5. Run the modules/oci_talos_image/prepare_images.bat or modules/oci_talos_image/prepare_images.sh to generate the Oracle image
6. Upload the 2 created images (oracle-amd64.oci and oracle-arm64.oci) to the bucket
7. [Create an Oracle api key](https://cloud.oracle.com/identity/domains/my-profile/api-keys)
8. Click "Add API Key"
9. Click "Add" after downloading the private key
10. For this newly generated api key, click on the 3 dots to the right of it and click "View configuration file"
11. Copy and note all the information there
12. [Sign up for Terraform cloud](https://app.terraform.io/)
13. Create a VCS project on terraform cloud and note the name
14. Create a workspace on terraform cloud under that project and note the name
15. [Create a classic Github personal access token with repo permissions and note the value](https://github.com/settings/tokens/new)
16. Under the created workspace variables, create a new workspace environment variable called TF_VAR_fingerprint and make the value after fingerprint= from what you copied on step #11
17. Under the created workspace variables, create a new workspace environment variable called TF_VAR_region and make the value after region= from what you copied on step #11
18. Under the created workspace variables, create a new workspace environment variable called TF_VAR_tenancy_ocid and make the value after tenancy= from what you copied on step #11
19. Under the created workspace variables, create a new workspace environment variable called TF_VAR_user_ocid and make the value after tenancy= from what you copied on step #11
20. Under the created workspace variables, create a new workspace environment variable called TF_VAR_talos_images_bucket and make the value what you noted on step #4
21. Under the created workspace variables, create a new SENSITIVE workspace environment variable called GITHUB_TOKEN and make the value what you noted on step #15
22. Under the created workspace variables, create a new SENSITIVE workspace environment variable called TF_VAR_private_key and make the value the contents of the downloaded private key from step #9
23. Start a new terraform cloud run and your new Oracle cloud talos cluster will be live
