docker exec -it "$container_name" /bin/sh
                fi
                ;;
            7)
                print_header "📝 Logs: $container_name"
                print_color "$YELLOW" "💡 Press Ctrl+C to exit logs"
                docker logs -f --tail 100 "$container_name"
                ;;
            8)
                print_header "📊 Live Stats: $container_name"
                print_color "$YELLOW" "💡 Press Ctrl+C to exit stats"
                docker stats "$container_name"
                ;;
            9)
                docker inspect "$container_name" | less
                ;;
            10)
                print_header "⚙️ Update Resources"
                read -p "New Memory Limit (e.g., 1g): " new_mem
                read -p "New CPU Limit (e.g., 2): " new_cpu
                docker update --memory "$new_mem" --cpus "$new_cpu" "$container_name"
                ;;
            11)
                read -p "Enter new image name (repo:tag): " new_img
                docker commit "$container_name" "$new_img"
                print_color "$GREEN" "✅ Image created!"
                sleep 2
                ;;
            12)
                print_color "$RED" "⚠️  DANGER: Remove container '$container_name'?"
                read -p "Confirm by typing 'yes': " confirm_del
                if [[ "$confirm_del" == "yes" ]]; then
                    docker rm -f "$container_name"
                    print_color "$GREEN" "✅ Container deleted."
                    return 0
                fi
                ;;
            0)
                return 0
                ;;
            *)
                print_color "$RED" "❌ Invalid choice!"
                sleep 1
                ;;
        esac
    done
}

# ============================================
# Main Execution Entry Point
# ============================================

# Initial environment check
check_docker_installation

# Main Menu Loop
while true; do
    print_banner
    print_color "$CYAN" "  1) 🚀 Create New Container"
    print_color "$CYAN" "  2) 📋 List All Containers"
    print_color "$CYAN" "  3) ⚙️  Manage Existing Container"
    print_color "$CYAN" "  4) 📊 System Information"
    print_color "$RED"  "  0) 🚪 Exit"
    echo ""
    read -p "🎯 Selection: " main_choice

    case $main_choice in
        1) create_docker_container ;;
        2) list_docker_containers ;;
        3) manage_docker_container ;;
        4) show_system_info ;;
        0) print_color "$GREEN" "👋 Goodbye!"; exit 0 ;;
        *) print_color "$RED" "❌ Invalid selection!"; sleep 1 ;;
    esac
done
