#!/bin/bash

# --- COLORS ---
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
NC="\033[0m"

# --- ROOT CHECK ---
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ Error: This script must be run as root (use sudo).${NC}"
   exit 1
fi

# ================== INSTALL FUNCTION ==================
install_ptero() {
    clear
    echo -e "${CYAN}┌──────────────────────────────────────────────┐"
    echo "│         🚀 Pterodactyl Installation          │"
    echo -e "└──────────────────────────────────────────────┘${NC}"
    bash <(curl -s https://raw.githubusercontent.com/lie-kg/lie-kg-Hub/refs/heads/main/srv/panel/pterodactyl.sh)
    echo -e "${GREEN}✔ Installation Complete${NC}"
    read -p "Press Enter to return..."
}

# ================== CREATE USER ==================
create_user() {
    clear
    echo -e "${CYAN}┌──────────────────────────────────────────────┐"
    echo "│         👤 Create Pterodactyl User           │"
    echo -e "└──────────────────────────────────────────────┘${NC}"

    if [ ! -d /var/www/pterodactyl ]; then
        echo -e "${RED}❌ Panel not installed!${NC}"
        read -p "Press Enter to return..."
        return
    fi

    cd /var/www/pterodactyl || exit
    php artisan p:user:make
    read -p "Press Enter to return..."
}

# ================= PANEL UNINSTALL =================
uninstall_ptero() {
    clear
    echo -e "${RED}┌──────────────────────────────────────────────┐"
    echo "│         🧹 Pterodactyl Uninstallation        │"
    echo -e "└──────────────────────────────────────────────┘${NC}"
    
    read -p "Are you sure you want to delete the Panel? (y/N): " confirm
    if [[ $confirm != "y" && $confirm != "Y" ]]; then
        return
    fi

    echo ">>> Stopping Panel service..."
    systemctl stop pteroq.service 2>/dev/null || true
    systemctl disable pteroq.service 2>/dev/null || true
    rm -f /etc/systemd/system/pteroq.service
    systemctl daemon-reload

    echo ">>> Removing cronjob..."
    (crontab -l 2>/dev/null | grep -v 'pterodactyl/artisan schedule:run') | crontab - 2>/dev/null

    echo ">>> Removing files..."
    rm -rf /var/www/pterodactyl

    echo ">>> Dropping database..."
    mysql -u root -e "DROP DATABASE IF EXISTS panel; DROP USER IF EXISTS 'pterodactyl'@'127.0.0.1'; FLUSH PRIVILEGES;" 2>/dev/null

    echo ">>> Cleaning nginx..."
    rm -f /etc/nginx/sites-enabled/pterodactyl.conf
    rm -f /etc/nginx/sites-available/pterodactyl.conf
    nginx -t && systemctl reload nginx || true

    echo -e "${GREEN}✔ Panel Uninstalled (Wings untouched)${NC}"
    read -p "Press Enter to return..."
}

# ================= UPDATE FUNCTION =================
update_panel() {
    clear
    echo -e "${YELLOW}═══════════════════════════════════════════════"
    echo "        ⚡ PTERODACTYL PANEL UPDATE ⚡         "
    echo -e "═══════════════════════════════════════════════${NC}"

    if [ ! -d /var/www/pterodactyl ]; then
        echo -e "${RED}❌ Panel not found in /var/www/pterodactyl!${NC}"
        read -p "Press Enter to return..."
        return
    fi

    cd /var/www/pterodactyl || return

    echo -e "${CYAN}Entering Maintenance Mode...${NC}"
    php artisan down

    echo -e "${CYAN}Downloading latest files...${NC}"
    curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv
    
    chmod -R 755 storage/* bootstrap/cache
    
    echo -e "${CYAN}Updating dependencies...${NC}"
    export COMPOSER_ALLOW_SUPERUSER=1
    composer install --no-dev --optimize-autoloader

    php artisan view:clear
    php artisan config:clear
    php artisan migrate --seed --force
    
    chown -R www-data:www-data /var/www/pterodactyl/*
    
    echo -e "${CYAN}Restarting Queue...${NC}"
    php artisan queue:restart
    php artisan up

    echo -e "${GREEN}🎉 Panel Updated Successfully!${NC}"
    read -p "Press Enter to return..."
}

# ===================== MENU =====================
while true; do
    clear
    echo -e "${YELLOW}╔═══════════════════════════════════════════════╗"
    echo "║     🐲 PTERODACTYL CONTROL CENTER             ║"
    echo "╠═══════════════════════════════════════════════╣"
    echo -e "║ ${GREEN}1) Install Panel${NC}"
    echo -e "║ ${CYAN}2) Create Panel User${NC}"
    echo -e "║ ${YELLOW}3) Update Panel${NC}"
    echo -e "║ ${RED}4) Uninstall Panel${NC}"
    echo -e "║ 5) Exit"
    echo "╚═══════════════════════════════════════════════╝"
    echo -ne "${CYAN}Select Option → ${NC}"
    read choice

    case $choice in
        1) install_ptero ;;
        2) create_user ;;
        3) update_panel ;;
        4) uninstall_ptero ;;
        5) clear; exit ;;
        *) echo -e "${RED}Invalid option...${NC}"; sleep 1 ;;
    esac
done
