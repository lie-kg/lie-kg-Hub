#!/bin/bash
set -e

# ==============================
# COLORS + UI
# ==============================
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
NC="\e[0m"

# --- ROOT CHECK ---
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ Error: Please run this script as root (use sudo).${NC}"
   exit 1
fi

banner() {
    clear
    echo -e "${CYAN}"
    echo "══════════════════════════════════════════════"
    echo "        FEATHERPANEL CONTROL MENU"
    echo "         liekg Hub | Auto Script"
    echo "══════════════════════════════════════════════"
    echo -e "${NC}"
}

pause() {
    echo ""
    read -rp "Press Enter to continue..."
}

install_panel() {
    echo -e "\n${BLUE}▶▶ Starting FeatherPanel INSTALL...${NC}"
    # Using -f to force bash to ignore errors in the remote script if necessary
    bash <(curl -s https://raw.githubusercontent.com/lie-kg/lie-kg-Hub/refs/heads/main/srv/panel/tool/FeatherPanel.sh) || echo -e "${RED}Install failed.${NC}"
}

uninstall_panel() {
    echo -e "\n${RED}⚠️  WARNING: Starting FeatherPanel UNINSTALL...${NC}"
    read -rp "Are you sure? (y/N): " confirm
    [[ "$confirm" != "y" && "$confirm" != "Y" ]] && return

    # 1. CRON CLEANUP
    # Filter out FeatherPanel lines and re-apply, or clear if empty
    tmp_cron=$(mktemp)
    crontab -l 2>/dev/null | grep -v "featherpanel" > "$tmp_cron" || true
    if [ -s "$tmp_cron" ]; then
        crontab "$tmp_cron"
    else
        crontab -r 2>/dev/null || true
    fi
    rm -f "$tmp_cron"

    # 2. FILE REMOVAL
    echo "Removing files and Nginx configs..."
    rm -rf /var/www/featherpanel
    rm -f /etc/nginx/sites-enabled/FeatherPanel.conf
    rm -f /etc/nginx/sites-available/FeatherPanel.conf
    rm -rf /etc/certs/featherpanel

    # 3. DATABASE REMOVAL
    echo "Dropping database..."
    mariadb -e "DROP DATABASE IF EXISTS featherpanel;" 2>/dev/null || true
    mariadb -e "DROP USER IF EXISTS 'featherpanel'@'127.0.0.1';" 2>/dev/null || true
    mariadb -e "FLUSH PRIVILEGES;" 2>/dev/null || true

    # 4. NGINX REFRESH
    if nginx -t >/dev/null 2>&1; then
        systemctl reload nginx
        echo -e "${GREEN}✔ Nginx reloaded successfully.${NC}"
    else
        echo -e "${YELLOW}⚠ Nginx config has errors, please check manually.${NC}"
    fi

    echo -e "${GREEN}✔ FeatherPanel uninstalled (dependencies untouched)${NC}"
}

# ==============================
# MENU LOOP
# ==============================
while true; do
    banner
    echo -e "${YELLOW}1) Install FeatherPanel"
    echo "2) Uninstall FeatherPanel"
    echo -e "3) Exit${NC}"
    echo "──────────────────────────────────────"
    read -rp "Select option → " opt

    case "$opt" in
        1)
            install_panel
            pause
            ;;
        2)
            uninstall_panel
            pause
            ;;
        3)
            echo -e "${GREEN}Bye boss 👋${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            sleep 1
            ;;
    esac
done
