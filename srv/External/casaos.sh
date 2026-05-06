#!/bin/bash

# ===================== COLORS =====================
RED="\e[31m"; GREEN="\e[32m"; C_MAIN="\e[36m"; C_SEC="\e[32m"; C_LINE="\e[90m"; NC="\e[0m"

# ===================== HELPERS =====================
pause() { read -rp "Press Enter to continue..." ; }

# Detect local IP address
get_ip() {
  hostname -I | awk '{print $1}'
}

# ===================== CASAOS MENU =====================
casaos_menu() {
  # Root check
  if [[ $EUID -ne 0 ]]; then 
     echo -e "${RED}Error: This script must be run as root (use sudo).${NC}"
     exit 1
  fi

  while true; do
    clear
    echo -e "${C_LINE}────────────── CASAOS MENU ──────────────${NC}"
    echo -e "${C_MAIN} 1) Install CasaOS"
    echo -e " 2) Uninstall CasaOS"
    echo -e " 3) Exit${NC}"
    echo -e "${C_LINE}────────────────────────────────────────${NC}"
    read -rp "Select → " cs

    case "$cs" in
      1)
        clear
        echo -e "${C_MAIN}🚀 Installing CasaOS...${NC}"
        # Ensure curl is installed first
        apt-get update && apt-get install -y curl
        curl -fsSL https://get.casaos.io | bash
        echo -e "\n${C_SEC}✅ CasaOS Installed Successfully${NC}"
        echo -e "${C_SEC}🌐 Access: http://$(get_ip)${NC}"
        pause
        ;;
      2)
        clear
        echo -e "${RED}🧹 Uninstalling CasaOS...${NC}"

        if command -v casaos-uninstall >/dev/null 2>&1; then
          casaos-uninstall
        fi

        systemctl stop casaos.service 2>/dev/null || true
        systemctl disable casaos.service 2>/dev/null || true

        # Clean up directories
        rm -rf /casaos /usr/lib/casaos /etc/casaos /var/lib/casaos /usr/bin/casaos /usr/local/bin/casaos

        echo -e "\n${C_SEC}✅ CasaOS Completely Removed${NC}"
        pause
        ;;
      3)
        clear; exit 0 ;;
      *)
        echo -e "${RED}Invalid Option${NC}"
        sleep 1 ;;
    esac
  done
}

# ===================== START =====================
casaos_menu
