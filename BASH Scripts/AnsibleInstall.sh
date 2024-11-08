#!/bin/bash

# Define variables
HOSTNAME="automationhost"
DOMAIN="automation.me"
FULL_DOMAIN="${HOSTNAME}.${DOMAIN}"
SSL_CERT_DIR="/etc/ssl/ansible"
SSL_CERT_FILE="${SSL_CERT_DIR}/${FULL_DOMAIN}.crt"
SSL_KEY_FILE="${SSL_CERT_DIR}/${FULL_DOMAIN}.key"

# Set hostname
echo "Setting hostname to ${HOSTNAME}"
sudo hostnamectl set-hostname "$HOSTNAME"

# Update system and install necessary dependencies
echo "Updating system and installing dependencies..."
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y software-properties-common curl gnupg ufw openssl

# Add Ansible PPA and install Ansible
echo "Installing Ansible..."
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

# Install Docker and Docker Compose (required for AWX)
echo "Installing Docker and Docker Compose..."
sudo apt install -y docker.io docker-compose
sudo systemctl enable --now docker

# Set up Docker permissions (optional but recommended)
sudo usermod -aG docker $USER

# Install AWX using Docker Compose
echo "Setting up AWX..."
AWX_COMPOSE_DIR="/opt/awx-docker"
sudo mkdir -p "$AWX_COMPOSE_DIR"
cd "$AWX_COMPOSE_DIR"

# Clone the AWX repository
sudo git clone https://github.com/ansible/awx.git .
sudo git checkout tags/21.3.0 -b 21.3.0  # Use a stable release tag

# Generate Docker Compose file and configure AWX settings
sudo cp tools/docker-compose/_sources/docker-compose.yml .
sudo sed -i "s|host_port: 80|host_port: 443|g" docker-compose.yml  # Change port to 443

# Generate SSL Certificate for AWX
echo "Generating self-signed SSL certificate..."
sudo mkdir -p "$SSL_CERT_DIR"
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$SSL_KEY_FILE" \
  -out "$SSL_CERT_FILE" \
  -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=${FULL_DOMAIN}"

# Update Docker Compose file to include SSL
sudo sed -i "/services:/a \  environment:\n    - NGINX_HTTPS_PORT=443\n    - SSL_CERT_PATH=$SSL_CERT_FILE\n    - SSL_KEY_PATH=$SSL_KEY_FILE" docker-compose.yml

# Start AWX
echo "Starting AWX with Docker Compose..."
sudo docker-compose up -d

# Set up UFW firewall rules
echo "Configuring firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 443/tcp  # HTTPS
sudo ufw allow 80/tcp   # HTTP (optional, redirect to HTTPS)
sudo ufw allow 22/tcp   # SSH
sudo ufw enable

# Output access information
echo "AWX should now be accessible at https://${FULL_DOMAIN}"
echo "Make sure to use this certificate for the SSL connection."
echo "Username and password for AWX admin are configured in the AWX configuration."