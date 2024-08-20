# Oracle Cloud Talos Example

## Prerequisites

- [Follow this tutorial until the "Convert your trial to PAYG" step](https://mattscott.cloud/kubernetes-on-oracle-cloud-for-free/)
- Terraform cloud account
- Create a terraform workspace
- Create a workspace variable titled "TF_VAR_fingerprint" with the value of your fingerprint from Oracle cloud
- Create a workspace variable titled "TF_VAR_private_key" with the value of your private key from Oracle cloud
- Create a workspace variable titled "TF_VAR_region" with the value of your region from Oracle cloud (us-ashburn-1)
- Create a workspace variable titled "TF_VAR_tenancy_ocid" with the value of your tenancy ocid from Oracle cloud
- Create a workspace variable titled "TF_VAR_user_ocid" with the value of your user ocid from Oracle cloud

## Steps

1. Create a bucket on Oracle
2. Run the modules/oci_talos_image/prepare_images.bat or modules/oci_talos_image/prepare_images.sh to generate the Oracle image
3. Upload the 2 images to the bucket
4. Create a workspace variable titled "TF_VAR_talos_images_bucket" with the name of the bucket that has the Talos images
5. Create a workspace variable titled "TF_VAR_ad_number" with the number of the domain that your free A1 flex instances are in...you can skip this step if you want to see if your default is 3
6. Apply this
