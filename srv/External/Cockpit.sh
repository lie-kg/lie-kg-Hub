#!/bin/bash
set -e

# ===== Colors =====
R="\e[31m"; G="\e[32m"; Y="\e[33m"; B="\e[34m"; C="\e[36m"; W="\e[0m"

# ===== Helper Functions =====
svc_status() {
  systemctl is-active --quiet "$1" && echo -e "${G}RUNNING${W}" || echo -e "${R}STOPPED${W}"
}

detect_port() {
  local conf="/etc/systemd/system/cockpit.socket.d/listen.conf"
  # Try detecting from config file first (works even if service is stopped)
  if [[ -f "$conf" ]]; then
    grep "ListenStream=" "$conf" | cut -d= -f2 | tail -n1
  else
    # Fallback to active socket detection
    local active_port
    active_port=$(ss -lntp 2>/dev/null | grep cockpit.socket | awk -F: '{print $NF}' | head -n1)
    echo "${active_port:-9090}"
  fi
}

pause(){ read -rp "👉 Press Enter to continue..."; }

# ===== UI Components =====
draw_header() {
  clear
  echo -e "${C}╔════════════════════════════════════════════╗${W}"
  echo -e "${C}║${W}   🛠️  ${B}COCKPIT + KVM CONTROL PANEL${W}   ${C}║${W}"
  echo -e "${C}╚════════════════════════════════════════════╝${W}"
  echo ""
}

draw_status() {
  local port
  port=$(detect_port)
  echo -e "${Y}┌────────── SYSTEM STATUS ──────────┐${W}"
  echo -e "${Y}│${W} Cockpit Socket : $(svc_status cockpit.socket)"
  echo -e "${Y}│${W} Libvirt Daemon : $(svc_status libvirtd)"
  echo -e "${Y}│${W} Cockpit Port   : ${C}${port}${W}"
  echo -e "${Y}└───────────────────────────────────┘${W}"
  echo ""
}

draw_menu() {
  echo -e "${Y}┌──────────────── MENU ────────────────┐${W}"
  echo -e "${Y}│${W} ${G}1${W}) Install/Repair Stack"
  echo -e "${Y}│${W} ${R}2${W}) Uninstall Everything"
  echo -e "${Y}│${W} ${C}3${W}) Change Cockpit Port"
  echo -e "${Y}│${W} ${W}4${W}) Exit"
  echo -e "${Y}└──────────────────────────────────────┘${W}"
  echo ""
}

# ===== Actions =====
install_stack() {
  echo -e "${G}🔥 Updating and installing stack...${W}"
  
  # Prevent script crash on apt update failure
  sudo apt update || echo -e "${R}Warning: apt update failed.${W}"
  
  sudo apt install -y cockpit cockpit-machines qemu-kvm libvirt-daemon-system \
  libvirt-clients bridge-utils virt-manager
  
  sudo systemctl enable --now cockpit.socket
  sudo systemctl enable --now libvirtd
  
  sudo usermod -aG libvirt,kvm "$USER"
  sudo rm -f /etc/cockpit/disallowed-users
  sudo systemctl restart cockpit

  echo -e "${G}✅ Install done.${W}"
  echo -e "${Y}⚠️  IMPORTANT: Please log out and back in for VM permissions to take effect.${W}"
  pause
}

uninstall_stack() {
  echo -e "${R}🧨 DANGER: This will remove Cockpit and all KVM tools.${W}"
  read -rp "Are you sure you want to continue? (y/n): " confirm
  if [[ "$confirm" != "y" ]]; then
    echo -e "${G}Aborted.${W}"
    sleep 1
    return
  fi

  sudo systemctl disable --now cockpit.socket || true
  sudo systemctl disable --now libvirtd || true

  sudo apt purge -y cockpit cockpit-machines virt-manager \
  qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
  sudo apt autoremove -y
  sudo apt autoclean

  echo -e "${R}❌ Everything removed.${W}"
  pause
}

change_port() {
  read -rp "🔢 New Cockpit port: " NEW_PORT
  [[ ! "$NEW_PORT" =~ ^[0-9]+$ ]] && echo -e "${R}Invalid port format.${W}" && pause && return

  sudo mkdir -p /etc/systemd/system/cockpit.socket.d
  sudo tee /etc/systemd/system/cockpit.socket.d/listen.conf >/dev/null <<EOF
[Socket]
ListenStream=
ListenStream=$NEW_PORT
EOF

  sudo systemctl daemon-reload
  sudo systemctl restart cockpit.socket

  # Firewall update if UFW is present
  if command -v ufw >/dev/null; then
    sudo ufw allow "$NEW_PORT"/tcp
    echo -e "${C}UFW: Allowed port $NEW_PORT${W}"
  fi

  echo -e "${G}✅ Port changed to $NEW_PORT${W}"
  pause
}

# ===== Main Loop =====
while true; do
  draw_header
  draw_status
  draw_menu

  read -rp "Select [1-4]: " choice
  case "$choice" in
    1) install_stack ;;
    2) uninstall_stack ;;
    3) change_port ;;
    4) echo -e "${B}👋 Exit. System under control.${W}"; exit 0 ;;
    *) echo -e "${R}❌ Invalid choice${W}"; sleep 1 ;;
  esac
done
