#!/bin/bash

# --- COLORS & STYLES ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Check for root/sudo
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ Error: This script must be run as root (use sudo).${NC}"
   exit 1
fi

# UI Elements
TOP="╔════════════════════════════════════════════════════════════╗"
BOTTOM="╚════════════════════════════════════════════════════════════╝"

show_header() {
    clear
    printf "${CYAN}${TOP}\n"
    printf "║${WHITE}                 🚀 PAYMENTER CONTROL PANEL                  ${CYAN}║\n"
    printf "╠════════════════════════════════════════════════════════════╣\n"
    printf "║${YELLOW}             Version 2.0 • Secure Panel Manager              ${CYAN}║\n"
    printf "${BOTTOM}${NC}\n\n"
}

show_menu() {
    printf "${MAGENTA}╔════════════════════════════════════════════════════════════╗\n"
    printf "║${WHITE}                        📋 MAIN MENU                         ${MAGENTA}║\n"
    printf "╠════════════════════════════════════════════════════════════╣\n"
    printf "║${GREEN}    1. ${WHITE}📥 Install Paymenter          ${MAGENTA}║\n"
    printf "║${RED}    2. ${WHITE}🗑️  Uninstall Paymenter                         ${MAGENTA}║\n"
    printf "║${YELLOW}    3. ${WHITE}🔄 Update Paymenter                            ${MAGENTA}║\n"
    printf "║${WHITE}    4. ${WHITE}❌ Exit                                        ${MAGENTA}║\n"
    printf "╚════════════════════════════════════════════════════════════╝${NC}\n\n"
}

install_paymenter() {
    printf "${GREEN}╔════════════════════════════════════════════════════════════╗\n"
    printf "║${WHITE}                📥 INSTALLING PAYMENTER                   ${GREEN}║\n"
    printf "╠════════════════════════════════════════════════════════════╣${NC}\n"
    
    echo "🚀 Starting Paymenter installation..."
    bash <(curl -s https://raw.githubusercontent.com/lie-kg/lie-kg-Hub/refs/heads/main/srv/panel/Payment.sh)
    
    printf "${GREEN}║                                                            ║\n"
    printf "║${WHITE}           ✅ INSTALLATION PROCESS COMPLETE!               ${GREEN}║\n"
    printf "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

uninstall_paymenter() {
    printf "${RED}╔════════════════════════════════════════════════════════════╗\n"
    printf "║${WHITE}                ⚠️ UNINSTALLING PAYMENTER                  ${RED}║\n"
    printf "╠════════════════════════════════════════════════════════════╣${NC}\n"
    
    read -p "Are you absolutely sure? (y/N): " confirm
    [[ "$confirm" != "y" && "$confirm" != "Y" ]] && return

    echo "🗑️  Stopping service..."
    systemctl stop paymenter 2>/dev/null
    systemctl disable paymenter 2>/dev/null
    rm -f /etc/systemd/system/paymenter.service
    
    echo "🗑️  Removing files and configs..."
    rm -rf /var/www/paymenter
    rm -f /etc/nginx/sites-enabled/paymenter.conf /etc/nginx/sites-available/paymenter.conf
    rm -rf /etc/nginx/adblock
    rm -f /etc/nginx/conf.d/adblock.conf
    
    echo "🗑️  Dropping database..."
    mysql -u root -e "DROP DATABASE IF EXISTS paymenter; DROP USER IF EXISTS 'paymenteruser'@'127.0.0.1'; FLUSH PRIVILEGES;" 2>/dev/null
    
    echo "🗑️  Cleaning crontab..."
    (crontab -l 2>/dev/null | grep -v 'paymenter/artisan schedule:run') | crontab - 2>/dev/null
    
    echo "🔄 Reloading Nginx..."
    nginx -t && systemctl reload nginx || true
    
    printf "${GREEN}║                                                            ║\n"
    printf "║${WHITE}           ✅ PAYMENTER COMPLETELY REMOVED!                ${GREEN}║\n"
    printf "${RED}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

update_paymenter() {
    printf "${YELLOW}╔════════════════════════════════════════════════════════════╗\n"
    printf "║${WHITE}                🔄 UPDATING PAYMENTER                     ${YELLOW}║\n"
    printf "╠════════════════════════════════════════════════════════════╣${NC}\n"
    
    if [ ! -d "/var/www/paymenter" ]; then
        echo "❌ Paymenter is not installed!"
        return
    fi
    
    cd /var/www/paymenter || return
    echo "⚙️  Putting panel in maintenance mode..."
    php artisan down
    
    echo "⚙️  Running upgrade..."
    # Ensure correct permissions before artisan runs
    chown -R www-data:www-data /var/www/paymenter
    php artisan app:upgrade
    
    echo "⚙️  Optimizing..."
    php artisan view:clear && php artisan config:clear
    php artisan up
    
    printf "${GREEN}║                                                            ║\n"
    printf "║${WHITE}           ✅ PAYMENTER UPDATED SUCCESSFULLY!              ${GREEN}║\n"
    printf "${YELLOW}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

# Main loop
while true; do
    show_header
    show_menu
    
    printf "${CYAN}┌─[${WHITE}SELECT OPTION${CYAN}]${NC}\n"
    printf "${CYAN}└──╼${WHITE} $ ${NC}"
    read -p "" option
    
    case $option in
        1) install_paymenter ;;
        2) uninstall_paymenter ;;
        3) update_paymenter ;;
        4)
            printf "\n${CYAN}╔════════════════════════════════════════════════════════════╗\n"
            printf "║${WHITE}                     👋 GOODBYE!                            ${CYAN}║\n"
            printf "╚════════════════════════════════════════════════════════════╝${NC}\n\n"
            exit 0
            ;;
        *)
            printf "\n${RED}❌ Invalid option! Please select 1-4${NC}\n"
            sleep 1
            ;;
    esac
    
    echo ""
    read -p "Press Enter to return to menu..."
done
