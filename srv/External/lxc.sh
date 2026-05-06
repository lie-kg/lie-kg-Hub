# Function to show image management (Completing your last function)
image_management() {
    while true; do
        print_header
        print_color "$CYAN" "🖼️  Image Management"
        echo "══════════════════════════════════════════════════════"
        echo
        print_color "$YELLOW" "📋 Operations:"
        echo "  1) 🔍 Search Remote Images"
        echo "  2) 📋 List Local Images"
        echo "  3) 🔄 Refresh Image Cache"
        echo "  4) 🗑️  Delete Local Image"
        echo "  0) ↩️  Back"
        echo

        read -p "🎯 Select operation: " img_opt

        case $img_opt in
            1) search_images ;;
            2) 
                print_color "$BLUE" "📦 Local Images:"
                lxc image list
                read -p "⏎ Press Enter to continue..."
                ;;
            3) detect_available_images ;;
            4)
                lxc image list
                read -p "🗑️  Enter Fingerprint/Alias to delete: " img_del
                if [[ -n "$img_del" ]]; then
                    lxc image delete "$img_del" && print_color "$GREEN" "✅ Image deleted" || print_color "$RED" "❌ Delete failed"
                fi
                sleep 2
                ;;
            0) return ;;
            *) print_color "$RED" "❌ Invalid option!" ; sleep 1 ;;
        esac
    done
}

# ============================================
# Main Menu Loop
# ============================================
main_menu() {
    while true; do
        print_header
        print_color "$CYAN" "📱 Main Menu - System Status: $(lxc version &>/dev/null && echo -e "${GREEN}Online${NC}" || echo -e "${RED}Offline${NC}")"
        echo "══════════════════════════════════════════════════════"
        echo "  1) 🚀 Create New Container/VM"
        echo "  2) 📋 List All Containers"
        echo "  3) ⚙️  Manage/Control Containers"
        echo "  4) 🖼️  Image Management"
        echo "  5) 📊 System Information"
        echo "  6) 🔍 Check Installation/Status"
        echo "  7) 🔧 Install Dependencies (Initial Setup)"
        echo "  0) 🚪 Exit"
        echo "══════════════════════════════════════════════════════"
        echo
        read -p "🎯 Select an option: " choice

        case $choice in
            1) create_container ;;
            2) list_containers ;;
            3) manage_container ;;
            4) image_management ;;
            5) show_system_info ;;
            6) check_installation ;;
            7) install_dependencies ;;
            0) 
                print_color "$CYAN" "👋 Goodbye!"
                exit 0 
                ;;
            *) 
                print_color "$RED" "❌ Invalid selection!"
                sleep 1
                ;;
        esac
    done
}

# Entry point of the script
if [[ $EUID -ne 0 ]]; then
   print_color "$YELLOW" "⚠️  Note: Some features may require sudo privileges."
   sleep 1
fi

# Initial check and start
main_menu
