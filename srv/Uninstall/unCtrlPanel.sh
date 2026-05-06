#!/bin/bash

# --- COLORS & STYLES ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Check for root/sudo
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ This script must be run as root (use sudo).${NC}"
   exit 1
fi

while true; do
    clear
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}${PURPLE}          ░█▀▀░█▀█░█▀▄░█▀▀░█░░         ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}${PURPLE}          ░█▀▀░█▀█░█▀▄░█▀▀░█░░         ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}${PURPLE}          ░▀░░░▀░▀░▀░▀░▀▀▀░▀▀▀         ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}${YELLOW}            C T R L  P A N E L          ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} ${GREEN}›${NC} ${BOLD}1)${NC} Install            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC} ${RED}›${NC} ${BOLD}2)${NC} Uninstall          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC} ${YELLOW}›${NC} ${BOLD}3)${NC} Update             ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC} ${BLUE}›${NC} ${BOLD}4)${NC} Exit               ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo ""
    read -p "$(echo -e "${YELLOW}👉 Select an option [1-4]:${NC} ")" option

    case $option in
        1)
            echo -e "\n${GREEN}🚀 Installing CTRL Panel...${NC}"
            echo -e "${CYAN}Please wait while we set up everything...${NC}\n"
            bash <(curl -s https://raw.githubusercontent.com/nobita54/-150/refs/heads/main/panel/CtrlPanel.sh)
            ;;
        2)
            echo -e "\n${RED}⚠️  WARNING: This will remove CTRL Panel completely!${NC}"
            read -p "Are you sure? (y/N): " confirm
            if [[ $confirm == "y" || $confirm == "Y" ]]; then
                echo -e "${RED}🗑️  Uninstalling CTRL Panel...${NC}"
                
                # Stop services
                sudo systemctl stop ctrlpanel 2>/dev/null
                sudo systemctl disable ctrlpanel 2>/dev/null
                sudo rm -f /etc/systemd/system/ctrlpanel.service 2>/dev/null
                
                # Clean Crontab
                (sudo crontab -l 2>/dev/null | grep -v 'ctrlpanel/artisan schedule:run') | sudo crontab - 2>/dev/null

                # Database Removal (Prompts for password once)
                echo -e "${RED}🗃️  Removing database...${NC}"
                mysql -u root -p -e "DROP DATABASE IF EXISTS ctrlpanel; DROP USER IF EXISTS 'ctrlpaneluser'@'127.0.0.1'; FLUSH PRIVILEGES;"

                # Nginx Cleanup
                sudo rm -f /etc/nginx/sites-enabled/ctrlpanel.conf 2>/dev/null
                sudo rm -f /etc/nginx/sites-available/ctrlpanel.conf 2>/dev/null
                sudo systemctl reload nginx 2>/dev/null

                # File Removal
                sudo rm -rf /var/www/ctrlpanel 2>/dev/null

                echo -e "${GREEN}✅ Uninstall complete! All files removed.${NC}"
            else
                echo -e "${YELLOW}❌ Uninstall cancelled.${NC}"
            fi
            ;;
        3)
            if [ ! -d "/var/www/ctrlpanel" ]; then
                echo -e "${RED}❌ CTRL Panel directory not found!${NC}"
                sleep 2
                continue
            fi
            
            echo -e "\n${YELLOW}🔄 Updating CTRL Panel...${NC}"
            cd /var/www/ctrlpanel || exit
            
            sudo php artisan down
            git stash
            git pull
            
            # Reset permissions for update
            sudo chown -R www-data:www-data /var/www/ctrlpanel
            
            # Composer Update
            COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader

            # Database & Optimization
            php artisan migrate --seed --force
            php artisan view:clear
            php artisan config:clear
            php artisan queue:restart
            sudo php artisan up

            echo -e "${GREEN}✅ Update complete! Panel is now up to date.${NC}"
            ;;
        4)
            echo -e "\n${BLUE}👋 Exiting... Have a great day!${NC}\n"
            exit 0
            ;;
        *)
            echo -e "\n${RED}❌ Invalid option!${NC}"
            sleep 1
            ;;
    esac

    echo ""
    read -p "$(echo -e "${CYAN}Press ${BOLD}Enter${NC}${CYAN} to return to menu...${NC}")" dummy
done
