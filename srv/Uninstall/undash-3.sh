#!/bin/bash

# --- COLORS & STYLES ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
MAGENTA='\033[1;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# --- ROOT CHECK ---
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ Error: This script must be run as root (use sudo).${NC}"
   exit 1
fi

show_header() {
    clear
    echo -e "${MAGENTA}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC}${CYAN}    __  __       _   _               _     _____   ${NC}${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}${CYAN}   |  \/  |     | | | |             | |   |  __ \  ${NC}${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}${CYAN}   | \  / |_   _| |_| |__   ___   __| |___| |  | | ${NC}${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}${CYAN}   | |\/| | | | | __| '_ \ / _ \ / _\` / __| |  | | ${NC}${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}${CYAN}   | |  | | |_| | |_| | | | (_) | (_| \__ \ |__| | ${NC}${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}${CYAN}   |_|  |_|\__,_|\__|_| |_|\___/ \__,_|___/_____/  ${NC}${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╠══════════════════════════════════════════════════╣${NC}"
    echo -e "${MAGENTA}║${NC}${BOLD}            D A S H B O A R D   M A N A G E R        ${NC}${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
}

while true; do
    show_header
    
    echo -e "${PURPLE}┌────────────────────────────────────────────────┐${NC}"
    echo -e "${PURPLE}│${NC} ${GREEN}🚀${NC} ${BOLD}1.${NC} Install                 ${PURPLE}│${NC}"
    echo -e "${PURPLE}│${NC} ${YELLOW}🔄${NC} ${BOLD}2.${NC} Update                  ${PURPLE}│${NC}"
    echo -e "${PURPLE}│${NC} ${RED}🗑️${NC} ${BOLD}3.${NC} Uninstall                ${PURPLE}│${NC}"
    echo -e "${PURPLE}│${NC} ${BLUE}🚪${NC} ${BOLD}4.${NC} Exit                                  ${PURPLE}│${NC}"
    echo -e "${PURPLE}├────────────────────────────────────────────────┤${NC}"
    echo -e "${PURPLE}│${NC} ${CYAN}📊${NC} Version: 3.2.3 | By: MythicalLTD            ${PURPLE}│${NC}"
    echo -e "${PURPLE}└────────────────────────────────────────────────┘${NC}"
    echo ""
    
    read -p "$(echo -e "${YELLOW}🎯 Select option [1-4]:${NC} ")" option

    case $option in
        1)
            echo -e "\n${GREEN}══════════════════════════════════════════════════${NC}"
            echo -e "${GREEN}            🚀 INSTALLATION STARTING                ${NC}"
            echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
            bash <(curl -s https://raw.githubusercontent.com/lie-kg/lie-kg-Hub/refs/heads/main/srv/panel/Dashboard-v3.sh)
            ;;
            
        2)
            echo -e "\n${YELLOW}══════════════════════════════════════════════════${NC}"
            echo -e "${YELLOW}            🔄 UPDATE IN PROGRESS                   ${NC}"
            echo -e "${YELLOW}══════════════════════════════════════════════════${NC}"
            
            if [ ! -d "/var/www/mythicaldash" ]; then
                echo -e "${RED}❌ MythicalDash directory not found!${NC}"
                read -p "Press Enter to continue..."
                continue
            fi
            
            cd /var/www/mythicaldash || exit
            
            echo -e "${BLUE}[1/6]${NC} ${CYAN}Downloading latest version...${NC}"
            curl -Lo MythicalDash.zip https://github.com/MythicalLTD/MythicalDash/releases/download/3.2.3/MythicalDash.zip
            
            echo -e "${BLUE}[2/6]${NC} ${CYAN}Extracting files...${NC}"
            unzip -o MythicalDash.zip -d /var/www/mythicaldash
            
            echo -e "${BLUE}[3/6]${NC} ${CYAN}Converting file formats...${NC}"
            dos2unix arch.bash 2>/dev/null || echo "dos2unix not installed, skipping..."
            
            echo -e "${BLUE}[4/6]${NC} ${CYAN}Running maintenance commands...${NC}"
            sudo bash arch.bash
            
            echo -e "${BLUE}[5/6]${NC} ${CYAN}Installing dependencies...${NC}"
            export COMPOSER_ALLOW_SUPERUSER=1
            composer install --no-dev --optimize-autoloader
            
            echo -e "${BLUE}[6/6]${NC} ${CYAN}Running migrations...${NC}"
            chmod +x MythicalDash
            ./MythicalDash -migrate
            
            chown -R www-data:www-data /var/www/mythicaldash/*
            
            echo -e "\n${GREEN}✅ UPDATE COMPLETED SUCCESSFULLY!${NC}"
            ;;
            
        3)
            echo -e "\n${RED}══════════════════════════════════════════════════${NC}"
            echo -e "${RED}            ⚠️  UNINSTALL WARNING!                  ${NC}"
            echo -e "${RED}══════════════════════════════════════════════════${NC}"
            read -p "$(echo -e "${RED}Are you absolutely sure? (y/N):${NC} ")" confirm
            
            if [[ $confirm == "y" || $confirm == "Y" ]]; then
                echo -e "\n${RED}🗑️  Removing MythicalDash...${NC}"
                
                # Database Removal
                mariadb -u root -e "DROP DATABASE IF EXISTS mythicaldash; DROP USER IF EXISTS 'mythicaldash'@'127.0.0.1'; FLUSH PRIVILEGES;" 2>/dev/null
                
                rm -rf /var/www/mythicaldash
                (crontab -l 2>/dev/null | grep -v 'mythicaldash/crons/server.php') | crontab - 2>/dev/null
                
                rm -f /etc/nginx/sites-available/MythicalDash.conf /etc/nginx/sites-enabled/MythicalDash.conf
                
                nginx -t && systemctl restart nginx
                echo -e "\n${GREEN}✅ UNINSTALL COMPLETE!${NC}"
            else
                echo -e "${YELLOW}❌ Uninstall cancelled.${NC}"
            fi
            ;;
            
        4)
            echo -e "\n${BLUE}👋 Farewell! Exiting gracefully...${NC}"
            exit 0
            ;;
            
        *)
            echo -e "\n${RED}❌ INVALID SELECTION!${NC}"
            sleep 1
            ;;
    esac

    echo ""
    read -p "$(echo -e "${CYAN}Press ${BOLD}Enter${NC}${CYAN} to return to menu...${NC}")" dummy
done
