#!/bin/bash

# ==============================================================================
#  ⚡ KS HOSTING - ULTIMATE PUFFERPANEL MANAGER ⚡
#  Version: 2.1 | Author: KSGAMING | License: MIT
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

# 📁 LOGGING SETUP
LOG_FILE="/var/log/kshosting_install.log"
exec 3>&1

# 🌈 GRADIENT TEXT EFFECT
gradient() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}║    ⚡ ${PURPLE}K S   H O S T I N G   P R O F E S S I O N A L ⚡    ${BLUE}║${RESET}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${RESET}"
}

# 📏 SEPARATOR LINE FUNCTION
print_line() {
    echo -e "${PURPLE}┌────────────────────────────────────────────────────────────┐${RESET}"
}

print_endline() {
    echo -e "${PURPLE}└────────────────────────────────────────────────────────────┘${RESET}"
}

# 🔄 SPINNER ANIMATION FUNCTION
spinner() {
    local pid=$1
    local delay=0.1
    local spin_chars=("🕐" "🕑" "🕒" "🕓" "🕔" "🕕" "🕖" "🕗" "🕘" "🕙" "🕚" "🕛")
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        echo -ne "\r  ${spin_chars[$i]} ${YELLOW}Processing...${RESET}"
        i=$(((i + 1) % 12))
        sleep $delay
    done
    echo -ne "\r\033[K"
}

# ✅ EXECUTE WITH ANIMATION
execute() {
    local message="$1"
    local command="$2"
    local critical="${3:-false}"
    
    echo -ne "  ${BLUE}➤${RESET} ${WHITE}${message}${RESET}"
    
    eval "$command" >> "$LOG_FILE" 2>&1 &
    local pid=$!
    
    spinner $pid
    
    wait $pid
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo -e "\r  ${GREEN}✓${RESET} ${LIME}${message} ${GREEN}SUCCESS${RESET}"
    else
        echo -e "\r  ${RED}✗${RESET} ${RED}${message} ${ORANGE}FAILED${RESET}"
        if [ "$critical" = "true" ]; then
            echo -e "  ${RED}⚠  CRITICAL ERROR - Installation cannot continue${RESET}"
            echo -e "  ${YELLOW}📋 Check log: ${WHITE}$LOG_FILE${RESET}"
            exit 1
        fi
    fi
}

# 🖼️ DYNAMIC BANNER
show_banner() {
    clear
    echo ""
    gradient
    echo ""
    echo -e "  ${WHITE}┌────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "  ${WHITE}│     ${CYAN}🏆 ${PURPLE}Ultimate Game Server Management Platform ${CYAN}🏆     ${WHITE}│${RESET}"
    echo -e "  ${WHITE}│     ${YELLOW}✨ Version 2.1 | Professional Edition ✨      ${WHITE}│${RESET}"
    echo -e "  ${WHITE}└────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
}

# 🛡️ ROOT CHECK
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo -e "${RED}"
        echo "  ╔══════════════════════════════════════════════════╗"
        echo "  ║                                                    ║"
        echo "  ║  🔒 ${WHITE}P E R M I S S I O N   D E N I E D 🔒      ${RED}║"
        echo "  ║                                                    ║"
        echo "  ║  This script requires ${YELLOW}root privileges${RED}         ║"
        echo "  ║  Please run with: ${WHITE}sudo ./install.sh${RED}            ║"
        echo "  ║                                                    ║"
        echo "  ╚══════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        exit 1
    fi
}

# 🔍 SYSTEM CHECK
system_check() {
    echo -e "${CYAN}"
    echo "  📊 SYSTEM ANALYSIS"
    echo -e "${WHITE}"
    print_line
    
    # Check OS
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo -e "  ${GREEN}✓${RESET} ${WHITE}OS:${RESET} ${YELLOW}$PRETTY_NAME${RESET}"
    else
        echo -e "  ${YELLOW}⚠${RESET} ${WHITE}OS:${RESET} ${ORANGE}Unknown Linux Distribution${RESET}"
    fi
    
    # Check RAM
    total_ram=$(free -h | awk '/^Mem:/ {print $2}')
    echo -e "  ${GREEN}✓${RESET} ${WHITE}RAM:${RESET} ${YELLOW}$total_ram${RESET}"
    
    # Check Disk Space
    disk_space=$(df -h / | awk 'NR==2 {print $4}')
    echo -e "  ${GREEN}✓${RESET} ${WHITE}Disk:${RESET} ${YELLOW}$disk_space free${RESET}"
    
    print_endline
    echo ""
}

# ==============================================================================
#  🚀 INSTALLATION PROCESS
# ==============================================================================
install_panel() {
    show_banner
    system_check
    
    echo -e "${CYAN}  🚀 STARTING PROFESSIONAL INSTALLATION ${RESET}"
    echo -e "${GRAY}  📝 Log file: ${WHITE}$LOG_FILE${RESET}"
    print_line
    
    # 1. SYSTEM UPDATE
    execute "Updating System Packages" "apt-get update -y && apt-get upgrade -y" "true"
    
    # 2. ESSENTIAL DEPENDENCIES
    execute "Installing Essential Tools" "apt-get install -y curl wget git sudo gnupg2 ca-certificates apt-transport-https software-properties-common" "true"
    
    # 3. DOCKER INSTALLATION
    if ! command -v docker > /dev/null; then
        execute "Installing Docker Engine" "curl -fsSL https://get.docker.com | sh" "true"
        execute "Starting Docker Service" "systemctl enable --now docker" "true"
        execute "Testing Docker" "docker run hello-world --quiet" "false"
    else
        echo -e "  ${GREEN}🎯 Docker already installed${RESET}"
        docker_version=$(docker --version | cut -d' ' -f3 | tr -d ',')
        echo -e "  ${BLUE}ℹ Version: ${WHITE}$docker_version${RESET}"
    fi
    
    print_line
    
    # 4. PUFFERPANEL REPOSITORY
    execute "Adding PufferPanel Repository" "curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | bash" "true"
    
    # 5. PANEL INSTALLATION
    execute "Installing PufferPanel Core" "apt-get install pufferpanel -y" "true"
    
    # 6. SERVICE CONFIGURATION
    execute "Configuring Panel Service" "systemctl enable --now pufferpanel" "true"
    
    # 7. FIREWALL CONFIGURATION
    if command -v ufw > /dev/null; then
        execute "Configuring Firewall Rules" "ufw allow 8080/tcp && ufw allow 5657/tcp && ufw allow 80/tcp && ufw allow 443/tcp && ufw reload" "false"
    else
        echo -e "  ${YELLOW}⚠ Firewall (UFW) not installed${RESET}"
        echo -e "  ${BLUE}ℹ Consider installing UFW for better security${RESET}"
    fi
    
    print_line
    
    # 8. ADMIN USER CREATION
    echo ""
    echo -e "${CYAN}  👑 ADMINISTRATOR ACCOUNT SETUP ${RESET}"
    echo -e "${WHITE}  Please provide details for the main administrator:${RESET}"
    print_line
    
    while true; do
        read -p "  📧 ${WHITE}Email Address: ${RESET}" admin_email
        if [[ "$admin_email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            break
        else
            echo -e "  ${RED}✗ Invalid email format${RESET}"
        fi
    done
    
    while true; do
        read -p "  👤 ${WHITE}Username (3-20 chars): ${RESET}" admin_name
        if [[ "$admin_name" =~ ^[a-zA-Z0-9_]{3,20}$ ]]; then
            break
        else
            echo -e "  ${RED}✗ Invalid username${RESET}"
        fi
    done
    
    while true; do
        read -s -p "  🔑 ${WHITE}Password (min 8 chars): ${RESET}" admin_pass
        echo ""
        if [ ${#admin_pass} -ge 8 ]; then
            read -s -p "  🔑 ${WHITE}Confirm Password: ${RESET}" admin_pass2
            echo ""
            if [ "$admin_pass" = "$admin_pass2" ]; then
                break
            else
                echo -e "  ${RED}✗ Passwords don't match${RESET}"
            fi
        else
            echo -e "  ${RED}✗ Password too short${RESET}"
        fi
    done
    
    execute "Creating Admin Account" "pufferpanel user add --email \"$admin_email\" --name \"$admin_name\" --password \"$admin_pass\" --admin" "true"
    
    print_line
    
    # 9. DOMAIN CONFIGURATION
    echo ""
    echo -e "${CYAN}  🌐 NETWORK CONFIGURATION ${RESET}"
    echo -e "${WHITE}  Enter your panel access URL:${RESET}"
    echo -e "  ${GRAY}Examples:${RESET}"
    echo -e "  ${YELLOW}• panel.yourdomain.com${RESET}"
    echo -e "  ${YELLOW}• 192.168.1.100${RESET}"
    echo -e "  ${YELLOW}• localhost${RESET}"
    print_line
    
    read -p "  🔗 ${WHITE}Panel URL/IP: ${RESET}" panel_host
    
    # 10. FINAL SUCCESS DISPLAY
    clear
    show_banner
    
    echo -e "${GREEN}"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║                                                              ║"
    echo "  ║                    🎉 INSTALLATION COMPLETE 🎉               ║"
    echo "  ║                                                              ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    
    echo -e "${CYAN}  📋 INSTALLATION SUMMARY ${RESET}"
    print_line
    echo -e "  ${GREEN}┌────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "  ${GREEN}│ ${WHITE}🌐 ${CYAN}Panel URL${WHITE}:    ${YELLOW}http://$panel_host:8080${RESET}           ${GREEN}│${RESET}"
    echo -e "  ${GREEN}│ ${WHITE}🔌 ${CYAN}SFTP Port${WHITE}:    ${YELLOW}5657${RESET}                              ${GREEN}│${RESET}"
    echo -e "  ${GREEN}│ ${WHITE}👑 ${CYAN}Admin User${WHITE}:   ${YELLOW}$admin_name${RESET}                      ${GREEN}│${RESET}"
    echo -e "  ${GREEN}│ ${WHITE}📧 ${CYAN}Admin Email${WHITE}:  ${YELLOW}$admin_email${RESET}                     ${GREEN}│${RESET}"
    echo -e "  ${GREEN}│ ${WHITE}📂 ${CYAN}Data Path${WHITE}:    ${YELLOW}/var/lib/pufferpanel${RESET}             ${GREEN}│${RESET}"
    echo -e "  ${GREEN}│ ${WHITE}📜 ${CYAN}Logs Path${WHITE}:    ${YELLOW}$LOG_FILE${RESET}           ${GREEN}│${RESET}"
    echo -e "  ${GREEN}└────────────────────────────────────────────────────────────┘${RESET}"
    
    print_line
    echo -e "  ${PURPLE}🚀 NEXT STEPS:${RESET}"
    echo -e "  ${WHITE}1. ${YELLOW}Access your panel at: ${WHITE}http://$panel_host:8080${RESET}"
    echo -e "  ${WHITE}2. ${YELLOW}Login with your admin credentials${RESET}"
    echo -e "  ${WHITE}3. ${YELLOW}Add your first game server from the dashboard${RESET}"
    echo -e "  ${WHITE}4. ${YELLOW}Configure reverse proxy for HTTPS (recommended)${RESET}"
    print_endline
    
    echo -e "  ${MAGENTA}💫 Thank you for choosing KS HOSTING Professional!${RESET}"
    echo ""
}

# ==============================================================================
#  🗑️ UNINSTALL PROCESS
# ==============================================================================
uninstall_panel() {
    show_banner
    
    echo -e "${RED}"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║                                                              ║"
    echo "  ║                    ⚠️  D A N G E R  Z O N E ⚠️               ║"
    echo "  ║                                                              ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    
    echo -e "${ORANGE}  ⚠  This action will:${RESET}"
    echo -e "  ${RED}• Remove all game servers${RESET}"
    echo -e "  ${RED}• Delete all user accounts${RESET}"
    echo -e "  ${RED}• Erase all configurations${RESET}"
    echo -e "  ${RED}• Remove all server data${RESET}"
    
    print_line
    echo -e "  ${WHITE}Type ${RED}'CONFIRM_DESTRUCTION'${WHITE} to proceed:${RESET}"
    echo -ne "  ${RED}>>> ${RESET}"
    read confirmation
    
    if [ "$confirmation" != "CONFIRM_DESTRUCTION" ]; then
        echo -e "  ${GREEN}✅ Operation cancelled${RESET}"
        return
    fi
    
    print_line
    execute "Stopping Services" "systemctl stop pufferpanel"
    execute "Disabling Services" "systemctl disable pufferpanel"
    execute "Removing Package" "apt-get purge pufferpanel -y"
    execute "Cleaning Data" "rm -rf /var/lib/pufferpanel /etc/pufferpanel"
    execute "Removing Dependencies" "apt-get autoremove -y"
    
    if command -v ufw > /dev/null; then
        execute "Resetting Firewall" "ufw delete allow 8080/tcp && ufw delete allow 5657/tcp && ufw reload"
    fi
    
    echo ""
    echo -e "${GREEN}  ✅ PufferPanel has been completely removed from your system${RESET}"
    echo -e "${YELLOW}  📝 Note: Game server files might still exist in user directories${RESET}"
}

# ==============================================================================
#  📊 STATUS CHECK
# ==============================================================================
check_status() {
    show_banner
    
    echo -e "${CYAN}  📊 SYSTEM STATUS CHECK ${RESET}"
    print_line
    
    # Check PufferPanel service
    if systemctl is-active --quiet pufferpanel; then
        echo -e "  ${GREEN}✅ ${WHITE}PufferPanel Service: ${GREEN}RUNNING${RESET}"
    else
        echo -e "  ${RED}❌ ${WHITE}PufferPanel Service: ${RED}STOPPED${RESET}"
    fi
    
    # Check Docker
    if systemctl is-active --quiet docker; then
        echo -e "  ${GREEN}✅ ${WHITE}Docker Service: ${GREEN}RUNNING${RESET}"
    else
        echo -e "  ${RED}❌ ${WHITE}Docker Service: ${RED}STOPPED${RESET}"
    fi
    
    # Check ports
    echo -e "  ${BLUE}🔍 ${WHITE}Port Check:${RESET}"
    if ss -tulpn | grep -q ":8080"; then
        echo -e "    ${GREEN}✓ Port 8080 (Panel): ${GREEN}LISTENING${RESET}"
    else
        echo -e "    ${RED}✗ Port 8080 (Panel): ${RED}CLOSED${RESET}"
    fi
    
    if ss -tulpn | grep -q ":5657"; then
        echo -e "    ${GREEN}✓ Port 5657 (SFTP): ${GREEN}LISTENING${RESET}"
    else
        echo -e "    ${RED}✗ Port 5657 (SFTP): ${RED}CLOSED${RESET}"
    fi
    
    # Disk usage
    disk_usage=$(df -h /var/lib/pufferpanel 2>/dev/null | tail -1 | awk '{print $5}')
    if [ ! -z "$disk_usage" ]; then
        echo -e "  ${BLUE}💾 ${WHITE}Disk Usage: ${YELLOW}$disk_used${RESET}"
    fi
    
    print_endline
    echo ""
}

# ==============================================================================
#  🎮 MAIN MENU
# ==============================================================================
main_menu() {
    while true; do
        show_banner
        
        echo -e "${WHITE}  📋 MAIN MENU ${RESET}"
        print_line
        echo -e "  ${GREEN}[1] 🚀 ${CYAN}Install PufferPanel (Complete Setup)${RESET}"
        echo -e "  ${BLUE}[2] 📊 ${CYAN}Check System Status${RESET}"
        echo -e "  ${YELLOW}[3] ⚙️  ${CYAN}Update Panel${RESET}"
        echo -e "  ${RED}[4] 🗑️  ${CYAN}Uninstall Panel${RESET}"
        echo -e "  ${MAGENTA}[5] ℹ️  ${CYAN}About & Support${RESET}"
        echo -e "  ${GRAY}[6] 🚪 ${CYAN}Exit${RESET}"
        print_endline
        
        echo -ne "  ${WHITE}🎮 Select option [1-6]: ${RESET}"
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
                echo -e "  ${CYAN}🔧 Update feature coming soon...${RESET}"
                ;;
            4)
                uninstall_panel
                ;;
            5)
                echo -e "  ${CYAN}📞 Support information coming soon...${RESET}"
                ;;
            6)
                echo -e "  ${GREEN}👋 Thank you for using KS HOSTING!${RESET}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "  ${RED}❌ Invalid selection${RESET}"
                ;;
        esac
        
        if [ "$choice" != "6" ]; then
            echo -e "\n  ${WHITE}Press ${GREEN}[ENTER]${WHITE} to continue...${RESET}"
            read
        fi
    done
}

# ==============================================================================
#  🏁 ENTRY POINT
# ==============================================================================

# Initial checks
check_root
trap "echo -e '\n${RED}❌ Script interrupted${RESET}'; exit 1" SIGINT

# Start main menu
main_menu
