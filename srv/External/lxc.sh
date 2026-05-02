#!/bin/bash

# ============================================
# LXC/LXD Container Manager
# Version: 3.0 - Auto Image Detection
# ============================================


# if you use Ubuntu


# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to print header
print_header() {
    clear
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║            LXC/LXD Container Manager                 ║"
    echo "║               Mode BY - lie_kg                       ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo
}

# Default image database (fallback)
declare -A DEFAULT_IMAGES=(
    ["1"]="ubuntu:22.04|Ubuntu 22.04 Jammy"
    ["2"]="almalinux/9|AlmaLinux 9"
    ["3"]="centos/stream-9|CentOS Stream 9"
    ["4"]="ubuntu:24.04|Ubuntu 24.04 Noble"
    ["5"]="rockylinux/9|Rocky Linux 9"
    ["6"]="fedora/40|Fedora 40"
    ["7"]="debian/11|Debian 11 Bullseye"
    ["8"]="debian/trixie-daily|Debian 13 Trixie"
    ["9"]="debian/12|Debian 12 Bookworm"
)

# Function to install dependencies
install_dependencies() {
    print_header
    print_color "$CYAN" "🔧 Installing Dependencies..."
    echo "══════════════════════════════════════════════════════"
    
    # Detect distribution
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS_NAME=$ID
    else
        print_color "$RED" "❌ Cannot detect OS distribution!"
        exit 1
    fi
    
    print_color "$BLUE" "📊 Detected: $PRETTY_NAME"
    echo
    
    case $OS_NAME in
        ubuntu|debian)
            print_color "$GREEN" "📦 Installing for Ubuntu/Debian..."
            echo
            
            # Update package lists
            print_color "$CYAN" "🔄 Updating package lists..."
            sudo apt update -y
            
            # Install LXC
            print_color "$CYAN" "📥 Installing LXC..."
            sudo apt install -y lxc lxc-utils lxc-templates bridge-utils uidmap
            
            # Install and configure snapd for LXD
            if ! command -v snap &> /dev/null; then
                print_color "$CYAN" "📦 Installing snapd..."
                sudo apt install -y snapd
                sudo systemctl enable --now snapd.socket
                sudo ln -s /var/lib/snapd/snap /snap 2>/dev/null || true
                echo "⚠️  Please log out and log back in for snap to work properly"
            fi
            
            # Install LXD
            print_color "$CYAN" "🚀 Installing LXD..."
            sudo snap install lxd
            
            # Add user to lxd group
            print_color "$CYAN" "👤 Adding user to lxd group..."
            sudo usermod -aG lxd $USER
            
            # Initialize LXD
            print_color "$CYAN" "⚙️  Initializing LXD..."
            echo "This will set up LXD with default settings..."
            sudo lxd init --auto
            
            # Start LXD service
            print_color "$CYAN" "▶️  Starting LXD service..."
            sudo systemctl start snap.lxd.daemon 2>/dev/null || sudo systemctl start lxd 2>/dev/null
            
            print_color "$GREEN" "✅ Dependencies installed successfully!"
            echo
            print_color "$YELLOW" "⚠️  IMPORTANT: Please log out and log back in for group changes!"
            print_color "$YELLOW" "   Then run this script again."
            ;;
        *)
            print_color "$RED" "❌ Unsupported OS: $OS_NAME"
            print_color "$YELLOW" "📋 Manual installation required:"
            echo "For Ubuntu/Debian:"
            echo "  sudo apt install lxc lxc-utils bridge-utils snapd"
            echo "  sudo snap install lxd"
            echo "  sudo usermod -aG lxd \$USER"
            echo "  sudo lxd init --auto"
            ;;
    esac
    
    read -p "⏎ Press Enter to continue..."
    exit 0
}

# Function to check installation
check_installation() {
    print_header
    print_color "$CYAN" "🔍 Checking Installation..."
    echo "══════════════════════════════════════════════════════"
    echo
    
    local checks_passed=0
    local total_checks=5
    
    # Check LXC
    if command -v lxc &> /dev/null; then
        print_color "$GREEN" "✅ LXC is installed"
        ((checks_passed++))
    else
        print_color "$RED" "❌ LXC is NOT installed"
    fi
    
    # Check LXD
    if command -v lxd &> /dev/null; then
        print_color "$GREEN" "✅ LXD is installed"
        ((checks_passed++))
    else
        print_color "$RED" "❌ LXD is NOT installed"
    fi
    
    # Check if user is in lxd group
    if groups $USER | grep -q '\blxd\b'; then
        print_color "$GREEN" "✅ User is in lxd group"
        ((checks_passed++))
    else
        print_color "$YELLOW" "⚠️  User is NOT in lxd group"
    fi
    
    # Check LXD service
    if systemctl is-active --quiet snap.lxd.daemon 2>/dev/null || systemctl is-active --quiet lxd 2>/dev/null; then
        print_color "$GREEN" "✅ LXD service is running"
        ((checks_passed++))
    else
        print_color "$RED" "❌ LXD service is NOT running"
    fi
    
    # Check if LXD is initialized
    if lxc cluster list 2>&1 | grep -q "no such file or directory" || lxc cluster list 2>&1 | grep -q "not initialized"; then
        print_color "$YELLOW" "⚠️  LXD is not initialized"
    else
        print_color "$GREEN" "✅ LXD is initialized"
        ((checks_passed++))
    fi
    
    echo
    print_color "$BLUE" "📊 Status: $checks_passed/$total_checks checks passed"
    
    if [[ $checks_passed -eq $total_checks ]]; then
        print_color "$GREEN" "🎉 All systems go! LXC/LXD is ready."
    elif [[ $checks_passed -ge 3 ]]; then
        print_color "$YELLOW" "⚠️  Some issues detected. Check below:"
        echo
        print_color "$CYAN" "💡 Troubleshooting tips:"
        echo "1. If not in lxd group, run: sudo usermod -aG lxd $USER"
        echo "2. If LXD not initialized, run: sudo lxd init --auto"
        echo "3. If service not running: sudo systemctl start snap.lxd.daemon"
        echo "4. Log out and log back in after adding to lxd group"
    else
        print_color "$RED" "🚨 Major issues detected. Please reinstall dependencies."
    fi
    
    read -p "⏎ Press Enter to continue..."
}

# Function to detect available images
detect_available_images() {
    print_color "$CYAN" "🔍 Scanning for available images..."
    echo
    
    # Clear previous image list
    declare -gA AVAILABLE_IMAGES
    AVAILABLE_IMAGES=()
    
    # List of remotes to check
    local remotes=("images" "ubuntu" "debian" "fedora" "centos" "almalinux" "rockylinux")
    local image_count=0
    
    # Try to get images from remotes
    for remote in "${remotes[@]}"; do
        print_color "$BLUE" "📡 Checking remote: $remote"
        
        # Try to list images from this remote
        local remote_images=$(timeout 10 lxc image list "$remote:" 2>/dev/null | grep -E "^\| [a-zA-Z0-9/:-]+ \|" | head -20)
        
        if [[ -n "$remote_images" ]]; then
            while IFS= read -r line; do
                # Extract image name from line
                local image_name=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
                local description=$(echo "$line" | awk -F'|' '{print $3}' | xargs | cut -c1-50)
                
                if [[ -n "$image_name" && ! "$image_name" =~ "ALIAS" && ! "$image_name" =~ "FINGERPRINT" ]]; then
                    ((image_count++))
                    AVAILABLE_IMAGES["$image_count"]="$remote:$image_name|$description"
                    echo "  ✅ Found: $remote:$image_name"
                fi
            done <<< "$remote_images"
        else
            echo "  ⚠️  No images found or remote not accessible"
        fi
    done
    
    # If no images found, use defaults
    if [[ ${#AVAILABLE_IMAGES[@]} -eq 0 ]]; then
        print_color "$YELLOW" "⚠️  Could not detect images automatically. Using defaults..."
        AVAILABLE_IMAGES=("${DEFAULT_IMAGES[@]}")
        for key in "${!DEFAULT_IMAGES[@]}"; do
            AVAILABLE_IMAGES["$key"]="${DEFAULT_IMAGES[$key]}"
        done
    fi
    
    echo
    print_color "$GREEN" "✅ Found ${#AVAILABLE_IMAGES[@]} available images"
    sleep 1
}

# Function to show image selection menu
show_image_menu() {
    print_header
    print_color "$CYAN" "📦 Available Container Images"
    echo "══════════════════════════════════════════════════════"
    echo
    
    # Sort image keys numerically
    mapfile -t sorted_keys < <(printf '%s\n' "${!AVAILABLE_IMAGES[@]}" | sort -n)
    
    for key in "${sorted_keys[@]}"; do
        IFS='|' read -r image_name display_name <<< "${AVAILABLE_IMAGES[$key]}"
        print_color "$GREEN" "  $key) $display_name"
        print_color "$BLUE" "     📦 Image: $image_name"
        echo
    done
    
    echo "══════════════════════════════════════════════════════"
    echo "  0) ↩️  Back to Main Menu"
    echo "  r) 🔄 Refresh Image List"
    echo
}

# Function to search for specific images
search_images() {
    print_header
    print_color "$CYAN" "🔍 Search Images"
    echo "══════════════════════════════════════════════════════"
    echo
    
    read -p "🔎 Enter search term (e.g., ubuntu, debian, centos): " search_term
    
    if [[ -z "$search_term" ]]; then
        return
    fi
    
    print_color "$BLUE" "🔍 Searching for '$search_term'..."
    echo
    
    local search_results=()
    local result_count=0
    
    # Search in available images
    for key in "${!AVAILABLE_IMAGES[@]}"; do
        IFS='|' read -r image_name display_name <<< "${AVAILABLE_IMAGES[$key]}"
        if [[ "$image_name" =~ $search_term || "$display_name" =~ $search_term ]]; then
            ((result_count++))
            search_results["$result_count"]="$image_name|$display_name"
            print_color "$GREEN" "  $result_count) $display_name"
            print_color "$BLUE" "     📦 Image: $image_name"
            echo
        fi
    done
    
    if [[ $result_count -eq 0 ]]; then
        print_color "$YELLOW" "⚠️  No images found matching '$search_term'"
    fi
    
    read -p "⏎ Press Enter to continue..."
}

# Function to create container from selected image
create_container() {
    # Detect available images first
    detect_available_images
    
    while true; do
        show_image_menu
        read -p "🎯 Select image (1-${#AVAILABLE_IMAGES[@]}) or 0/r: " image_choice
        
        case $image_choice in
            0)
                return
                ;;
            r|R)
                detect_available_images
                continue
                ;;
        esac
        
        if [[ -n "${AVAILABLE_IMAGES[$image_choice]}" ]]; then
            IFS='|' read -r image_name display_name <<< "${AVAILABLE_IMAGES[$image_choice]}"
            break
        else
            print_color "$RED" "❌ Invalid selection!"
            sleep 2
        fi
    done
    
    print_header
    print_color "$CYAN" "🚀 Creating Container: $display_name"
    print_color "$BLUE" "📦 Image: $image_name"
    echo "══════════════════════════════════════════════════════"
    echo
    
    # Get container name
    while true; do
        read -p "🏷️  Enter container name: " container_name
        
        # Check if empty
        if [[ -z "$container_name" ]]; then
            print_color "$RED" "❌ Container name cannot be empty!"
            continue
        fi
        
        # Validate name format
        if [[ ! "$container_name" =~ ^[a-zA-Z][a-zA-Z0-9_-]{1,}$ ]]; then
            print_color "$RED" "❌ Invalid name! Must start with letter, can contain letters, numbers, hyphens, underscores"
            continue
        fi
        
        # Check if container already exists
        if lxc list -c n --format csv 2>/dev/null | grep -q "^$container_name$"; then
            print_color "$RED" "❌ Container '$container_name' already exists!"
            
            read -p "🔄 Use different name? (y/N): " rename_choice
            if [[ ! "$rename_choice" =~ ^[Yy]$ ]]; then
                return
            fi
            continue
        fi
        
        break
    done
    
    # Get container type
    echo
    print_color "$YELLOW" "💻 Container Type:"
    echo "  1) Container (Default) - Lightweight, shares host kernel"
    echo "  2) Virtual Machine - Full VM with its own kernel (more resources)"
    read -p "Select type (1-2, default: 1): " container_type
    container_type=${container_type:-1}
    
    local type_flag=""
    case $container_type in
        1) 
            type_flag=""
            print_color "$BLUE" "📦 Selected: Container (lightweight)"
            ;;
        2) 
            type_flag="--vm"
            print_color "$BLUE" "💻 Selected: Virtual Machine"
            ;;
        *) 
            type_flag=""
            print_color "$YELLOW" "⚠️  Using default: Container"
            ;;
    esac
    
    # Get resources
    echo
    print_color "$YELLOW" "⚙️  Resource Configuration:"
    read -p "💾 Disk size (e.g., 10GB, default: 10GB): " disk_size
    disk_size=${disk_size:-10GB}
    
    read -p "🧠 Memory (e.g., 2GB, default: 2GB): " memory
    memory=${memory:-2GB}
    
    read -p "⚡ CPU cores (default: 2): " cpu_count
    cpu_count=${cpu_count:-2}
    
    # Summary
    echo
    print_color "$CYAN" "📋 Creation Summary:"
    echo "──────────────────────────────────────"
    echo "🏷️  Name: $container_name"
    echo "📦 Image: $image_name"
    echo "💻 Type: $([ "$type_flag" == "--vm" ] && echo "Virtual Machine" || echo "Container")"
    echo "💾 Disk: $disk_size"
    echo "🧠 Memory: $memory"
    echo "⚡ CPU: $cpu_count cores"
    echo "──────────────────────────────────────"
    echo
    
    read -p "✅ Proceed with creation? (Y/n): " confirm
    confirm=${confirm:-Y}
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_color "$YELLOW" "⚠️  Creation cancelled."
        read -p "⏎ Press Enter to continue..."
        return
    fi
    
    # Create container
    print_color "$BLUE" "📦 Creating container '$container_name'..."
    echo
    
    # Try different approaches to launch container
    local launch_success=false
    
    # Approach 1: Direct launch
    print_color "$CYAN" "🔄 Attempt 1: Direct launch..."
    if lxc launch $type_flag "$image_name" "$container_name" 2>&1 | tee /tmp/lxc_launch.log; then
        launch_success=true
    else
        # Check error
        local error_msg=$(cat /tmp/lxc_launch.log)
        
        # Approach 2: Try with images: prefix
        if [[ "$error_msg" == *"not found"* ]] || [[ "$error_msg" == *"couldn't be found"* ]]; then
            print_color "$YELLOW" "🔄 Attempt 2: Trying with 'images:' prefix..."
            
            if [[ ! "$image_name" =~ ^images: ]]; then
                local image_with_prefix="images:$image_name"
                if lxc launch $type_flag "$image_with_prefix" "$container_name" 2>&1 | tee /tmp/lxc_launch.log; then
                    launch_success=true
                fi
            fi
        fi
        
        # Approach 3: Try to find similar image
        if [[ "$launch_success" == false ]]; then
            print_color "$YELLOW" "🔄 Attempt 3: Searching for similar image..."
            
            # Extract base name
            local base_name=$(echo "$image_name" | awk -F'/' '{print $NF}' | awk -F':' '{print $1}')
            
            # Search in available remotes
            for remote in "images" "ubuntu" "debian"; do
                print_color "$BLUE" "   Searching in remote: $remote"
                local found_image=$(lxc image list "$remote:" 2>/dev/null | grep -i "$base_name" | head -1 | awk -F'|' '{print $2}' | xargs)
                
                if [[ -n "$found_image" ]]; then
                    print_color "$GREEN" "   ✅ Found: $remote:$found_image"
                    if lxc launch $type_flag "$remote:$found_image" "$container_name" 2>&1 | tee /tmp/lxc_launch.log; then
                        launch_success=true
                        break
                    fi
                fi
            done
        fi
    fi
    
    if [[ "$launch_success" == false ]]; then
        print_color "$RED" "❌ Failed to create container!"
        echo
        print_color "$YELLOW" "💡 Troubleshooting tips:"
        echo "1. Check if LXD is initialized: sudo lxd init --auto"
        echo "2. List available images: lxc image list images:"
        echo "3. Try a different image name"
        echo "4. Check internet connection"
        read -p "⏎ Press Enter to continue..."
        return
    fi
    
    # Set resource limits
    print_color "$BLUE" "⚙️  Configuring resources..."
    
    # Set CPU
    if lxc config set "$container_name" limits.cpu="$cpu_count" 2>/dev/null; then
        print_color "$GREEN" "✅ CPU set to: $cpu_count cores"
    else
        print_color "$YELLOW" "⚠️  Could not set CPU limit"
    fi
    
    # Set Memory
    if lxc config set "$container_name" limits.memory="$memory" 2>/dev/null; then
        print_color "$GREEN" "✅ Memory set to: $memory"
    else
        print_color "$YELLOW" "⚠️  Could not set memory limit"
    fi
    
    # Wait for container to be ready
    print_color "$BLUE" "⏳ Waiting for container to initialize..."
    sleep 8
    
    # Show container info
    echo
    print_color "$CYAN" "📊 Container Information:"
    echo "──────────────────────────────────────"
    lxc list "$container_name"
    
    # Get IP address
    local container_ip=$(lxc list "$container_name" -c 4 --format csv | head -1)
    
    echo
    print_color "$GREEN" "🎉 Container '$container_name' created successfully!"
    
    if [[ -n "$container_ip" && "$container_ip" != "-" ]]; then
        print_color "$BLUE" "🌐 IP Address: $container_ip"
        
        # Show connection info
        echo
        print_color "$YELLOW" "🔗 Connection Information:"
        
        # Determine OS type for default username
        local default_user=""
        if [[ "$image_name" =~ ubuntu ]]; then
            default_user="ubuntu"
        elif [[ "$image_name" =~ debian ]]; then
            default_user="debian"
        elif [[ "$image_name" =~ centos|rocky|alma|fedora ]]; then
            default_user="root"
        fi
        
        if [[ -n "$default_user" ]]; then
            echo "  SSH: ssh $default_user@$container_ip"
            echo "  Username: $default_user"
            
            if [[ "$default_user" == "root" ]]; then
                echo "  Password: Set during first boot or use SSH keys"
            else
                echo "  Password: No password by default (use SSH keys)"
            fi
        fi
    fi
    
    # Offer to start shell
    echo
    read -p "💻 Open shell in container? (y/N): " open_shell
    if [[ "$open_shell" =~ ^[Yy]$ ]]; then
        echo "📝 Type 'exit' to return to menu"
        lxc exec "$container_name" -- /bin/bash || lxc exec "$container_name" -- /bin/sh
    fi
    
    read -p "⏎ Press Enter to continue..."
}

# Function to list containers
list_containers() {
    print_header
    print_color "$CYAN" "📋 Container List"
    echo "══════════════════════════════════════════════════════"
    echo
    
    if ! command -v lxc &> /dev/null; then
        print_color "$RED" "❌ LXC is not installed!"
        read -p "⏎ Press Enter to continue..."
        return
    fi
    
    # List all containers with formatting
    if ! lxc list; then
        print_color "$YELLOW" "⚠️  Could not list containers. Is LXD running?"
        echo "Try: sudo systemctl start snap.lxd.daemon"
    fi
    
    echo
    print_color "$YELLOW" "📊 Legend:"
    echo "  🟢 RUNNING - Container is active"
    echo "  🔴 STOPPED - Container is not running"
    echo "  ⚪ FROZEN  - Container is paused"
    echo "  🟡 ERROR   - Container has issues"
    
    read -p "⏎ Press Enter to continue..."
}

# Function to manage containers
manage_container() {
    print_header
    print_color "$CYAN" "⚙️  Container Management"
    echo "══════════════════════════════════════════════════════"
    echo
    
    if ! command -v lxc &> /dev/null; then
        print_color "$RED" "❌ LXC is not installed!"
        read -p "⏎ Press Enter to continue..."
        return
    fi
    
    # Get container list
    local containers=$(lxc list -c n --format csv 2>/dev/null)
    if [[ -z "$containers" ]]; then
        print_color "$YELLOW" "📭 No containers found!"
        read -p "⏎ Press Enter to continue..."
        return
    fi
    
    # Display containers
    print_color "$BLUE" "📋 Available Containers:"
    echo
    local i=1
    declare -A container_map
    for container in $containers; do
        container_map[$i]=$container
        local status=$(lxc list $container -c s --format csv 2>/dev/null || echo "UNKNOWN")
        local status_icon="❓"
        [[ "$status" == "RUNNING" ]] && status_icon="🟢"
        [[ "$status" == "STOPPED" ]] && status_icon="🔴"
        [[ "$status" == "FROZEN" ]] && status_icon="⚪"
        echo "  $i) $status_icon $container ($status)"
        ((i++))
    done
    
    echo
    read -p "🎯 Select container number: " container_num
    
    if [[ -z "${container_map[$container_num]}" ]]; then
        print_color "$RED" "❌ Invalid selection!"
        read -p "⏎ Press Enter to continue..."
        return
    fi
    
    local container_name=${container_map[$container_num]}
    container_management_menu "$container_name"
}

# Container management sub-menu
container_management_menu() {
    local container_name=$1
    
    while true; do
        print_header
        print_color "$CYAN" "⚙️  Managing: $container_name"
        
        # Get container status
        local container_status=$(lxc list "$container_name" -c s --format csv 2>/dev/null || echo "UNKNOWN")
        local container_ip=$(lxc list "$container_name" -c 4 --format csv 2>/dev/null | head -1)
        
        print_color "$BLUE" "📊 Status: $container_status"
        if [[ -n "$container_ip" && "$container_ip" != "-" ]]; then
            print_color "$GREEN" "🌐 IP: $container_ip"
        fi
        echo "══════════════════════════════════════════════════════"
        echo
        
        print_color "$YELLOW" "📋 Operations:"
        echo "  1) ▶️  Start Container"
        echo "  2) ⏹️  Stop Container"
        echo "  3) 🔄 Restart Container"
        echo "  4) ⏸️  Pause/Freeze"
        echo "  5) ⏯️  Resume/Unfreeze"
        echo "  6) 💻 Open Shell"
        echo "  7) 📊 Show Info"
        echo "  8) 📝 View Logs"
        echo "  9) ⚙️  Configure Resources"
        echo "  10) 📦 Take Snapshot"
        echo "  11) 🗑️  Delete Container"
        echo "  0) ↩️  Back"
        echo
        
        read -p "🎯 Select operation: " operation
        
        case $operation in
            1)
                print_color "$GREEN" "▶️  Starting container..."
                if lxc start "$container_name"; then
                    print_color "$GREEN" "✅ Container started!"
                else
                    print_color "$RED" "❌ Failed to start container"
                fi
                sleep 2
                ;;
            2)
                print_color "$YELLOW" "⏹️  Stopping container..."
                if lxc stop "$container_name"; then
                    print_color "$GREEN" "✅ Container stopped!"
                else
                    print_color "$RED" "❌ Failed to stop container"
                fi
                sleep 2
                ;;
            3)
                print_color "$BLUE" "🔄 Restarting container..."
                if lxc restart "$container_name"; then
                    print_color "$GREEN" "✅ Container restarted!"
                else
                    print_color "$RED" "❌ Failed to restart container"
                fi
                sleep 2
                ;;
            4)
                print_color "$PURPLE" "⏸️  Freezing container..."
                if lxc freeze "$container_name"; then
                    print_color "$GREEN" "✅ Container frozen!"
                else
                    print_color "$RED" "❌ Failed to freeze container"
                fi
                sleep 2
                ;;
            5)
                print_color "$PURPLE" "⏯️  Unfreezing container..."
                if lxc unfreeze "$container_name"; then
                    print_color "$GREEN" "✅ Container unfrozen!"
                else
                    print_color "$RED" "❌ Failed to unfreeze container"
                fi
                sleep 2
                ;;
            6)
                print_color "$CYAN" "💻 Opening shell..."
                echo "📝 Type 'exit' to return to menu"
                if ! lxc exec "$container_name" -- /bin/bash; then
                    print_color "$YELLOW" "⚠️  Trying /bin/sh instead..."
                    lxc exec "$container_name" -- /bin/sh
                fi
                ;;
            7)
                print_color "$BLUE" "📊 Container Information:"
                lxc info "$container_name" || echo "Could not get container info"
                read -p "⏎ Press Enter to continue..."
                ;;
            8)
                print_color "$BLUE" "📝 Container Logs (last 50 lines):"
                lxc info "$container_name" --show-log | tail -50 || echo "Could not get logs"
                read -p "⏎ Press Enter to continue..."
                ;;
            9)
                configure_container "$container_name"
                ;;
            10)
                read -p "📸 Snapshot name: " snapshot_name
                if lxc snapshot "$container_name" "$snapshot_name"; then
                    print_color "$GREEN" "✅ Snapshot created: $snapshot_name"
                else
                    print_color "$RED" "❌ Failed to create snapshot"
                fi
                sleep 2
                ;;
            11)
                print_color "$RED" "⚠️  ⚠️  ⚠️  WARNING: This will permanently delete '$container_name'!"
                read -p "🗑️  Are you sure? (type 'DELETE' to confirm): " confirm
                if [[ "$confirm" == "DELETE" ]]; then
                    print_color "$RED" "🗑️  Deleting container..."
                    if lxc delete "$container_name" --force; then
                        print_color "$GREEN" "✅ Container deleted!"
                        read -p "⏎ Press Enter to continue..."
                        return
                    else
                        print_color "$RED" "❌ Failed to delete container"
                    fi
                else
                    print_color "$YELLOW" "⚠️  Deletion cancelled"
                fi
                sleep 2
                ;;
            0)
                return
                ;;
            *)
                print_color "$RED" "❌ Invalid operation!"
                sleep 1
                ;;
        esac
    done
}

# Function to configure container resources
configure_container() {
    local container_name=$1
    
    while true; do
        print_header
        print_color "$CYAN" "⚙️  Configuring: $container_name"
        echo "══════════════════════════════════════════════════════"
        echo
        
        print_color "$YELLOW" "📋 Resource Configuration:"
        echo "  1) ⚡ Set CPU Limits"
        echo "  2) 🧠 Set Memory Limits"
        echo "  3) 💾 Set Disk Limits"
        echo "  4) 🌐 Network Settings"
        echo "  5) 👁️  View Current Configuration"
        echo "  0) ↩️  Back"
        echo
        
        read -p "🎯 Select option: " config_opt
        
        case $config_opt in
            1)
                read -p "⚡ Enter CPU limit (e.g., 2 or 0-4): " cpu_limit
                if lxc config set "$container_name" limits.cpu="$cpu_limit"; then
                    print_color "$GREEN" "✅ CPU limit set to: $cpu_limit"
                else
                    print_color "$RED" "❌ Failed to set CPU limit"
                fi
                ;;
            2)
                read -p "🧠 Enter memory limit (e.g., 2GB or 512MB): " mem_limit
                if lxc config set "$container_name" limits.memory="$mem_limit"; then
                    print_color "$GREEN" "✅ Memory limit set to: $mem_limit"
                else
                    print_color "$RED" "❌ Failed to set memory limit"
                fi
                ;;
            3)
                read -p "💾 Enter disk limit (e.g., 20GB): " disk_limit
                if lxc config device set "$container_name" root size="$disk_limit"; then
                    print_color "$GREEN" "✅ Disk limit set to: $disk_limit"
                else
                    print_color "$RED" "❌ Failed to set disk limit"
                fi
                ;;
            4)
                echo "🌐 Available networks:"
                lxc network list || echo "Could not list networks"
                read -p "Network name to attach (default: lxdbr0): " net_name
                net_name=${net_name:-lxdbr0}
                if lxc network attach "$net_name" "$container_name" eth0; then
                    print_color "$GREEN" "✅ Attached to network: $net_name"
                else
                    print_color "$RED" "❌ Failed to attach network"
                fi
                ;;
            5)
                print_color "$BLUE" "👁️  Current Configuration:"
                lxc config show "$container_name" || echo "Could not get configuration"
                ;;
            0)
                return
                ;;
            *)
                print_color "$RED" "❌ Invalid option!"
                ;;
        esac
        
        read -p "⏎ Press Enter to continue..."
    done
}

# Function to show system info
show_system_info() {
    print_header
    print_color "$CYAN" "📊 System Information"
    echo "══════════════════════════════════════════════════════"
    echo
    
    # LXC/LXD Info
    print_color "$YELLOW" "🚀 LXC/LXD Information:"
    echo "──────────────────────────────────────"
    if command -v lxc &> /dev/null; then
        echo -n "📦 LXC Version: "
        lxc version 2>/dev/null || echo "Unknown"
        
        # Container count
        local container_count=$(lxc list --format csv 2>/dev/null | wc -l)
        echo "📦 Containers: $container_count"
        
        # Storage pools
        echo "💾 Storage Pools:"
        lxc storage list 2>/dev/null | head -5 || echo "  Not available"
        
        # Networks
        echo "🌐 Networks:"
        lxc network list 2>/dev/null | head -5 || echo "  Not available"
    else
        echo "❌ LXC not installed"
    fi
    
    # System Info
    echo
    print_color "$YELLOW" "💻 System Information:"
    echo "──────────────────────────────────────"
    
    # OS info
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "🏷️  OS: $PRETTY_NAME"
    fi
    
    # Kernel
    echo "🐧 Kernel: $(uname -r)"
    
    # CPU
    echo "⚡ CPU: $(nproc) cores"
    echo "💾 Memory: $(free -h | awk '/^Mem:/ {print $2}') total"
    echo "💿 Disk: $(df -h / | awk 'NR==2 {print $4}') free"
    
    echo
    print_color "$CYAN" "🔧 Quick Commands:"
    echo "  lxc list                   # List all containers"
    echo "  lxc image list images:     # List available images"
    echo "  sudo lxd init --auto       # Initialize LXD"
    echo "  sudo systemctl restart snap.lxd.daemon  # Restart LXD"
    
    read -p "⏎ Press Enter to continue..."
}

# Function to refresh images
refresh_images() {
    print_header
    print_color "$CYAN" "🔄 Refreshing Available Images..."
    echo "══════════════════════════════════════════════════════"
    echo
    
    detect_available_images
    
    print_color "$GREEN" "✅ Image list refreshed!"
    read -p "⏎ Press Enter to continue..."
}

# Function to show image management
image_management() {
    while true; do
        print_header
        print_color "$CYAN" "📦 Image Management"
        echo "══════════════════════════════════════════════════════"
        echo
        
        print_color "$YELLOW" "📋 Operations:"
        echo "  1) 🔍 List Available Images"
        echo "  2) 🔄 Refresh Image List"
        echo "  3) 🔎 Search Images"
        echo "  4) 📥 Import Custom Image"
        echo "  0) ↩️  Back"
        echo
        
        read -p "🎯 Select option: " choice
        
        case $choice in
            1)
                detect_available_images
                show_image_menu
                read -p "⏎ Press Enter to continue..."
                ;;
            2)
                refresh_images
                ;;
            3)
                search_images
                ;;
            4)
                print_color "$BLUE" "📥 Import Custom Image"
                read -p "Enter image URL or local path: " image_url
                if [[ -n "$image_url" ]]; then
                    read -p "Enter alias for image: " image_alias
                    if lxc image import "$image_url" --alias "$image_alias"; then
                        print_color "$GREEN" "✅ Image imported as: $image_alias"
                    else
                        print_color "$RED" "❌ Failed to import image"
                    fi
                fi
                read -p "⏎ Press Enter to continue..."
                ;;
            0)
                return
                ;;
            *)
                print_color "$RED" "❌ Invalid option!"
                sleep 1
                ;;
        esac
    done
}

# Main menu
main_menu() {
    while true; do
        print_header
        
        # Get container count
        local container_count=0
        if command -v lxc &> /dev/null; then
            container_count=$(lxc list --format csv 2>/dev/null | wc -l)
        fi
        
        print_color "$GREEN" "🏠 Main Menu"
        print_color "$BLUE" "📦 Active Containers: $container_count"
        echo "══════════════════════════════════════════════════════"
        echo
        
        echo "  1) 🚀 Create New Container"
        echo "  2) 📋 List Containers"
        echo "  3) ⚙️  Manage Container"
        echo "  4) 📦 Image Management"
        echo "  5) 🔧 Check Installation"
        echo "  6) 📊 System Information"
        echo "  7) ⚡ Install Dependencies"
        echo "  0) 👋 Exit"
        echo
        
        read -p "🎯 Select option: " choice
        
        case $choice in
            1) create_container ;;
            2) list_containers ;;
            3) manage_container ;;
            4) image_management ;;
            5) check_installation ;;
            6) show_system_info ;;
            7) install_dependencies ;;
            0)
                print_header
                print_color "$GREEN" "👋 Goodbye! Happy containerizing! 🐳"
                echo
                exit 0
                ;;
            *)
                print_color "$RED" "❌ Invalid option!"
                sleep 1
                ;;
        esac
    done
}

# Check if LXC/LXD is ready
check_system_ready() {
    if ! command -v lxc &> /dev/null; then
        print_header
        print_color "$YELLOW" "⚠️  LXC/LXD Not Installed"
        echo "══════════════════════════════════════════════════════"
        echo
        print_color "$CYAN" "This script requires LXC/LXD to be installed."
        echo "Would you like to install it now?"
        echo
        
        read -p "📦 Install dependencies? (Y/n): " install_choice
        install_choice=${install_choice:-Y}
        
        if [[ "$install_choice" =~ ^[Yy]$ ]]; then
            install_dependencies
        else
            print_color "$YELLOW" "⚠️  Please install LXC/LXD manually first."
            echo "Run option 7 from the main menu later."
            sleep 2
        fi
    elif ! groups $USER | grep -q '\blxd\b'; then
        print_header
        print_color "$YELLOW" "⚠️  User Not in LXD Group"
        echo "══════════════════════════════════════════════════════"
        echo
        print_color "$CYAN" "Your user is not in the 'lxd' group."
        echo "This is required to manage containers."
        echo
        print_color "$GREEN" "💡 Solution:"
        echo "  1. Run: sudo usermod -aG lxd $USER"
        echo "  2. Log out and log back in"
        echo "  3. Run this script again"
        echo
        read -p "⏎ Press Enter to continue..."
        exit 0
    fi
}

# Main function
main() {
    # Check if in terminal
    if [[ ! -t 0 ]]; then
        print_color "$RED" "❌ This script must be run in a terminal!"
        exit 1
    fi
    
    # Welcome
    print_header
    print_color "$GREEN" "🌟 Welcome to LXC/LXD Container Manager"
    print_color "$CYAN" "📦 Auto Image Detection | Easy Container Management"
    echo
    
    # Check system
    check_system_ready
    
    # Initial image detection
    detect_available_images
    
    # Start main menu
    main_menu
}

# Run main
main
