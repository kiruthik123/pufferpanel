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
    echo -e "${YELLOW}       PufferPanel Manager (Install/Uninstall)      ${NC}"
    echo -e "${CYAN}======================================================${NC}"
    echo ""
}

# Check if running as root
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}[ERROR] This script must be run as root.${NC}" 1>&2
   exit 1
fi

# ==========================================
# FUNCTION: INSTALL PANEL
# ==========================================
install_panel() {
    echo -e "${GREEN}[+] Starting Installation...${NC}"
    sleep 1

    # Step 1: Install Dependencies & Docker
    echo -e "${YELLOW}[INFO] Checking system dependencies...${NC}"
    sudo apt-get update -y && sudo apt-get install -y curl wget git

    # Check/Install Docker
    if ! command -v docker > /dev/null; then
        echo -e "${YELLOW}[INFO] Docker not found. Installing Docker...${NC}"
        curl -fsSL https://get.docker.com | sudo sh
        sudo systemctl enable --now docker
        echo -e "${GREEN}[+] Docker installed successfully.${NC}"
    else
        echo -e "${GREEN}[+] Docker is already installed.${NC}"
    fi

    # Step 2: Add PufferPanel Repositories
    echo -e "${YELLOW}[INFO] Adding PufferPanel Repositories...${NC}"
    curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | sudo bash

    # Step 3: Install PufferPanel
    echo -e "${YELLOW}[INFO] Installing PufferPanel...${NC}"
    sudo apt-get install pufferpanel -y

    # Step 4: Enable and Start Service
    echo -e "${YELLOW}[INFO] Starting PufferPanel Service...${NC}"
    sudo systemctl enable --now pufferpanel

    # Step 5: Configure Firewall
    echo -e "${YELLOW}[INFO] Configuring Firewall Rules...${NC}"
    if command -v ufw > /dev/null; then
        sudo ufw allow 8080/tcp comment 'PufferPanel Web'
        sudo ufw allow 5657/tcp comment 'PufferPanel SFTP'
        sudo ufw reload
        echo -e "${GREEN}[+] Ports 8080 (Web) and 5657 (SFTP) opened.${NC}"
    else
        echo -e "${RED}[!] UFW not found. Please ensure ports 8080 and 5657 are open.${NC}"
    fi

    # Step 6: Create Admin User
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

    # Step 7: Set Panel URL
    echo ""
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${YELLOW}              PANEL CONFIGURATION                    ${NC}"
    echo -e "${CYAN}======================================================${NC}"
    echo "Enter the IP Address or Domain for this panel."
    echo "Examples: 192.168.1.1 OR panel.kshosting.com"
    echo ""
    read -p "Panel URL/IP: " panel_host

    # Completion Message
    echo ""
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${GREEN}      INSTALLATION COMPLETE - KS HOSTING              ${NC}"
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${YELLOW}Access Details:${NC}"
    echo -e "Panel URL:  ${GREEN}http://$panel_host:8080${NC}"
    echo -e "SFTP Port:  5657"
    echo -e "Username:   $admin_name"
    echo -e "Email:      $admin_email"
    echo -e "${CYAN}======================================================${NC}"
    echo ""
}

# ==========================================
# FUNCTION: UNINSTALL PANEL
# ==========================================
uninstall_panel() {
    echo ""
    echo -e "${RED}⚠️  WARNING: THIS WILL DELETE PUFFERPANEL AND ALL GAME SERVER DATA! ⚠️${NC}"
    echo -e "${YELLOW}This action cannot be undone.${NC}"
    echo ""
    echo -n "Type 'AGREE' to delete everything and uninstall: "
    read confirmation

    if [ "$confirmation" != "AGREE" ]; then
        echo -e "${GREEN}Uninstall cancelled. Nothing was deleted.${NC}"
        exit 1
    fi

    echo ""
    echo -e "${YELLOW}[INFO] Stopping PufferPanel Service...${NC}"
    sudo systemctl stop pufferpanel
    sudo systemctl disable pufferpanel

    echo -e "${YELLOW}[INFO] Removing PufferPanel Package...${NC}"
    sudo apt-get purge pufferpanel -y
    sudo apt-get autoremove -y

    echo -e "${YELLOW}[INFO] Deleting Data Directories (Servers & Configs)...${NC}"
    sudo rm -rf /var/lib/pufferpanel
    sudo rm -rf /etc/pufferpanel

    echo -e "${YELLOW}[INFO] Cleaning up Firewall Rules...${NC}"
    if command -v ufw > /dev/null; then
        sudo ufw delete allow 8080/tcp
        sudo ufw delete allow 5657/tcp
        sudo ufw reload
    fi

    echo ""
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${GREEN}      UNINSTALL COMPLETE - KS HOSTING                 ${NC}"
    echo -e "${CYAN}======================================================${NC}"
    echo ""
}

# ==========================================
# MAIN MENU
# ==========================================
show_banner
show_loading

echo -e "Select an option:"
echo -e "${GREEN}[1] Install PufferPanel${NC}"
echo -e "${RED}[2] Uninstall PufferPanel${NC}"
echo -e "${YELLOW}[3] Exit${NC}"
echo ""
read -p "Enter your choice [1-3]: " choice

case $choice in
    1)
        install_panel
        ;;
    2)
        uninstall_panel
        ;;
    3)
        echo -e "${GREEN}Exiting...${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting...${NC}"
        exit 1
        ;;
esac
