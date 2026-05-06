#!/bin/bash
# ===========================================================
# CODING HUB - All-in-One Terminal Control Panel
# Version: 3.0 (Fixed & Consolidated)
# Mode By - Nobita & lie_kg
# ===========================================================

# --- COLORS ---
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
WHITE='\033[1;37m'
NC='\033[0m'

# --- HELPERS ---
pause(){ 
    echo -e "${CYAN}"
    read -p "Press Enter to continue..." x
    echo -e "${NC}" 
}

print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Reset colors and exit on Ctrl+C
trap 'echo -e "${NC}"; exit' INT

# ===================== BANNER =====================
banner(){
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW} ██╗     ██╗███████╗    ██╗  ██╗ ██████╗      ██████╗██╗      ██████╗ ██╗   ██╗██████╗  ${NC}"
    echo -e "${YELLOW} ██║     ██║██╔════╝    ██║ ██╔╝██╔════╝     ██╔════╝██║      ██╔═══██╗██║   ██║██╔══██╗ ${NC}"
    echo -e "${YELLOW} ██║     ██║█████╗      █████╔╝ ██║  ███╗    ██║     ██║      ██║   ██║██║   ██║██║  ██║ ${NC}"
    echo -e "${YELLOW} ██║     ██║██╔══╝      ██╔═██╗ ██║  ██║    ██║     ██║      ██║   ██║██║   ██║██║  ██║ ${NC}"
    echo -e "${YELLOW} ███████╗██║███████╗    ██║  ██╗╚██████╔╝    ╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝ ${NC}"
    echo -e "${YELLOW} ╚══════╝╚═╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝      ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝  ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "                      ${WHITE}Mode By - lie_kg & Nobita${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
}

# ===================== PANEL MENU =====================
panel_menu(){
    while true; do 
        banner
        echo -e "${GREEN}────────────── PANEL MENU ──────────────${NC}"
        echo -e "${YELLOW} 1)${WHITE} FeatherPanel"
        echo -e "${YELLOW} 2)${WHITE} Pterodactyl"
        echo -e "${YELLOW} 3)${WHITE} Jexactyl v3"
        echo -e "${YELLOW} 4)${WHITE} Jexpanel v4"
        echo -e "${YELLOW} 5)${WHITE} Dashboard v3"
        echo -e "${YELLOW} 6)${WHITE} Dashboard v4"
        echo -e "${YELLOW} 7)${WHITE} Payment Gateway"
        echo -e "${YELLOW} 8)${WHITE} CtrlPanel"
        echo -e "${YELLOW} 9)${WHITE} CPanel"
        echo -e "${YELLOW} 10)${WHITE} Back"
        echo -e "${GREEN}─────────────────────────────────────────${NC}"
        read -p "Select → " p

        case $p in
            1) curl -sSL https://get.featherpanel.com/beta.sh | bash ;;
            2) bash <(curl -s https://raw.githubusercontent.com/nobita54/-150/refs/heads/main/Uninstall/unPterodactyl.sh) ;;
            3) bash <(curl -s https://raw.githubusercontent.com/nobita54/-150/refs/heads/main/panel/Jexactyl.sh) ;;
            4) bash <(curl -s https://raw.githubusercontent.com/nobita54/-150/refs/heads/main/Uninstall/unJexactyl.sh) ;;
            5) bash <(curl -s https://raw.githubusercontent.com/nobita54/-150/refs/heads/main/Uninstall/unMythicalDash.sh) ;;
            6) bash <(curl -s https://raw.githubusercontent.com/nobita54/-150/refs/heads/main/Uninstall/dash-v4) ;;
            7) bash <(curl -s https://raw.githubusercontent.com/nobita54/-150/refs/heads/main/Uninstall/unPaymenter.sh) ;;
            8) bash <(curl -s https://raw.githubusercontent.com/nobita54/-150/refs/heads/main/Uninstall/unCtrlPanel.sh) ;;
            9) bash <(curl -s https://raw.githubusercontent.com/yourlink/cpanel.sh) ;;
            10) break ;;
            *) echo -e "${RED}Invalid Option${NC}"; sleep 1 ;;
        esac
    done
}

# ===================== TOOLS MENU =====================
tools_menu(){
    while true; do 
        banner
        echo -e "${BLUE}────────────── TOOLS MENU ──────────────${NC}"
        echo -e "${YELLOW} 1)${WHITE} Root Access Enabler"
        echo -e "${YELLOW} 2)${WHITE} Tailscale VPN"
        echo -e "${YELLOW} 3)${WHITE} Cloudflare DNS"
        echo -e "${YELLOW} 4)${WHITE} System Info"
        echo -e "${YELLOW} 5)${WHITE} VPS Benchmark (Run)"
        echo -e "${YELLOW} 6)${WHITE} Port Forwarding"
        echo -e "${YELLOW} 7)${WHITE} RDP Installer"
        echo -e "${YELLOW} 8)${WHITE} Back"
        echo -e "${BLUE}────────────────────────────────────────${NC}"
        read -p "Select → " t

        case $t in
            1) bash <(curl -s https://raw.githubusercontent.com/nobita54/-150/refs/heads/main/tools/root.sh) ;;
            2) bash <(curl -s https://raw.githubusercontent.com/nobita54/-150/refs/heads/main/tools/Tailscale.sh) ;;
            3) bash <(curl -s https://raw.githubusercontent.com/nobita54/-150/refs/heads/main/tools/cf.sh) ;;
            4) bash <(curl -s https://raw.githubusercontent.com/nobita54/-150/refs/heads/main/tools/SYSTEM.sh) ;;
            5) bash <(curl -s https://raw.githubusercontent.com/nobita54/-150/refs/heads/main/tools/vps.sh) ;;
            6) bash <(curl -s https://raw.githubusercontent.com/yourlink/portforward.sh) ;;
            7) bash <(curl -s https://raw.githubusercontent.com/yourlink/rdp.sh) ;;
            8) break ;;
            *) echo -e "${RED}Invalid Option${NC}"; sleep 1 ;;
        esac
    done
}

# ===================== LXC MANAGEMENT =====================
# (Integration of your first script's logic)
lxc_menu() {
    while true; do
        banner
        echo -e "${PURPLE}────────────── LXC MANAGER ─────────────${NC}"
        echo -e "${YELLOW} 1)${WHITE} List Containers"
        echo -e "${YELLOW} 2)${WHITE} Create New Container"
        echo -e "${YELLOW} 3)${WHITE} Check LXD Installation"
        echo -e "${YELLOW} 4)${WHITE} Install LXD Dependencies"
        echo -e "${YELLOW} 5)${WHITE} Back"
        echo -e "${PURPLE}────────────────────────────────────────${NC}"
        read -p "Select → " lx

        case $lx in
            1) lxc list; pause ;;
            2) # This calls your launch logic
               read -p "Container Name: " cname
               read -p "Image (e.g., ubuntu:22.04): " cimg
               lxc launch "$cimg" "$cname" && print_color "$GREEN" "Success!" || print_color "$RED" "Failed!"
               pause ;;
            3) lxc version || echo "LXD not found"; pause ;;
            4) # Simplified install
               sudo apt update && sudo apt install -y snapd
               sudo snap install lxd
               sudo lxd init --auto
               pause ;;
            5) break ;;
            *) echo -e "${RED}Invalid${NC}"; sleep 1 ;;
        esac
    done
}

# ===================== MAIN MENU =====================
main_menu(){
    while true; do 
        banner
        echo -e "${CYAN}────────────── MAIN MENU ──────────────${NC}"
        echo -e "${YELLOW} 1)${WHITE} VPS Benchmark"
        echo -e "${YELLOW} 2)${WHITE} Panel Management"
        echo -e "${YELLOW} 3)${WHITE} Wings (Uninstall/Manage)"
        echo -e "${YELLOW} 4)${WHITE} LXC/LXD Manager"
        echo -e "${YELLOW} 5)${WHITE} Extra Tools"
        echo -e "${YELLOW} 6)${WHITE} Exit"
        echo -e "${CYAN}────────────────────────────────────────${NC}"
        read -p "Select → " c

        case $c in
            1) bash <(curl -s https://raw.githubusercontent.com/nobita54/-150/refs/heads/main/tools/vps.sh) ;;
            2) panel_menu ;;
            3) bash <(curl -s https://raw.githubusercontent.com/nobita54/-150/refs/heads/main/Uninstall/unwings.sh) ;;
            4) lxc_menu ;;
            5) tools_menu ;;
            6) echo -e "${GREEN}Exiting CODING HUB. Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid Selection${NC}"; sleep 1 ;;
        esac
    done
}

# Start script
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Please run as root!${NC}"
   exit 1
fi

main_menu
