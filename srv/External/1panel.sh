#!/bin/bash

# ===================== COLORS =====================
RED="\e[31m"
C_MAIN="\e[36m"
C_SEC="\e[32m"
C_LINE="\e[90m"
NC="\e[0m"

# ===================== HELPERS =====================
pause() {
  read -rp "Press Enter to continue..."
}

get_ip() {
  hostname -I | awk '{print $1}'
}

# ===================== COCKPIT MENU =====================
cockpit_menu() {
  while true; do
    clear
    echo -e "${C_LINE}────────────── COCKPIT MENU ──────────────${NC}"
    echo -e "${C_MAIN} 1) Install Cockpit"
    echo -e " 2) Uninstall Cockpit"
    echo -e " 3) Exit${NC}"
    echo -e "${C_LINE}──────────────────────────────────────────${NC}"
    read -rp "Select → " op

    case "$op" in
      1)
        clear
        echo -e "${C_MAIN}🚀 Installing Cockpit Web Console...${NC}"
        sudo apt update
        sudo apt install -y cockpit
        sudo systemctl enable --now cockpit.socket
        
        echo -e "\n${C_SEC}✅ Cockpit Installed Successfully${NC}"
        echo -e "${C_SEC}🌐 Access: https://$(get_ip):9090${NC}"
        echo -e "${C_SEC}💡 Use your system root/user credentials to login.${NC}"
        pause
        ;;
      2)
        clear
        echo -e "${C_MAIN}🧹 Removing Cockpit...${NC}"
        sudo systemctl stop cockpit.socket 2>/dev/null
        sudo apt purge -y cockpit cockpit-* 
        sudo apt autoremove -y
        
        echo -e "\n${C_SEC}✅ Cockpit Completely Removed${NC}"
        pause
        ;;
      3)
        exit 0
        ;;
      *)
        echo -e "${RED}Invalid Option${NC}"
        sleep 1
        ;;
    esac
  done
}

# ===================== START =====================
cockpit_menu
