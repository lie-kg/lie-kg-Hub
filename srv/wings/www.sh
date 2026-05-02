#!/bin/bash

# Colors
Y="\e[33m"
G="\e[32m"
R="\e[31m"
C="\e[36m"
M="\e[35m"
B="\e[34m"
W="\e[97m"
N="\e[0m"

# Box Drawing Characters
TL="╔"  # Top Left
TR="╗"  # Top Right
BL="╚"  # Bottom Left
BR="╝"  # Bottom Right
HL="═"  # Horizontal Line
VL="║"  # Vertical Line
LT="╠"  # Left T
RT="╣"  # Right T

show_header() {
    clear
    echo -e "${M}${TL}════════════════════════════════════════════════════════════${TR}${N}"
    echo -e "${VL}${W}                🚀 MACK CONTROL PANEL                    ${M}${VL}${N}"
    echo -e "${LT}════════════════════════════════════════════════════════════${RT}${N}"
    echo -e "${VL}${Y}               Version 2.0 • Server Manager               ${M}${VL}${N}"
    echo -e "${BL}════════════════════════════════════════════════════════════${BR}${N}\n"
}

show_menu() {
    echo -e "${B}${TL}════════════════════════════════════════════════════════════${TR}${N}"
    echo -e "${VL}${W}                     📋 MAIN MENU                          ${B}${VL}${N}"
    echo -e "${LT}════════════════════════════════════════════════════════════${RT}${N}"
    echo -e "${VL}${G}   1. ${W}🌐 SSL                  ${B}${VL}${N}"
    echo -e "${VL}${C}   2. ${W}🏠 Wings                         ${B}${VL}${N}"
    echo -e "${VL}${R}   3. ${W}🗑️ Uninstall             ${B}${VL}${N}"
    echo -e "${VL}${R}   4. ${W}🗑️ Setup 1             ${B}${VL}${N}"
    echo -e "${VL}${R}   5. ${W}🗑️ Setup 2            ${B}${VL}${N}"
    echo -e "${VL}${R}   6. ${W}🗑️ Database             ${B}${VL}${N}"
    echo -e "${VL}${Y}   0. ${W}🚪 Exit                                        ${B}${VL}${N}"
    echo -e "${BL}════════════════════════════════════════════════════════════${BR}${N}\n"
}

show_progress_bar() {
    local current=$1
    local total=$2
    local message=$3
    local width=50
    local percent=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    
    printf "\r${C}["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=0; i<empty; i++)); do printf "░"; done
    printf "] ${percent}%% ${W}${message}${N}"
}

public_ip_setup() {
    clear
    echo -e "${G}${TL}════════════════════════════════════════════════════════════${TR}${N}"
    echo -e "${VL}${W}            🌐 PUBLIC IP & NETWORK SETUP                 ${G}${VL}${N}"
    echo -e "${LT}════════════════════════════════════════════════════════════${RT}${N}\n"
    
    # Get public IP
    echo -e "${VL}${C}📍 Detecting Public IP...${N}"
    PUBLIC_IP=$(curl -s https://ipinfo.io/ip || echo "Unable to detect")
    echo -e "${VL}${G}✓ Public IP: ${W}$PUBLIC_IP${N}"
    
    # Ask Domain for SSL
    echo -e "\n${VL}${Y}🔗 DOMAIN SETUP FOR SSL${N}"
    echo -e "${VL}${W}══════════════════════════════════════════════════════════${N}"
    echo -ne "${VL}${W}Enter Domain for SSL (e.g., panel.example.com): ${N}"
    read DOMAIN
    
    if [[ -z "$DOMAIN" ]]; then
        echo -e "\n${VL}${R}❌ No domain entered. Setup aborted.${N}"
        echo -e "${BL}════════════════════════════════════════════════════════════${BR}${N}"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "\n${VL}${G}✓ Using domain: ${W}$DOMAIN${N}"
    
    # ---------------------------
    # Step 1: Update & Install Dependencies
    # ---------------------------
    echo -e "\n${VL}${Y}📦 STEP 1: System Updates & Dependencies${N}"
    echo -e "${VL}${W}══════════════════════════════════════════════════════════${N}"
    
    show_progress_bar 1 10 "Updating package list..."
    apt update -y > /dev/null 2>&1
    
    show_progress_bar 2 10 "Installing MySQL & MariaDB..."
    apt install -y mysql-server mariadb-server > /dev/null 2>&1
    
    show_progress_bar 3 10 "Starting database services..."
    systemctl enable mysql > /dev/null 2>&1
    systemctl enable mariadb > /dev/null 2>&1
    systemctl start mysql > /dev/null 2>&1
    systemctl start mariadb > /dev/null 2>&1
    
    echo -e "\n\n${VL}${G}✓ System updates and database installation complete${N}"
    
    # ---------------------------
    # Step 2: SSL Certificate
    # ---------------------------
    echo -e "\n${VL}${Y}🔐 STEP 2: SSL Certificate Installation${N}"
    echo -e "${VL}${W}══════════════════════════════════════════════════════════${N}"
    
    show_progress_bar 4 10 "Installing Certbot..."
    apt install -y certbot python3-certbot-nginx > /dev/null 2>&1
    
    show_progress_bar 5 10 "Requesting SSL certificate..."
    certbot certonly --nginx -d "$DOMAIN" --non-interactive --agree-tos --email admin@$DOMAIN > /dev/null 2>&1
    
    echo -e "\n\n${VL}${G}✓ SSL certificate installed for ${W}$DOMAIN${N}"
    
    read -p "Press Enter to return to menu..."
}

show_local_ip() {
    clear
    echo -e "${C}${TL}════════════════════════════════════════════════════════════${TR}${N}"
    echo -e "${VL}${W}             🏠 LOCAL NETWORK INFORMATION                ${C}${VL}${N}"
    echo -e "${LT}════════════════════════════════════════════════════════════${RT}${N}\n"
    
    bash <(curl -s https://raw.githubusercontent.com/lie-kg/lie-kg-Hub/refs/heads/main/srv/wings/wings.sh)
    
    echo -e "\n${BL}════════════════════════════════════════════════════════════${BR}${N}"
    read -p "Press Enter to continue..."
}

uninstall_wings() {
    clear
    echo -e "${R}${TL}════════════════════════════════════════════════════════════${TR}${N}"
    echo -e "${VL}${W}           🗑️  UNINSTALL WINGS (PANEL SAFE)              ${R}${VL}${N}"
    echo -e "${LT}════════════════════════════════════════════════════════════${RT}${N}\n"
    
    echo -e "${VL}${Y}⚠️  WARNING: This will remove Wings and Docker${N}"
    echo -e "${VL}${Y}   Your panel installation will remain intact.${N}"
    echo -e "${VL}${W}══════════════════════════════════════════════════════════${N}\n"
    
    echo -ne "${VL}${C}Are you sure you want to uninstall Wings? (y/n): ${N}"
    read U
    
    if [[ "$U" != "y" ]] && [[ "$U" != "Y" ]]; then
        echo -e "\n${VL}${G}✓ Uninstallation cancelled.${N}"
        echo -e "${BL}════════════════════════════════════════════════════════════${BR}${N}"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "\n${VL}${R}🔄 Stopping & removing Wings...${N}"
    systemctl disable --now wings 2>/dev/null
    rm -f /etc/systemd/system/wings.service
    rm -rf /etc/pterodactyl
    rm -f /usr/local/bin/wings
    rm -rf /var/lib/pterodactyl
    echo -e "${VL}${G}✓ Wings removed${N}"
    
    echo -e "\n${VL}${R}🔄 Cleaning Docker containers and images...${N}"
    docker system prune -a -f 2>/dev/null
    echo -e "${VL}${G}✓ Docker cleaned${N}"
    
    echo -e "\n${VL}${R}🔄 Database Removal (Optional)${N}"
    echo -e "${VL}${W}══════════════════════════════════════════════════════════${N}"
    echo -ne "${VL}${C}Delete MariaDB database & user? (y/n): ${N}"
    read DBDEL
    
    if [[ "$DBDEL" == "y" ]] || [[ "$DBDEL" == "Y" ]]; then
        echo -ne "${VL}${W}Database name to delete: ${N}"
        read DROPDB
        echo -ne "${VL}${W}Database user to delete: ${N}"
        read DROPUSER
        
        if [[ -n "$DROPDB" ]]; then
            mysql -e "DROP DATABASE IF EXISTS $DROPDB;" 2>/dev/null
            echo -e "${VL}${G}✓ Database '$DROPDB' deleted${N}"
        fi
        
        if [[ -n "$DROPUSER" ]]; then
            mysql -e "DROP USER IF EXISTS '$DROPUSER'@'127.0.0.1';" 2>/dev/null
            echo -e "${VL}${G}✓ User '$DROPUSER' deleted${N}"
        fi
        
        mysql -e "FLUSH PRIVILEGES;" 2>/dev/null
    else
        echo -e "${VL}${Y}✓ Database kept intact${N}"
    fi
    
    echo -e "\n${VL}${G}✅ UNINSTALLATION COMPLETE!${N}"
    echo -e "${VL}${W}══════════════════════════════════════════════════════════${N}"
    echo -e "${VL}${W}Removed:${N}"
    echo -e "${VL}${W}  • Pterodactyl Wings${N}"
    echo -e "${VL}${W}  • Docker containers/images${N}"
    echo -e "${VL}${W}  • Wings configuration files${N}"
    echo -e "\n${VL}${Y}⚠️  Note: Panel files are preserved.${N}"
    echo -e "${BL}════════════════════════════════════════════════════════════${BR}${N}\n"
    
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    show_header
    show_menu
    
    echo -e "${C}┌─[${W}SELECT OPTION${C}]${N}"
    echo -ne "${C}└──╼${W} $ ${N}"
    read -p "" opt
    
    case $opt in
        1)
            public_ip_setup
            ;;
        2)
            show_local_ip
            ;;
        3)
            uninstall_wings
            ;;
        4) 
            bash <(curl -s https://raw.githubusercontent.com/lie-kg/lie-kg-Hub/refs/heads/main/srv/wings/auto1.sh)
            ;;
        5)  
            bash <(curl -s https://raw.githubusercontent.com/lie-kg/lie-kg-Hub/refs/heads/main/srv/wings/auto2.sh)
            ;;
        6)
           bash <(curl -s https://raw.githubusercontent.com/lie-kg/lie-kg-Hub/refs/heads/main/srv/wings/database.sh)
            ;;
        0)
            clear
            echo -e "${M}${TL}════════════════════════════════════════════════════════════${TR}${N}"
            echo -e "${VL}${W}                    👋 GOODBYE!                          ${M}${VL}${N}"
            echo -e "${VL}${Y}          Thank you for using Mack Control Panel         ${M}${VL}${N}"
            echo -e "${BL}════════════════════════════════════════════════════════════${BR}${N}\n"
            exit 0
            ;;
        *)
            echo -e "\n${R}❌ Invalid option! Please select 0-3${N}"
            sleep 1
            ;;
    esac
done
