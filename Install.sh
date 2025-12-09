#!/bin/bash

# Define Colors for Branding
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function: Loading Animation
show_loading() {
    echo -n "Loading KS HOSTING Assets"
    for i in {1..3}; do
        echo -n "."
        sleep 0.5
    done
    echo ""
}

# Function: Display Banner
show_banner() {
    clear
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${RED}           KS HOSTING BY KSGAMING                    ${NC}"
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${YELLOW}     PufferPanel Installer & User Setup             ${NC}"
    echo -e "${CYAN}======================================================${NC}"
    echo ""
}

# Check if running as root
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}[ERROR] This script must be run as root.${NC}" 1>&2
   exit 1
fi

# Run Visuals
show_banner
show_loading
echo -e "${GREEN}[+] Initialization complete.${NC}"
sleep 1

# Step 1: Add PufferPanel Repositories
echo -e "${YELLOW}[INFO] Adding PufferPanel Repositories...${NC}"
curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | sudo bash

# Step 2: Install PufferPanel
echo -e "${YELLOW}[INFO] Installing PufferPanel...${NC}"
sudo apt-get install pufferpanel -y

# Step 3: Enable and Start Service
echo -e "${YELLOW}[INFO] Starting PufferPanel Service...${NC}"
sudo systemctl enable --now pufferpanel

# Step 4: Configure Firewall (Ports 8080 & 5657)
echo -e "${YELLOW}[INFO] Configuring Firewall Rules...${NC}"
if command -v ufw > /dev/null; then
    sudo ufw allow 8080/tcp comment 'PufferPanel Web'
    sudo ufw allow 5657/tcp comment 'PufferPanel SFTP'
    sudo ufw reload
    echo -e "${GREEN}[+] Ports 8080 (Web) and 5657 (SFTP) opened.${NC}"
else
    echo -e "${RED}[!] UFW not found. Please open ports 8080 and 5657 manually.${NC}"
fi

# Step 5: Create Admin User (Interactive)
echo ""
echo -e "${CYAN}======================================================${NC}"
echo -e "${YELLOW}           CREATE ADMIN USER (KS HOSTING)            ${NC}"
echo -e "${CYAN}======================================================${NC}"
echo "Please enter the details for your new Admin account:"
echo ""

read -p "Enter Email: " admin_email
read -p "Enter Username: " admin_name
read -s -p "Enter Password: " admin_pass
echo "" 

echo -e "${YELLOW}[INFO] Creating Admin Account...${NC}"
sudo pufferpanel user add --email "$admin_email" --name "$admin_name" --password "$admin_pass" --admin

# Step 6: Get Public IP
SERVER_IP=$(curl -s https://ifconfig.me || echo "YOUR-IP")

# Completion Message
echo ""
echo -e "${CYAN}======================================================${NC}"
echo -e "${GREEN}      INSTALLATION COMPLETE - KS HOSTING              ${NC}"
echo -e "${CYAN}======================================================${NC}"
echo -e "${YELLOW}Access Details:${NC}"
echo -e "Panel URL:  ${GREEN}http://$SERVER_IP:8080${NC}"
echo -e "SFTP Port:  5657"
echo -e "Username:   $admin_name"
echo -e "Email:      $admin_email"
echo -e "${CYAN}======================================================${NC}"
echo ""
