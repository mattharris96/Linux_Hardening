#!/bin/bash

# Define variables
TERRAFORM_VERSION="1.5.7"  # Specify the desired Terraform version
DOWNLOAD_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

# Update and install dependencies
echo "Updating system and installing dependencies..."
sudo apt update -y
sudo apt install -y wget unzip gnupg software-properties-common

# Download Terraform
echo "Downloading Terraform ${TERRAFORM_VERSION}..."
wget "$DOWNLOAD_URL" -O /tmp/terraform.zip

# Install Terraform
echo "Installing Terraform..."
sudo unzip -o /tmp/terraform.zip -d /usr/local/bin/
sudo chmod +x /usr/local/bin/terraform

# Verify installation
echo "Verifying Terraform installation..."
terraform -v

# Clean up
echo "Cleaning up downloaded files..."
rm /tmp/terraform.zip

echo "Terraform installation complete!"