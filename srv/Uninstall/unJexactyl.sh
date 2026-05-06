#!/bin/bash

# --- COLORS & STYLES ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' 
BOLD='\033[1m'

# Check for root/sudo
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ Error: This script must be run as root (use sudo).${NC}"
   exit 1
fi

# ASCII Art for Jexactyl
show_header() {
    clear
    echo -e "${PURPLE}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}${CYAN}       ██╗███████╗██╗  ██╗ █████╗  ██████╗ ████████╗██╗   ██╗${NC}${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}${CYAN}       ██║██╔════╝╚██╗██╔╝██╔══██╗██╔════╝ ╚══██╔══╝╚██╗ ██╔╝${NC}${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}${CYAN}       ██║█████╗   ╚███╔╝ ███████║██║  ███╗   ██║    ╚████╔╝ ${NC}${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}${CYAN}  ██  ██║██╔══╝   ██╔██╗ ██╔══██║██║   ██║   ██║     ╚██╔╝  ${NC}${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}${CYAN}  ╚█████╔╝███████╗██╔╝ ██╗██║  ██║╚██████╔╝   ██║      ██║   ${NC}${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}${CYAN}   ╚════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝    ╚═╝      ╚═╝   ${NC}${PURPLE}║${NC}"
    echo -e "${PURPLE}╠══════════════════════════════════════════════╣${NC}"
    echo -e "${PURPLE}║${NC}${BOLD}             J E X A C T Y L  P A N E L            ${NC}${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════╝${NC}"
    echo ""
}

while true; do
    show_header
    
    # Menu Options
    echo -e "${CYAN}┌────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}📦${NC} ${BOLD}1.${NC} Install       ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${RED}🗑️${NC} ${BOLD}2.${NC} Uninstall      ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}🔄${NC} ${BOLD}3.${NC} Update          ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${BLUE}🚪${NC} ${BOLD}4.${NC} Exit Menu                       ${CYAN}│${NC}"
    echo -e "${CYAN}├────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${PURPLE}💡${NC} Need help? Check docs: jexactyl.com      ${CYAN}│${NC}"
    echo -e "${CYAN}└────────────────────────────────────────────┘${NC}"
    echo ""
    
    read -p "$(echo -e "${YELLOW}🎯 Select option [1-4]:${NC} ")" choice

    case "$choice" in
        1)
            echo -e "\n${GREEN}🚀 Starting Installation...${NC}"
            bash <(curl -s https://raw.githubusercontent.com/lie-kg/lie-kg-Hub/refs/heads/main/srv/panel/Jexpanel.sh)
            echo -e "\n${GREEN}✅ Installation process completed!${NC}"
            ;;
            
        2)
            echo -e "\n${RED}⚠️  UNINSTALL WARNING!${NC}"
            read -p "$(echo -e "${RED}Are you sure? This deletes ALL data. (y/N):${NC} ")" confirm
            
            if [[ $confirm == "y" || $confirm == "Y" ]]; then
                echo -e "\n${RED}🗑️  Uninstalling...${NC}"
                
                # Services
                systemctl stop jxctl.service 2>/dev/null
                systemctl disable jxctl.service 2>/dev/null
                rm -f /etc/systemd/system/jxctl.service 2>/dev/null
                systemctl daemon-reload
                
                # Nginx
                rm -f /etc/nginx/sites-enabled/jexactyl.conf 2>/dev/null
                rm -f /etc/nginx/sites-available/jexactyl.conf 2>/dev/null
                nginx -t && systemctl reload nginx 2>/dev/null
                
                # Database (Prompts for password safely)
                echo -e "${YELLOW}Removing database...${NC}"
                mysql -u root -p -e "DROP DATABASE IF EXISTS jexactyldb; DROP USER IF EXISTS 'jexactyluser'@'127.0.0.1'; FLUSH PRIVILEGES;"
                
                # Cleanup
                (crontab -l 2>/dev/null | grep -v 'jexactyl/artisan schedule:run') | crontab - 2>/dev/null
                rm -rf /var/www/jexactyl 2>/dev/null
                
                echo -e "${GREEN}✅ Uninstall complete! System is clean.${NC}"
            else
                echo -e "${YELLOW}❌ Uninstall cancelled.${NC}"
            fi
            ;;
            
        3)
            if [ ! -d "/var/www/jexactyl" ]; then
                echo -e "${RED}❌ Jexactyl not found in /var/www/jexactyl!${NC}"
                sleep 2; continue
            fi
            
            echo -e "\n${YELLOW}🔄 Starting Update...${NC}"
            cd /var/www/jexactyl || exit
            
            php artisan down
            curl -Lo panel.tar.gz https://github.com/jexactyl/jexactyl/releases/download/v4.0.0-rc2/panel.tar.gz
            tar -xzvf panel.tar.gz
            
            chmod -R 755 storage/* bootstrap/cache/
            export COMPOSER_ALLOW_SUPERUSER=1
            composer install --no-dev --optimize-autoloader
            
            php artisan optimize:clear
            php artisan migrate --seed --force
            chown -R www-data:www-data /var/www/jexactyl/
            php artisan up
            
            echo -e "${GREEN}✅ Update to v4.0.0-rc2 complete!${NC}"
            ;;
            
        4)
            echo -e "\n${BLUE}👋 Goodbye! Server console signing off... 🌙${NC}\n"
            exit 0
            ;;
            
        *)
            echo -e "\n${RED}❌ Invalid Option!${NC}"
            sleep 1
            ;;
    esac

    echo ""
    read -p "$(echo -e "${CYAN}Press ${BOLD}Enter${NC}${CYAN} to return to menu...${NC}")" dummy
done
