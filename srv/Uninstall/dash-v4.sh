#!/bin/bash

# --- COLORS ---
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}🔰 MythicalDash v3 Manager${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${WHITE}1) 🚀 Install MythicalDash v4 (Latest)${NC}"
echo -e "${WHITE}2) 🗑️  Uninstall MythicalDash v3${NC}"
echo ""
read -p "👉 Choose option [1-2]: " ACTION

case $ACTION in
    1)
        echo -e "\n${YELLOW}😌 Starting Installation...${NC}"
        # Triggering the remote installer
        if bash <(curl -s https://raw.githubusercontent.com/lie-kg/lie-kg-Hub/refs/heads/main/srv/panel/Dashboard-v4.sh); then
            echo -e "${GREEN}✅ Installation process completed!${NC}"
        else
            echo -e "${RED}❌ Installation failed. Please check your network.${NC}"
        fi
        exit 0
        ;;

    2)
        echo -e "\n${RED}🧹 Uninstalling MythicalDash v3...${NC}"
        sleep 1

        # 1. REMOVE PANEL FILES
        echo "Removing web files..."
        rm -rf /var/www/mythicaldash-v3

        # 2. REMOVE NGINX CONFIG
        echo "Cleaning Nginx configurations..."
        rm -f /etc/nginx/sites-enabled/MythicalDashRemastered.conf
        rm -f /etc/nginx/sites-available/MythicalDashRemastered.conf
        systemctl reload nginx 2>/dev/null

        # 3. REMOVE SSL CERTS
        rm -rf /etc/certs/MythicalDash-4

        # 4. REMOVE CRON JOBS
        echo "Cleaning Crontab..."
        crontab -l 2>/dev/null | grep -v "mythicaldash-v3" | crontab -

        # 5. DROP DATABASE & USER
        echo "Dropping Database..."
        mariadb -e "DROP DATABASE IF EXISTS mythicaldash_remastered;"
        mariadb -e "DROP USER IF EXISTS 'mythicaldash_remastered'@'127.0.0.1';"
        mariadb -e "FLUSH PRIVILEGES;"

        echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ MythicalDash fully removed.${NC}"
        echo -e "${YELLOW}Perfectly balanced, as all scripts should be ⚖️${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        exit 0
        ;;

    *)
        echo -e "${RED}❌ Invalid option selected. Exiting.${NC}"
        exit 1
        ;;
esac
