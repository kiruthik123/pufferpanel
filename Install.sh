#!/bin/bash

# ==============================================================================
#  ⚡ KS HOSTING - ULTIMATE PUFFERPANEL MANAGER ⚡
#  Version: 2.2 | Author: KSGAMING | License: MIT
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
GRAY='\033[90m'
ORANGE='\033[38;5;208m'
PURPLE='\033[38;5;93m'
LIME='\033[38;5;154m'

# 📁 LOGGING
LOG_FILE="/var/log/kshosting_install.log"
exec 3>&1

# 🌈 BANNER
show_banner() {
    clear
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}║    ⚡ ${PURPLE}K S   H O S T I N G   P R O F E S S I O N A L ⚡    ${BLUE}║${RESET}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "  ${WHITE}🏆 Ultimate Game Server Management Platform${RESET}"
    echo -e "  ${YELLOW}✨ Version 2.2 | Professional Edition ✨${RESET}"
    echo ""
}

# 📏 LINES
print_line() {
    echo -e "${PURPLE}──────────────────────────────────────────────────────────────${RESET}"
}

# 🔄 SPINNER
spinner() {
    local pid=$1
    local delay=0.1
    local spin_chars=("⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷")
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        echo -ne "\r  ${spin_chars[$i]} ${YELLOW}Processing...${RESET}"
        i=$(((i + 1) % 8))
        sleep $delay
    done
    echo -ne "\r\033[K"
}

# ✅ EXECUTE
execute() {
    local message="$1"
    local command="$2"
    
    echo -ne "  ${BLUE}➤${RESET} ${WHITE}${message}${RESET}"
    
    eval "$command" >> "$LOG_FILE" 2>&1 &
    local pid=$!
    
    spinner $pid
    wait $pid
    
    if [ $? -eq 0 ]; then
        echo -e "\r  ${GREEN}✓${RESET} ${LIME}${message} ${GREEN}Done${RESET}"
    else
        echo -e "\r  ${RED}✗${RESET} ${RED}${message} ${ORANGE}Failed${RESET}"
    fi
}

# 🛡️ ROOT CHECK
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}"
    echo "  ╔══════════════════════════════════════════════════╗"
    echo "  ║                                                    ║"
    echo "  ║  🔒 Permission Denied! 🔒                          ║"
    echo "  ║                                                    ║"
    echo "  ║  Please run as root: ${WHITE}sudo ./install.sh${RED}            ║"
    echo "  ║                                                    ║"
    echo "  ╚══════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    exit 1
fi

# ==============================================================================
#  🚀 INSTALL PANEL
# ==============================================================================
install_panel() {
    show_banner
    echo -e "${CYAN}🚀 STARTING INSTALLATION${RESET}"
    print_line
    
    execute "Updating System" "apt-get update -y"
    execute "Installing Tools" "apt-get install -y curl wget git sudo"
    
    if ! command -v docker > /dev/null; then
        execute "Installing Docker" "curl -fsSL https://get.docker.com | sh"
        execute "Starting Docker" "systemctl enable --now docker"
    else
        echo -e "  ${GREEN}🎯 Docker already installed${RESET}"
    fi
    
    print_line
    execute "Adding PufferPanel" "curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | bash"
    execute "Installing Panel" "apt-get install pufferpanel -y"
    execute "Starting Service" "systemctl enable --now pufferpanel"
    
    if command -v ufw > /dev/null; then
        execute "Setting Firewall" "ufw allow 8080/tcp && ufw allow 5657/tcp && ufw reload"
    fi
    
    print_line
    echo ""
    echo -e "${CYAN}👑 CREATE ADMIN ACCOUNT${RESET}"
    print_line
    
    read -p "  📧 Email: " admin_email
    read -p "  👤 Username: " admin_name
    read -s -p "  🔑 Password: " admin_pass
    echo ""
    
    execute "Creating Admin" "pufferpanel user add --email \"$admin_email\" --name \"$admin_name\" --password \"$admin_pass\" --admin"
    
    print_line
    echo ""
    echo -e "${CYAN}🌐 PANEL ACCESS${RESET}"
    echo -e "  ${GRAY}Enter your server IP or domain${RESET}"
    echo -e "  ${GRAY}Example: panel.myserver.com or 192.168.1.100${RESET}"
    print_line
    
    read -p "  🔗 URL/IP: " panel_host
    
    clear
    show_banner
    echo -e "${GREEN}"
    echo "  ╔══════════════════════════════════════════════════════╗"
    echo "  ║                                                      ║"
    echo "  ║               🎉 INSTALLATION COMPLETE 🎉            ║"
    echo "  ║                                                      ║"
    echo "  ╚══════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    
    echo -e "${CYAN}📋 YOUR PANEL DETAILS${RESET}"
    print_line
    echo -e "  ${GREEN}┌────────────────────────────────────────────────────┐${RESET}"
    echo -e "  ${GREEN}│ ${WHITE}🌐 Panel URL:   ${YELLOW}http://$panel_host:8080${RESET}       ${GREEN}│${RESET}"
    echo -e "  ${GREEN}│ ${WHITE}🔌 SFTP Port:   ${YELLOW}5657${RESET}                          ${GREEN}│${RESET}"
    echo -e "  ${GREEN}│ ${WHITE}👤 Username:    ${YELLOW}$admin_name${RESET}                  ${GREEN}│${RESET}"
    echo -e "  ${GREEN}│ ${WHITE}📧 Email:       ${YELLOW}$admin_email${RESET}                 ${GREEN}│${RESET}"
    echo -e "  ${GREEN}└────────────────────────────────────────────────────┘${RESET}"
    print_line
    
    echo -e "  ${MAGENTA}💫 Thank you for choosing KS HOSTING!${RESET}"
    echo ""
}

# ==============================================================================
#  🗑️ EASY DELETE
# ==============================================================================
delete_panel() {
    show_banner
    
    echo -e "${RED}"
    echo "  ╔══════════════════════════════════════════════════════╗"
    echo "  ║                                                      ║"
    echo "  ║                🗑️  REMOVE PANEL 🗑️                  ║"
    echo "  ║                                                      ║"
    echo "  ╚══════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    
    echo -e "${ORANGE}⚠️  WARNING: This will remove:${RESET}"
    echo -e "  ${RED}• All game servers${RESET}"
    echo -e "  ${RED}• All user accounts${RESET}"
    echo -e "  ${RED}• All settings${RESET}"
    echo -e "  ${RED}• All server files${RESET}"
    
    print_line
    
    echo -e "${YELLOW}❓ Are you sure? (y/N): ${RESET}"
    echo -ne "  ${RED}>>> ${RESET}"
    read -n 1 confirm_delete
    echo ""
    
    if [[ ! "$confirm_delete" =~ ^[Yy]$ ]]; then
        echo -e "  ${GREEN}✅ Delete cancelled${RESET}"
        return
    fi
    
    print_line
    
    # Simple one-liner removal
    echo -e "  ${BLUE}🗑️  Removing PufferPanel...${RESET}"
    
    # Stop and disable service
    systemctl stop pufferpanel 2>/dev/null
    systemctl disable pufferpanel 2>/dev/null
    
    # Remove package
    apt-get remove --purge pufferpanel -y 2>/dev/null
    
    # Clean up files
    rm -rf /var/lib/pufferpanel 2>/dev/null
    rm -rf /etc/pufferpanel 2>/dev/null
    
    # Clean firewall
    ufw delete allow 8080/tcp 2>/dev/null
    ufw delete allow 5657/tcp 2>/dev/null
    ufw reload 2>/dev/null
    
    # Remove orphan packages
    apt-get autoremove -y 2>/dev/null
    
    echo ""
    print_line
    echo -e "  ${GREEN}✅ PufferPanel removed successfully!${RESET}"
    echo -e "  ${YELLOW}📝 Note: Your game files in /home might still exist${RESET}"
    echo ""
}

# ==============================================================================
#  📊 CHECK STATUS
# ==============================================================================
check_status() {
    show_banner
    
    echo -e "${CYAN}📊 PANEL STATUS${RESET}"
    print_line
    
    # Check service
    if systemctl is-active --quiet pufferpanel; then
        echo -e "  ${GREEN}✅ Panel: RUNNING${RESET}"
    else
        echo -e "  ${RED}❌ Panel: STOPPED${RESET}"
    fi
    
    # Check Docker
    if systemctl is-active --quiet docker; then
        echo -e "  ${GREEN}✅ Docker: RUNNING${RESET}"
    else
        echo -e "  ${RED}❌ Docker: STOPPED${RESET}"
    fi
    
    # Check ports
    echo -e "  ${BLUE}🔍 Open Ports:${RESET}"
    if ss -tulpn | grep -q ":8080"; then
        echo -e "    ${GREEN}✓ 8080 (Panel) - OPEN${RESET}"
    else
        echo -e "    ${RED}✗ 8080 (Panel) - CLOSED${RESET}"
    fi
    
    if ss -tulpn | grep -q ":5657"; then
        echo -e "    ${GREEN}✓ 5657 (SFTP) - OPEN${RESET}"
    else
        echo -e "    ${RED}✗ 5657 (SFTP) - CLOSED${RESET}"
    fi
    
    print_line
    echo ""
}

# ==============================================================================
#  🎮 MAIN MENU
# ==============================================================================
while true; do
    show_banner
    
    echo -e "${WHITE}📋 MAIN MENU${RESET}"
    print_line
    echo -e "  ${GREEN}[1] 🚀 Install PufferPanel${RESET}"
    echo -e "  ${BLUE}[2] 📊 Check Status${RESET}"
    echo -e "  ${RED}[3] 🗑️  Remove Panel${RESET}"
    echo -e "  ${GRAY}[4] 🚪 Exit${RESET}"
    print_line
    
    echo -ne "  ${WHITE}👉 Choose [1-4]: ${RESET}"
    read -n 1 choice
    echo ""
    
    case $choice in
        1)
            install_panel
            ;;
        2)
            check_status
            ;;
        3)
            delete_panel
            ;;
        4)
            echo -e "  ${GREEN}👋 Goodbye!${RESET}"
            echo ""
            exit 0
            ;;
        *)
            echo -e "  ${RED}❌ Invalid choice${RESET}"
            ;;
    esac
    
    if [ "$choice" != "4" ]; then
        echo -e "\n  ${WHITE}Press ${GREEN}[ENTER]${WHITE} to continue...${RESET}"
        read
    fi
done
