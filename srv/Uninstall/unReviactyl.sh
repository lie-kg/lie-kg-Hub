#!/bin/bash
# ====================================================
#      REVIACTYL INSTALL / USER / UPDATE / REMOVE
# ====================================================

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
    echo "│         🚀 Reviactyl Installation            │"
    echo -e "└──────────────────────────────────────────────┘${NC}"
    bash <(curl -s https://raw.githubusercontent.com/lie-kg/lie-kg-Hub/refs/heads/main/srv/panel/tool/reviactyl.sh)
    echo -e "${GREEN}✔ Installation Complete${NC}"
    read -p "Press Enter to return..."
}

# ================== CREATE USER ==================
create_user() {
    clear
    echo -e "${CYAN}┌──────────────────────────────────────────────┐"
    echo "│         👤 Create Reviactyl User             │"
    echo -e "└──────────────────────────────────────────────┘${NC}"

    if [ ! -d /var/www/reviactyl ]; then
        echo -e "${RED}❌ Panel not installed in /var/www/reviactyl!${NC}"
        read -p "Press Enter to return..."
        return
    fi

    cd /var/www/reviactyl || exit
    php artisan p:user:make
    read -p "Press Enter to return..."
}

# ================= PANEL UNINSTALL =================
uninstall_ptero() {
    clear
    echo -e "${RED}┌──────────────────────────────────────────────┐"
    echo "│         🧹 Reviactyl Uninstallation         │"
    echo -e "└──────────────────────────────────────────────┘${NC}"
    
    read -p "Are you sure you want to completely remove the panel? (y/N): " confirm
    [[ "$confirm" != "y" && "$confirm" != "Y" ]] && return

    echo ">>> Stopping Panel service..."
    systemctl stop reviq.service 2>/dev/null || true
    systemctl disable reviq.service 2>/dev/null || true
    rm -f /etc/systemd/system/reviq.service
    systemctl daemon-reload

    echo ">>> Removing cronjob..."
    (crontab -l 2>/dev/null | grep -v 'reviactyl/artisan schedule:run') | crontab - 2>/dev/null

    echo ">>> Removing files..."
    rm -rf /var/www/reviactyl

    echo ">>> Dropping database..."
    mysql -u root -e "DROP DATABASE IF EXISTS reviactyl; DROP USER IF EXISTS 'reviactyl'@'127.0.0.1'; FLUSH PRIVILEGES;" 2>/dev/null

    echo ">>> Cleaning Nginx..."
    rm -f /etc/nginx/sites-enabled/reviactyl.conf /etc/nginx/sites-available/reviactyl.conf
    nginx -t && systemctl reload nginx || true

    echo -e "${GREEN}✔ Panel removed.${NC}"
    read -p "Press Enter to return..."
}

# ================= RESET/UPGRADE FUNCTION =================
reset_panel() {
    clear
    echo -e "${YELLOW}═══════════════════════════════════════════════"
    echo "        ⚡ REVIACTYL PANEL RESET/UPGRADE ⚡"
    echo -e "═══════════════════════════════════════════════${NC}"

    if [ ! -d /var/www/reviactyl ]; then
        echo -e "${RED}❌ Panel not found!${NC}"
        read; return
    fi

    cd /var/www/reviactyl
    php artisan down
    php artisan p:upgrade
    php artisan up
    echo -e "${GREEN}🎉 Reset/Upgrade command executed.${NC}"
    read -p "Press Enter to return..."
}

# ================= MIGRATING FROM PTERO =================
Migrating() {
    clear
    echo -e "${YELLOW}═══════════════════════════════════════════════"
    echo "        ⚡ Migrating Pterodactyl -> Reviactyl ⚡"
    echo -e "═══════════════════════════════════════════════${NC}"

    if [ ! -d /var/www/pterodactyl ]; then
        echo -e "${RED}❌ Pterodactyl directory not found!${NC}"
        read; return
    fi

    cd /var/www/pterodactyl
    php artisan down
    
    echo "Cleaning old files..."
    rm -rf * 2>/dev/null || true
    
    echo "Downloading Reviactyl..."
    curl -Lo panel.tar.gz https://github.com/reviactyl/panel/releases/latest/download/panel.tar.gz
    tar -xzvf panel.tar.gz
    
    chmod -R 755 storage/* bootstrap/cache/
    export COMPOSER_ALLOW_SUPERUSER=1
    composer install --no-dev --optimize-autoloader
    
    php artisan migrate --seed --force
    chown -R www-data:www-data /var/www/pterodactyl/*
    
    # Enable service (Checks for both possible names)
    systemctl enable --now pteroq.service 2>/dev/null || systemctl enable --now reviq.service 2>/dev/null
    
    php artisan up
    echo -e "${GREEN}🎉 Migration Complete! Note: Files are still in /var/www/pterodactyl${NC}"
    read -p "Press Enter to return..."
}

# ================= STANDARD UPDATE =================
update() {
    clear
    echo -e "${YELLOW}═══════════════════════════════════════════════"
    echo "        ⚡ REVIACTYL STANDARD UPDATE ⚡"
    echo -e "═══════════════════════════════════════════════${NC}"

    if [ ! -d /var/www/reviactyl ]; then
        echo -e "${RED}❌ Reviactyl directory not found!${NC}"
        read; return
    fi

    cd /var/www/reviactyl
    php artisan down
    curl -Lo panel.tar.gz https://github.com/reviactyl/panel/releases/latest/download/panel.tar.gz
    tar -xzvf panel.tar.gz
    
    chmod -R 755 storage/* bootstrap/cache/
    export COMPOSER_ALLOW_SUPERUSER=1
    composer install --no-dev --optimize-autoloader
    
    php artisan migrate --seed --force
    chown -R www-data:www-data /var/www/reviactyl/*
    systemctl enable --now reviq.service 2>/dev/null
    
    php artisan up
    echo -e "${GREEN}🎉 Update Complete!${NC}"
    read -p "Press Enter to return..."
}

# ===================== MENU =====================
while true; do
    clear
    echo -e "${YELLOW}╔═══════════════════════════════════════════════╗"
    echo "║        🐲 REVIACTYL CONTROL CENTER            ║"
    echo "╠═══════════════════════════════════════════════╣"
    echo -e "║ ${GREEN}1) Install Panel${NC}"
    echo -e "║ ${CYAN}2) Create Panel User${NC}"
    echo -e "║ ${YELLOW}3) Reset Panel (p:upgrade)${NC}"
    echo -e "║ ${RED}4) Uninstall Panel${NC}"
    echo -e "║ ${BLUE}5) Migrate (Ptero -> Reviactyl)${NC}"
    echo -e "║ ${GREEN}6) Update Panel (Latest Release)${NC}"
    echo -e "║ 7) Exit"
    echo "╚═══════════════════════════════════════════════╝"
    echo -ne "${CYAN}Select Option → ${NC}"
    read choice

    case $choice in
        1) install_ptero ;;
        2) create_user ;;
        3) reset_panel ;;
        4) uninstall_ptero ;;
        5) Migrating ;;
        6) update ;;
        7) clear; exit 0 ;;
        *) echo -e "${RED}Invalid option...${NC}"; sleep 1 ;;
    esac
done
