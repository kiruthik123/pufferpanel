#!/bin/bash

# ==============================================================================
#  KS HOSTING - ULTIMATE PUFFERPANEL MANAGER
#  Author: KSGAMING
# ==============================================================================

# 🎨 COLOR PALETTE
RESET='\033[0m'
BOLD='\033[1m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
GRAY='\033[1;30m'

# 📁 LOGGING SETUP
LOG_FILE="kshosting_install.log"
exec 3>&1 # Save original stdout

# 📏 SEPARATOR LINE FUNCTION
print_line() {
    echo -e "  ${GRAY}------------------------------------------------------${RESET}"
}

# 🔄 ANIMATION FUNCTION
execute() {
    local message="$1"
    local command="$2"
    
    # Print the "Loading" line
    echo -ne "  ⏳ ${YELLOW}${message}...${RESET}"
    
    # Run command in background, silence ALL output to log
    # We use nohup to try and detach from terminal noise
    eval "$command" > "$LOG_FILE" 2>&1 &
    local pid=$!
    
    # Animation loop
    local delay=0.1
    local spinstr='|/-\'
    while ps -p $pid > /dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done

    # Check exit status
    wait $pid
    local exit_code=$?

    # Clear the line fully to overwrite any system noise
    echo -ne "\r\033[K" 

    # Print result
    if [ $exit_code -eq 0 ]; then
        echo -e "  ✅ ${GREEN}${message} - COMPLETED${RESET}"
    else
        echo -e "  ❌ ${RED}${message} - FAILED${RESET}"
        echo -e "  ${RED}[!] Check $LOG_FILE for error details.${RESET}"
        read -p "Press Enter to continue anyway..."
    fi
    
    # Add the requested separator line
    print_line
}

# 🖼️ BANNER
show_banner() {
    clear
    echo -e "${CYAN}  ╔══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}  ║           ${MAGENTA}⚡ KS HOSTING BY KSGAMING ⚡${CYAN}               ║${RESET}"
    echo -e "${CYAN}  ║      ${WHITE}High Performance Game Server Management${CYAN}         ║${RESET}"
    echo -e "${CYAN}  ╚══════════════════════════════════════════════════════╝${RESET}"
    echo -e "  ${YELLOW}▶ Script Version: 2.1 (Lines Added)${RESET}"
    echo ""
}

# 🛡️ ROOT CHECK
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}  ❌ ERROR: You must be root (sudo) to run this script!${RESET}" 1>&2
   exit 1
fi

# ==============================================================================
#  🛠️ INSTALLATION LOGIC
# ==============================================================================
install_panel() {
    echo -e "${BLUE}  [🚀] STARTING INSTALLATION PROCESS...${RESET}"
    echo -e "${WHITE}  Logs are being saved to: ${LOG_FILE}${RESET}"
    print_line

    # 1. DEPENDENCIES
    execute "Updating System & Basics" "apt-get update -y && apt-get install -y curl wget git sudo"

    # 2. DOCKER CHECK
    if ! command -v docker > /dev/null; then
        execute "Installing Docker Engine" "curl -fsSL https://get.docker.com | sh && systemctl enable --now docker"
    else
        echo -e "  ✅ ${GREEN}Docker Engine is already installed${RESET}"
        print_line
    fi

    # 3. REPOSITORY
    execute "Adding PufferPanel Repo" "curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | bash"

    # 4. INSTALLATION
    execute "Installing PufferPanel Core" "apt-get install pufferpanel -y"

    # 5. SERVICE
    execute "Starting Panel Service" "systemctl enable --now pufferpanel"

    # 6. FIREWALL
    if command -v ufw > /dev/null; then
        execute "Configuring Firewall (8080/5657)" "ufw allow 8080/tcp && ufw allow 5657/tcp && ufw reload"
    else
        echo -e "  ⚠️ ${YELLOW}UFW not found. Skipping Firewall setup.${RESET}"
        print_line
    fi

    # 7. USER SETUP (INTERACTIVE)
    echo ""
    echo -e "${CYAN}  ╔════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}  ║        👤 ADMIN USER CONFIGURATION         ║${RESET}"
    echo -e "${CYAN}  ╚════════════════════════════════════════════╝${RESET}"
    echo ""
    
    echo -e "${WHITE}  Please enter details for the main admin account:${RESET}"
    read -p "  📧 Email Address: " admin_email
    read -p "  👤 Username: " admin_name
    read -s -p "  🔑 Password: " admin_pass
    echo "" 

    print_line
    execute "Creating Admin Account" "pufferpanel user add --email \"$admin_email\" --name \"$admin_name\" --password \"$admin_pass\" --admin"

    # 8. URL SETUP
    echo ""
    echo -e "${WHITE}  🌐 Enter your Panel Domain or IP (e.g., panel.kshosting.com):${RESET}"
    read -p "  >> " panel_host

    # 9. SUCCESS SCREEN
    clear
    echo -e "${GREEN}  🎉 INSTALLATION SUCCESSFUL! 🎉${RESET}"
    echo -e "${CYAN}  ══════════════════════════════════════════════${RESET}"
    echo -e "  🚀 ${BOLD}Panel URL:${RESET}  ${YELLOW}http://$panel_host:8080${RESET}"
    echo -e "  📂 ${BOLD}SFTP Port:${RESET}  ${YELLOW}5657${RESET}"
    echo -e "  👤 ${BOLD}User:${RESET}       ${WHITE}$admin_name${RESET}"
    echo -e "  📧 ${BOLD}Email:${RESET}      ${WHITE}$admin_email${RESET}"
    echo -e "${CYAN}  ══════════════════════════════════════════════${RESET}"
    echo -e "  ${MAGENTA}Thank you for choosing KS HOSTING!${RESET}"
    echo ""
}

# ==============================================================================
#  🗑️ UNINSTALL LOGIC
# ==============================================================================
uninstall_panel() {
    echo ""
    echo -e "${RED}  💣 DANGER ZONE: UNINSTALL${RESET}"
    echo -e "${YELLOW}  This will delete ALL servers, data, and configurations.${RESET}"
    echo -ne "  Type ${RED}AGREE${RESET} to confirm destruction: "
    read confirmation

    if [ "$confirmation" != "AGREE" ]; then
        echo -e "  🚫 ${GREEN}Action Cancelled.${RESET}"
        return
    fi

    echo ""
    print_line
    execute "Stopping Services" "systemctl stop pufferpanel && systemctl disable pufferpanel"
    execute "Removing Package" "apt-get purge pufferpanel -y && apt-get autoremove -y"
    execute "Deleting Server Data" "rm -rf /var/lib/pufferpanel && rm -rf /etc/pufferpanel"
    
    if command -v ufw > /dev/null; then
        execute "Cleaning Firewall" "ufw delete allow 8080/tcp && ufw delete allow 5657/tcp && ufw reload"
    fi

    echo ""
    echo -e "  🗑️ ${GREEN}PufferPanel has been completely removed.${RESET}"
}

# ==============================================================================
#  🎮 MAIN MENU LOOP
# ==============================================================================
while true; do
    show_banner
    echo -e "  ${WHITE}Select an action:${RESET}"
    echo -e "  ${GREEN}[1] 💿 Install PufferPanel (Recommended)${RESET}"
    echo -e "  ${RED}[2] 🗑️ Uninstall PufferPanel${RESET}"
    echo -e "  ${YELLOW}[3] 🚪 Exit${RESET}"
    echo ""
    echo -ne "  👉 ${BOLD}Choice [1-3]: ${RESET}"
    read choice

    case $choice in
        1)
            install_panel
            print_line
            read -p "  Press [ENTER] to return to menu..."
            ;;
        2)
            uninstall_panel
            print_line
            read -p "  Press [ENTER] to return to menu..."
            ;;
        3)
            echo -e "  👋 ${CYAN}Goodbye!${RESET}"
            exit 0
            ;;
        *)
            echo -e "  ❌ ${RED}Invalid option.${RESET}"
            sleep 1
            ;;
    esac
done
