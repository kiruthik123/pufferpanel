#!/bin/bash

# ==============================================================================
#  ⚡ KS HOSTING - ULTIMATE PUFFERPANEL MANAGER
#  Author: KSGAMING | Professional Server Solutions
#  Version: 3.0 Professional Edition
# ==============================================================================

# 🎨 PROFESSIONAL COLOR PALETTE
RESET='\033[0m'
BOLD='\033[1m'
ITALIC='\033[3m'

# 🔴 Red Variations
RED='\033[1;31m'
RED_LIGHT='\033[38;5;203m'
RED_DARK='\033[38;5;124m'

# 🟢 Green Variations
GREEN='\033[1;32m'
GREEN_LIGHT='\033[38;5;154m'
GREEN_DARK='\033[38;5;28m'

# 🟡 Yellow Variations
YELLOW='\033[1;33m'
YELLOW_LIGHT='\033[38;5;227m'
YELLOW_DARK='\033[38;5;178m'

# 🔵 Blue Variations
BLUE='\033[1;34m'
BLUE_LIGHT='\033[38;5;117m'
BLUE_DARK='\033[38;5;26m'

# 🟣 Purple Variations
PURPLE='\033[1;35m'
PURPLE_LIGHT='\033[38;5;213m'
PURPLE_DARK='\033[38;5;93m'

# 🟢 Cyan Variations
CYAN='\033[1;36m'
CYAN_LIGHT='\033[38;5;123m'
CYAN_DARK='\033[38;5;44m'

# ⚪ White/Gray Variations
WHITE='\033[1;37m'
GRAY='\033[1;90m'
GRAY_LIGHT='\033[38;5;250m'
GRAY_DARK='\033[38;5;240m'

# 🌈 Gradient Colors
GRADIENT_1='\033[38;5;213m'
GRADIENT_2='\033[38;5;207m'
GRADIENT_3='\033[38;5;201m'
GRADIENT_4='\033[38;5;165m'

# 📁 PROFESSIONAL LOGGING SYSTEM
LOG_FILE="/var/log/kshosting_install_$(date +%Y%m%d_%H%M%S).log"
AUDIT_LOG="/var/log/kshosting_audit.log"
mkdir -p /var/log/kshosting/

# Save original descriptors
exec 3>&1
exec 4>&2

# Redirect all output to log file
exec 1>>"$LOG_FILE" 2>&1

# Function to print to console (goes to original stdout via fd 3)
console() {
    echo -e "$1" >&3
}

# 📏 PROFESSIONAL SEPARATORS
print_header_line() {
    console "\n  ${GRAY_DARK}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
}

print_footer_line() {
    console "  ${GRAY_DARK}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
}

print_section_line() {
    console "  ${GRAY}╠════════════════════════════════════════════════════════════╣${RESET}"
}

print_task_line() {
    console "  ${GRAY_LIGHT}├────────────────────────────────────────────────────────┤${RESET}"
}

# 📊 PROFESSIONAL STATUS FUNCTIONS
log_audit() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$AUDIT_LOG"
}

show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percent=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    
    console -ne "\r  ${BLUE}[${RESET}"
    printf "%0.s█" $(seq 1 $filled)
    printf "%0.s░" $(seq 1 $empty)
    console -ne "${BLUE}] ${GREEN}${percent}%${RESET} ${GRAY}(Step ${current}/${total})${RESET}"
}

# 🌟 ENHANCED LOADING ANIMATIONS
show_spinner() {
    local pid=$1
    local msg="$2"
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    console -ne "  ${BLUE}${spinstr:0:1}${RESET} ${WHITE}${msg}${RESET} "
    
    while kill -0 $pid 2>/dev/null; do
        for i in $(seq 0 9); do
            console -ne "\b${BLUE}${spinstr:$i:1}${RESET}"
            sleep $delay
        done
    done
    console -ne "\b\b"
}

show_dots() {
    local pid=$1
    local msg="$2"
    local count=0
    
    console -ne "  ${CYAN}▶${RESET} ${WHITE}${msg}${RESET} "
    
    while kill -0 $pid 2>/dev/null; do
        case $((count % 4)) in
            0) console -ne "\b${YELLOW}.${RESET}  " ;;
            1) console -ne "\b${YELLOW}..${RESET} " ;;
            2) console -ne "\b${YELLOW}...${RESET}" ;;
            3) console -ne "\b   \b\b\b" ;;
        esac
        sleep 0.5
        count=$((count + 1))
    done
    console -ne "\b\b\b\b"
}

show_pulse() {
    local pid=$1
    local msg="$2"
    local frames=("○" "◎" "●" "◎")
    
    console -ne "  ${PURPLE}${frames[0]}${RESET} ${WHITE}${msg}${RESET} "
    
    while kill -0 $pid 2>/dev/null; do
        for frame in "${frames[@]}"; do
            console -ne "\b${PURPLE}${frame}${RESET}"
            sleep 0.2
        done
    done
}

# 🚀 PROFESSIONAL EXECUTE FUNCTIONS
execute_task() {
    local task_id="$1"
    local description="$2"
    local command="$3"
    local animation="${4:-spinner}"
    
    console "\n  ${BLUE_LIGHT}➤ TASK ${task_id}:${RESET} ${BOLD}${WHITE}${description}${RESET}"
    console "  ${GRAY}└─ Command: ${ITALIC}${GRAY_LIGHT}${command:0:60}...${RESET}"
    
    # Execute command in background
    eval "$command" &
    local pid=$!
    
    # Show selected animation
    case $animation in
        "spinner") show_spinner "$pid" "Processing" ;;
        "dots") show_dots "$pid" "Running" ;;
        "pulse") show_pulse "$pid" "Executing" ;;
    esac
    
    # Wait for completion
    wait $pid
    local exit_code=$?
    
    # Show result
    if [ $exit_code -eq 0 ]; then
        console "\r  ${GREEN_LIGHT}✓ SUCCESS:${RESET} ${GREEN}${description} completed${RESET}"
        log_audit "TASK $task_id PASS: $description"
    else
        console "\r  ${RED_LIGHT}✗ FAILED:${RESET} ${RED}${description} (Code: ${exit_code})${RESET}"
        console "  ${YELLOW}  ↳ Check details: ${CYAN}tail -f ${LOG_FILE}${RESET}"
        log_audit "TASK $task_id FAIL: $description (Exit: $exit_code)"
    fi
    
    print_task_line
    return $exit_code
}

quick_execute() {
    local description="$1"
    local command="$2"
    
    console -ne "  ${CYAN}⚡ ${description}...${RESET}"
    
    if eval "$command" >/dev/null 2>&1; then
        console -e "\r  ${GREEN}✓ ${description} - Done${RESET}"
        return 0
    else
        console -e "\r  ${RED}✗ ${description} - Failed${RESET}"
        return 1
    fi
}

# 🖼️ PROFESSIONAL BANNER
show_banner() {
    clear >&3
    console ""
    console "${GRADIENT_1}  ╔══════════════════════════════════════════════════════════════════╗${RESET}"
    console "${GRADIENT_2}  ║                                                                  ║${RESET}"
    console "${GRADIENT_3}  ║    ██╗  ██╗███████╗    ██╗  ██╗ ██████╗ ███████╗████████╗██╗███╗   ██╗ ██████╗   ║${RESET}"
    console "${GRADIENT_4}  ║    ██║ ██╔╝██╔════╝    ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝██║████╗  ██║██╔════╝   ║${RESET}"
    console "${GRADIENT_1}  ║    █████╔╝ ███████╗    ███████║██║   ██║███████╗   ██║   ██║██╔██╗ ██║██║  ███╗  ║${RESET}"
    console "${GRADIENT_2}  ║    ██╔═██╗ ╚════██║    ██╔══██║██║   ██║╚════██║   ██║   ██║██║╚██╗██║██║   ██║  ║${RESET}"
    console "${GRADIENT_3}  ║    ██║  ██╗███████║    ██║  ██║╚██████╔╝███████║   ██║   ██║██║ ╚████║╚██████╔╝  ║${RESET}"
    console "${GRADIENT_4}  ║    ╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝   ║${RESET}"
    console "${GRADIENT_2}  ║                                                                  ║${RESET}"
    console "${GRADIENT_1}  ║               ${WHITE}🚀 PROFESSIONAL SERVER MANAGEMENT PLATFORM 🚀${GRADIENT_1}              ║${RESET}"
    console "${GRADIENT_1}  ╚══════════════════════════════════════════════════════════════════╝${RESET}"
    console ""
    console "  ${YELLOW}╭─ INFO ${GRAY}──────────────────────────────────────────────────────${RESET}"
    console "  ${BLUE}│${RESET} ${WHITE}Version:${RESET} ${GREEN}3.0 Professional Edition${RESET}"
    console "  ${BLUE}│${RESET} ${WHITE}Log File:${RESET} ${CYAN}${LOG_FILE}${RESET}"
    console "  ${BLUE}│${RESET} ${WHITE}Audit Log:${RESET} ${CYAN}${AUDIT_LOG}${RESET}"
    console "  ${YELLOW}╰───────────────────────────────────────────────────────────────────${RESET}"
    console ""
}

# 🛡️ PROFESSIONAL ROOT CHECK
check_requirements() {
    print_header_line
    console "  ${WHITE}🔍 SYSTEM REQUIREMENTS CHECK${RESET}"
    print_section_line
    
    # Root check
    console -ne "  ${BLUE}│${RESET} ${WHITE}Root Privileges:${RESET} "
    if [ "$(id -u)" = "0" ]; then
        console "${GREEN}✓ Granted${RESET}"
    else
        console "${RED}✗ Denied${RESET}"
        console "  ${RED}│${RESET}"
        console "  ${RED}│${RESET} ${YELLOW}This script requires root privileges.${RESET}"
        console "  ${RED}│${RESET} ${CYAN}Please run: ${BOLD}sudo bash $0${RESET}"
        print_footer_line
        exit 1
    fi
    
    # OS check
    console -ne "  ${BLUE}│${RESET} ${WHITE}Operating System:${RESET} "
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        console "${GREEN}${PRETTY_NAME}${RESET}"
    else
        console "${YELLOW}Unknown${RESET}"
    fi
    
    # Architecture check
    console -ne "  ${BLUE}│${RESET} ${WHITE}Architecture:${RESET} "
    case $(uname -m) in
        x86_64) console "${GREEN}x86_64 (64-bit)${RESET}" ;;
        aarch64) console "${GREEN}ARM64${RESET}" ;;
        *) console "${YELLOW}$(uname -m)${RESET}" ;;
    esac
    
    # Memory check
    console -ne "  ${BLUE}│${RESET} ${WHITE}Available Memory:${RESET} "
    local mem=$(free -m | awk '/^Mem:/{print $2}')
    if [ "$mem" -gt 1024 ]; then
        console "${GREEN}${mem} MB${RESET}"
    else
        console "${YELLOW}${mem} MB${RESET}"
        console "  ${YELLOW}│${RESET} ${RED_LIGHT}⚠ Warning: Minimum 1GB RAM recommended${RESET}"
    fi
    
    # Disk space check
    console -ne "  ${BLUE}│${RESET} ${WHITE}Available Disk:${RESET} "
    local disk=$(df -h / | awk 'NR==2{print $4}')
    console "${GREEN}${disk}${RESET}"
    
    print_footer_line
    console ""
}

# ==============================================================================
#  🚀 PROFESSIONAL INSTALLATION PROCESS
# ==============================================================================
install_panel() {
    local total_steps=12
    local current_step=1
    
    console "\n"
    print_header_line
    console "  ${PURPLE}🚀 INSTALLATION PROCESS INITIATED${RESET}"
    console "  ${GRAY}├────────────────────────────────────────────────────────┤${RESET}"
    console "  ${BLUE}│${RESET} ${WHITE}Start Time:${RESET} ${CYAN}$(date '+%Y-%m-%d %H:%M:%S')${RESET}"
    console "  ${BLUE}│${RESET} ${WHITE}Total Steps:${RESET} ${GREEN}${total_steps}${RESET}"
    console "  ${BLUE}│${RESET} ${WHITE}Log File:${RESET} ${CYAN}${LOG_FILE}${RESET}"
    print_footer_line
    
    log_audit "INSTALLATION STARTED"
    
    # 1. SYSTEM PREPARATION
    show_progress $current_step $total_steps
    execute_task "01" "System Package Update" "apt-get update -y" "spinner"
    current_step=$((current_step + 1))
    
    show_progress $current_step $total_steps
    execute_task "02" "Installing Essential Tools" "apt-get install -y curl wget git sudo nano htop ufw software-properties-common apt-transport-https ca-certificates gnupg lsb-release" "dots"
    current_step=$((current_step + 1))
    
    # 2. DOCKER INSTALLATION
    show_progress $current_step $total_steps
    if ! command -v docker > /dev/null; then
        execute_task "03" "Docker Repository Setup" "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && echo 'deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | tee /etc/apt/sources.list.d/docker.list > /dev/null" "spinner"
        current_step=$((current_step + 1))
        
        show_progress $current_step $total_steps
        execute_task "04" "Docker Engine Installation" "apt-get update -y && apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin" "pulse"
        current_step=$((current_step + 1))
        
        show_progress $current_step $total_steps
        execute_task "05" "Docker Service Configuration" "systemctl enable --now docker && usermod -aG docker \$SUDO_USER" "dots"
        current_step=$((current_step + 1))
    else
        console "\n  ${GREEN}✓ Docker is already installed${RESET}"
        current_step=$((current_step + 3))
    fi
    
    # 3. PUFFERPANEL INSTALLATION
    show_progress $current_step $total_steps
    execute_task "06" "PufferPanel Repository Setup" "curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | bash" "spinner"
    current_step=$((current_step + 1))
    
    show_progress $current_step $total_steps
    execute_task "07" "PufferPanel Core Installation" "apt-get install pufferpanel -y" "pulse"
    current_step=$((current_step + 1))
    
    show_progress $current_step $total_steps
    execute_task "08" "Panel Service Activation" "systemctl enable --now pufferpanel && systemctl status pufferpanel --no-pager -l" "dots"
    current_step=$((current_step + 1))
    
    # 4. NETWORK CONFIGURATION
    show_progress $current_step $total_steps
    if command -v ufw > /dev/null; then
        execute_task "09" "Firewall Configuration" "ufw --force enable && ufw allow 22/tcp && ufw allow 8080/tcp && ufw allow 5657/tcp && ufw --force reload" "spinner"
    else
        execute_task "09" "Opening Required Ports" "iptables -A INPUT -p tcp --dport 8080 -j ACCEPT && iptables -A INPUT -p tcp --dport 5657 -j ACCEPT" "dots"
    fi
    current_step=$((current_step + 1))
    
    # 5. ADMIN ACCOUNT SETUP
    show_progress $current_step $total_steps
    console "\n"
    print_header_line
    console "  ${CYAN}👤 ADMINISTRATOR ACCOUNT SETUP${RESET}"
    console "  ${GRAY}├────────────────────────────────────────────────────────┤${RESET}"
    console ""
    
    local admin_email admin_name admin_pass
    while true; do
        console -ne "  ${BLUE}│${RESET} ${WHITE}📧 Admin Email Address: ${RESET}"
        read -r admin_email >&3
        if [[ "$admin_email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            break
        else
            console "  ${RED}│${RESET} ${YELLOW}⚠ Please enter a valid email address${RESET}"
        fi
    done
    
    console -ne "  ${BLUE}│${RESET} ${WHITE}👤 Admin Username: ${RESET}"
    read -r admin_name >&3
    
    console -ne "  ${BLUE}│${RESET} ${WHITE}🔑 Admin Password: ${RESET}"
    read -s -r admin_pass >&3
    console ""
    
    console -ne "  ${BLUE}│${RESET} ${WHITE}🔒 Confirm Password: ${RESET}"
    read -s -r admin_pass_confirm >&3
    console ""
    
    if [ "$admin_pass" != "$admin_pass_confirm" ]; then
        console "  ${RED}│${RESET} ${RED_LIGHT}✗ Passwords do not match!${RESET}"
        return 1
    fi
    
    print_footer_line
    
    execute_task "10" "Creating Admin Account" "pufferpanel user add --email \"$admin_email\" --name \"$admin_name\" --password \"$admin_pass\" --admin" "pulse"
    current_step=$((current_step + 1))
    
    # 6. PANEL URL SETUP
    show_progress $current_step $total_steps
    console "\n"
    print_header_line
    console "  ${CYAN}🌐 PANEL ACCESS CONFIGURATION${RESET}"
    console "  ${GRAY}├────────────────────────────────────────────────────────┤${RESET}"
    console ""
    
    console "  ${BLUE}│${RESET} ${WHITE}Enter your panel access URL:${RESET}"
    console "  ${BLUE}│${RESET} ${GRAY}Examples:${RESET}"
    console "  ${BLUE}│${RESET}   ${CYAN}• panel.yourdomain.com${RESET}"
    console "  ${BLUE}│${RESET}   ${CYAN}• 192.168.1.100${RESET}"
    console "  ${BLUE}│${RESET}   ${CYAN}• server.yourhost.com${RESET}"
    console ""
    console -ne "  ${BLUE}│${RESET} ${GREEN}➤ ${WHITE}Panel URL/IP: ${RESET}"
    read -r panel_host >&3
    print_footer_line
    
    current_step=$((current_step + 1))
    
    # 7. FINALIZATION
    show_progress $current_step $total_steps
    execute_task "11" "Final System Configuration" "pufferpanel configure && systemctl daemon-reload" "spinner"
    current_step=$((current_step + 1))
    
    # INSTALLATION COMPLETE
    console "\n"
    print_header_line
    console "  ${GREEN}🎉 INSTALLATION COMPLETED SUCCESSFULLY!${RESET}"
    print_section_line
    
    # Display system information
    local ip_address=$(hostname -I | awk '{print $1}')
    local public_ip=$(curl -s -4 ifconfig.me 2>/dev/null || echo "Not detected")
    
    console "  ${BLUE}│${RESET} ${WHITE}📊 SYSTEM INFORMATION${RESET}"
    console "  ${BLUE}│${RESET} ${GRAY}├─ Local IP:${RESET} ${CYAN}${ip_address}${RESET}"
    console "  ${BLUE}│${RESET} ${GRAY}├─ Public IP:${RESET} ${CYAN}${public_ip}${RESET}"
    console "  ${BLUE}│${RESET} ${GRAY}├─ Hostname:${RESET} ${CYAN}$(hostname)${RESET}"
    
    print_section_line
    console "  ${BLUE}│${RESET} ${WHITE}🔗 PANEL ACCESS DETAILS${RESET}"
    console "  ${BLUE}│${RESET} ${GRAY}├─ Panel URL:${RESET} ${YELLOW}http://${panel_host}:8080${RESET}"
    console "  ${BLUE}│${RESET} ${GRAY}├─ SFTP Port:${RESET} ${YELLOW}5657${RESET}"
    console "  ${BLUE}│${RESET} ${GRAY}├─ Admin User:${RESET} ${GREEN}${admin_name}${RESET}"
    console "  ${BLUE}│${RESET} ${GRAY}├─ Admin Email:${RESET} ${GREEN}${admin_email}${RESET}"
    
    print_section_line
    console "  ${BLUE}│${RESET} ${WHITE}⚙️  SERVICE STATUS${RESET}"
    console -ne "  ${BLUE}│${RESET} ${GRAY}├─ PufferPanel:${RESET} "
    if systemctl is-active --quiet pufferpanel; then
        console "${GREEN}● ACTIVE${RESET}"
    else
        console "${RED}○ INACTIVE${RESET}"
    fi
    
    console -ne "  ${BLUE}│${RESET} ${GRAY}├─ Docker:${RESET} "
    if systemctl is-active --quiet docker; then
        console "${GREEN}● ACTIVE${RESET}"
    else
        console "${RED}○ INACTIVE${RESET}"
    fi
    
    print_section_line
    console "  ${BLUE}│${RESET} ${WHITE}📋 NEXT STEPS${RESET}"
    console "  ${BLUE}│${RESET} ${CYAN}1.${RESET} Access panel at: ${YELLOW}http://${panel_host}:8080${RESET}"
    console "  ${BLUE}│${RESET} ${CYAN}2.${RESET} Login with your admin credentials"
    console "  ${BLUE}│${RESET} ${CYAN}3.${RESET} Configure your first server"
    console "  ${BLUE}│${RESET} ${CYAN}4.${RESET} Check firewall if ports are not accessible"
    
    print_footer_line
    console ""
    console "  ${PURPLE}💫 Thank you for choosing KS Hosting!${RESET}"
    console ""
    
    log_audit "INSTALLATION COMPLETED - Panel: ${panel_host}:8080"
}

# ==============================================================================
#  🗑️ PROFESSIONAL UNINSTALL PROCESS
# ==============================================================================
uninstall_panel() {
    console "\n"
    print_header_line
    console "  ${RED}⚠️  DANGER: COMPLETE UNINSTALLATION${RESET}"
    console "  ${GRAY}├────────────────────────────────────────────────────────┤${RESET}"
    console "  ${RED}│${RESET} ${WHITE}This action will:${RESET}"
    console "  ${RED}│${RESET} ${YELLOW}• Remove PufferPanel completely${RESET}"
    console "  ${RED}│${RESET} ${YELLOW}• Delete ALL server data${RESET}"
    console "  ${RED}│${RESET} ${YELLOW}• Remove configurations${RESET}"
    console "  ${RED}│${RESET} ${YELLOW}• Clean up all related files${RESET}"
    console "  ${GRAY}├────────────────────────────────────────────────────────┤${RESET}"
    console ""
    
    console -ne "  ${RED}│${RESET} ${WHITE}Type ${RED}CONFIRM${WHITE} to proceed: ${RESET}"
    read -r confirmation >&3
    
    if [ "$confirmation" != "CONFIRM" ]; then
        console "\n  ${GREEN}✓ Uninstallation cancelled${RESET}"
        return
    fi
    
    console ""
    print_header_line
    console "  ${RED}🗑️  UNINSTALLATION IN PROGRESS${RESET}"
    print_footer_line
    
    log_audit "UNINSTALLATION STARTED"
    
    local total_steps=6
    local current_step=1
    
    show_progress $current_step $total_steps
    execute_task "U01" "Stopping Services" "systemctl stop pufferpanel && systemctl disable pufferpanel" "spinner"
    current_step=$((current_step + 1))
    
    show_progress $current_step $total_steps
    execute_task "U02" "Removing PufferPanel" "apt-get purge pufferpanel -y" "dots"
    current_step=$((current_step + 1))
    
    show_progress $current_step $total_steps
    execute_task "U03" "Cleaning Package Files" "apt-get autoremove -y && apt-get autoclean -y" "pulse"
    current_step=$((current_step + 1))
    
    show_progress $current_step $total_steps
    execute_task "U04" "Removing Data Directories" "rm -rf /var/lib/pufferpanel /etc/pufferpanel /usr/share/pufferpanel" "spinner"
    current_step=$((current_step + 1))
    
    show_progress $current_step $total_steps
    if command -v ufw > /dev/null; then
        execute_task "U05" "Closing Firewall Ports" "ufw delete allow 8080/tcp && ufw delete allow 5657/tcp && ufw reload" "dots"
    fi
    current_step=$((current_step + 1))
    
    show_progress $current_step $total_steps
    execute_task "U06" "Final Cleanup" "rm -f /etc/apt/sources.list.d/pufferpanel.list /etc/apt/trusted.gpg.d/pufferpanel.gpg" "pulse"
    
    console "\n"
    print_header_line
    console "  ${GREEN}✓ UNINSTALLATION COMPLETED${RESET}"
    console "  ${GRAY}├────────────────────────────────────────────────────────┤${RESET}"
    console "  ${GREEN}│${RESET} ${WHITE}All components have been removed successfully${RESET}"
    console "  ${GREEN}│${RESET} ${CYAN}Recommended:${RESET} Reboot your system to complete cleanup"
    print_footer_line
    
    log_audit "UNINSTALLATION COMPLETED"
}

# ==============================================================================
#  📊 SYSTEM STATUS CHECK
# ==============================================================================
system_status() {
    console "\n"
    print_header_line
    console "  ${CYAN}📊 SYSTEM STATUS CHECK${RESET}"
    console "  ${GRAY}├────────────────────────────────────────────────────────┤${RESET}"
    
    # Panel Status
    console -ne "  ${BLUE}│${RESET} ${WHITE}PufferPanel:${RESET} "
    if systemctl is-active --quiet pufferpanel; then
        console "${GREEN}● RUNNING${RESET}"
        local panel_version=$(pufferpanel version 2>/dev/null || echo "Unknown")
        console "  ${BLUE}│${RESET}   ${GRAY}Version:${RESET} ${CYAN}${panel_version}${RESET}"
    else
        console "${RED}○ STOPPED${RESET}"
    fi
    
    # Docker Status
    console -ne "  ${BLUE}│${RESET} ${WHITE}Docker Service:${RESET} "
    if systemctl is-active --quiet docker; then
        console "${GREEN}● RUNNING${RESET}"
        local docker_version=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        console "  ${BLUE}│${RESET}   ${GRAY}Version:${RESET} ${CYAN}${docker_version}${RESET}"
    else
        console "${RED}○ STOPPED${RESET}"
    fi
    
    # Port Status
    console "  ${BLUE}│${RESET} ${WHITE}Port Status:${RESET}"
    console -ne "  ${BLUE}│${RESET}   ${GRAY}Port 8080 (Panel):${RESET} "
    if ss -tuln | grep -q ':8080'; then
        console "${GREEN}● LISTENING${RESET}"
    else
        console "${RED}○ CLOSED${RESET}"
    fi
    
    console -ne "  ${BLUE}│${RESET}   ${GRAY}Port 5657 (SFTP):${RESET} "
    if ss -tuln | grep -q ':5657'; then
        console "${GREEN}● LISTENING${RESET}"
    else
        console "${RED}○ CLOSED${RESET}"
    fi
    
    # Resource Usage
    console "  ${BLUE}│${RESET} ${WHITE}Resource Usage:${RESET}"
    local mem_usage=$(free -m | awk '/^Mem:/{printf "%.1f%%", $3/$2*100}')
    local disk_usage=$(df -h / | awk 'NR==2{print $5}')
    local load=$(uptime | awk -F'load average:' '{print $2}')
    
    console "  ${BLUE}│${RESET}   ${GRAY}Memory:${RESET} ${CYAN}${mem_usage}${RESET}"
    console "  ${BLUE}│${RESET}   ${GRAY}Disk (/):${RESET} ${CYAN}${disk_usage}${RESET}"
    console "  ${BLUE}│${RESET}   ${GRAY}Load Avg:${RESET} ${CYAN}${load}${RESET}"
    
    print_footer_line
}

# ==============================================================================
#  🎮 PROFESSIONAL MAIN MENU
# ==============================================================================
main_menu() {
    while true; do
        show_banner
        check_requirements
        
        console ""
        print_header_line
        console "  ${WHITE}📋 MAIN MENU - Select an action${RESET}"
        console "  ${GRAY}├────────────────────────────────────────────────────────┤${RESET}"
        console "  ${CYAN}│${RESET} ${GREEN}[1] 🚀${RESET} ${BOLD}Install PufferPanel${RESET} ${GRAY}(Recommended)${RESET}"
        console "  ${CYAN}│${RESET} ${RED}[2] 🗑️${RESET} ${BOLD}Uninstall PufferPanel${RESET} ${GRAY}(Danger Zone)${RESET}"
        console "  ${CYAN}│${RESET} ${BLUE}[3] 📊${RESET} ${BOLD}System Status${RESET} ${GRAY}(Check Services)${RESET}"
        console "  ${CYAN}│${RESET} ${PURPLE}[4] 🛠️${RESET} ${BOLD}Restart Services${RESET} ${GRAY}(Panel & Docker)${RESET}"
        console "  ${CYAN}│${RESET} ${YELLOW}[5] 🚪${RESET} ${BOLD}Exit${RESET} ${GRAY}(Close Script)${RESET}"
        console "  ${GRAY}├────────────────────────────────────────────────────────┤${RESET}"
        console -ne "  ${CYAN}│${RESET} ${WHITE}👉 Your choice [1-5]: ${RESET}"
        
        read -r choice >&3
        
        case $choice in
            1)
                install_panel
                ;;
            2)
                uninstall_panel
                ;;
            3)
                system_status
                ;;
            4)
                console "\n"
                execute_task "RS1" "Restarting Services" "systemctl restart pufferpanel docker" "pulse"
                console "  ${GREEN}✓ Services restarted successfully${RESET}"
                ;;
            5)
                console "\n"
                print_header_line
                console "  ${CYAN}👋 Thank you for using KS Hosting!${RESET}"
                console "  ${GRAY}├────────────────────────────────────────────────────────┤${RESET}"
                console "  ${BLUE}│${RESET} ${WHITE}Need help?${RESET} Check our documentation or contact support"
                console "  ${BLUE}│${RESET} ${GRAY}Logs saved to:${RESET} ${CYAN}${LOG_FILE}${RESET}"
                print_footer_line
                console ""
                exit 0
                ;;
            *)
                console "\n  ${RED}✗ Invalid selection. Please choose 1-5${RESET}"
                ;;
        esac
        
        if [ "$choice" -ne 5 ]; then
            console "\n  ${WHITE}Press ${GREEN}[ENTER]${WHITE} to continue...${RESET}"
            read -r >&3
        fi
    done
}

# ==============================================================================
#  🚀 SCRIPT ENTRY POINT
# ==============================================================================

# Trap for cleanup on exit
trap 'console "\n${RED}Script interrupted. Cleaning up...${RESET}"; exit 1' INT TERM

# Start the application
main_menu

# Restore original descriptors
exec 1>&3
exec 2>&4
