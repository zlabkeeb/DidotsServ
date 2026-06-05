#!/bin/bash

# GenieACS Installer Script
# Description: Interactive installer for GenieACS with Docker
# Repository : https://github.com/zlabkeeb/DidotsServ

# ============================================================
# CONFIGURATION - GitHub Repository
# ============================================================
GITHUB_USER="zlabkeeb"
GITHUB_REPO="DidotsServ"
GITHUB_BRANCH="main"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}"
DB_URL="${GITHUB_RAW_BASE}/db"

INSTALLER_VERSION="5.5"

# L2TP IP Pool Configuration
L2TP_SERVER_IP="192.99.100.1"
L2TP_IP_POOL_START="192.99.100.2"
L2TP_IP_POOL_BASE="192.99.100"
L2TP_IP_POOL_OFFSET=2   # akun1=.2, akun2=.3, dst
L2TP_CONFIG_DIR="/etc/l2tp-server"
L2TP_ACCOUNTS_FILE="${L2TP_CONFIG_DIR}/accounts.conf"
L2TP_ROUTES_FILE="${L2TP_CONFIG_DIR}/routes.conf"

# Detect system language
LANG_CODE="${LANG:0:2}"

# Language strings
case $LANG_CODE in
    id)
        MSG_TITLE="Interactive Installer"
        MSG_CHOOSE="Pilih menu"
        MSG_BACK="Kembali"
        MSG_EXIT="Keluar"
        MSG_SUCCESS="SUKSES"
        MSG_ERROR="ERROR"
        MSG_WARNING="PERINGATAN"
        MSG_INFO="INFO"
        MSG_PRESS_ENTER="Tekan Enter untuk melanjutkan..."
        MSG_INVALID_CHOICE="Pilihan tidak valid!"
        MSG_THANK_YOU="Terima kasih telah menggunakan Installer!"
        MSG_PROCESS_COMPLETE="Proses selesai!"
        MSG_PROCESS_FAILED="Proses gagal! Silakan periksa error di atas."

        MENU_DOCKER="Docker"
        MENU_GENIEACS="GenieACS"
        MENU_PANEL="GenieACS Panel"
        MENU_CUSTOMER_PORTAL="Customer Portal"
        MENU_L2TP="L2TP Server (BETA)"
        MENU_STATUS="Lihat Status"
        MENU_EXIT="Keluar"

        SUBMENU_INSTALL_DOCKER="Install Docker dan Docker Compose"
        SUBMENU_UNINSTALL_DOCKER="Uninstall Docker dan Docker Compose"
        SUBMENU_INSTALL_GENIEACS="Install GenieACS"
        SUBMENU_CONFIG_GENIEACS="Konfigurasi DB GenieACS"
        SUBMENU_UNINSTALL_GENIEACS="Uninstall GenieACS"
        SUBMENU_INSTALL_PANEL="Install GenieACS Panel"
        SUBMENU_UNINSTALL_PANEL="Uninstall GenieACS Panel"
        SUBMENU_INSTALL_CUSTOMER_PORTAL="Install Customer Portal"
        SUBMENU_UNINSTALL_CUSTOMER_PORTAL="Uninstall Customer Portal"
        SUBMENU_INSTALL_L2TP="Install L2TP Server"
        SUBMENU_MANAGE_L2TP_ACCOUNTS="Kelola Akun L2TP"
        SUBMENU_MANAGE_L2TP_ROUTES="Kelola IP Route"
        SUBMENU_SHOW_L2TP_STATUS="Status L2TP"
        SUBMENU_UNINSTALL_L2TP="Uninstall L2TP Server"
        ;;
    *)
        MSG_TITLE="Interactive Installer"
        MSG_CHOOSE="Choose menu"
        MSG_BACK="Back"
        MSG_EXIT="Exit"
        MSG_SUCCESS="SUCCESS"
        MSG_ERROR="ERROR"
        MSG_WARNING="WARNING"
        MSG_INFO="INFO"
        MSG_PRESS_ENTER="Press Enter to continue..."
        MSG_INVALID_CHOICE="Invalid choice!"
        MSG_THANK_YOU="Thank you for using Installer!"
        MSG_PROCESS_COMPLETE="Process completed!"
        MSG_PROCESS_FAILED="Process failed! Please check the error above."

        MENU_DOCKER="Docker"
        MENU_GENIEACS="GenieACS"
        MENU_PANEL="GenieACS Panel"
        MENU_CUSTOMER_PORTAL="Customer Portal"
        MENU_L2TP="L2TP Server (BETA)"
        MENU_STATUS="View Status"
        MENU_EXIT="Exit"

        SUBMENU_INSTALL_DOCKER="Install Docker and Docker Compose"
        SUBMENU_UNINSTALL_DOCKER="Uninstall Docker and Docker Compose"
        SUBMENU_INSTALL_GENIEACS="Install GenieACS"
        SUBMENU_CONFIG_GENIEACS="Configure GenieACS Database"
        SUBMENU_UNINSTALL_GENIEACS="Uninstall GenieACS"
        SUBMENU_INSTALL_PANEL="Install GenieACS Panel"
        SUBMENU_UNINSTALL_PANEL="Uninstall GenieACS Panel"
        SUBMENU_INSTALL_CUSTOMER_PORTAL="Install Customer Portal"
        SUBMENU_UNINSTALL_CUSTOMER_PORTAL="Uninstall Customer Portal"
        SUBMENU_INSTALL_L2TP="Install L2TP Server"
        SUBMENU_MANAGE_L2TP_ACCOUNTS="Manage L2TP Accounts"
        SUBMENU_MANAGE_L2TP_ROUTES="Manage IP Routes"
        SUBMENU_SHOW_L2TP_STATUS="L2TP Status"
        SUBMENU_UNINSTALL_L2TP="Uninstall L2TP Server"
        ;;
esac

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() { echo -e "${GREEN}[${MSG_SUCCESS}]${NC} $1"; }
print_error()   { echo -e "${RED}[${MSG_ERROR}]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[${MSG_WARNING}]${NC} $1"; }
print_info()    { echo -e "${BLUE}[${MSG_INFO}]${NC} $1"; }
print_beta()    { echo -e "${CYAN}[BETA]${NC} $1"; }

get_server_ip() { hostname -I | awk '{print $1}'; }

detect_architecture() {
    case $(uname -m) in
        x86_64)        echo "amd64";;
        aarch64|arm64) echo "arm64";;
        armv7l)        echo "armhf";;
        *)             echo "unknown";;
    esac
}

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
        OS_CODENAME=$VERSION_CODENAME
        OS_PRETTY_NAME=$PRETTY_NAME

        if grep -qi microsoft /proc/version 2>/dev/null || grep -qi wsl /proc/version 2>/dev/null; then
            IS_WSL=true
        else
            IS_WSL=false
        fi

        [ -z "$OS_CODENAME" ] && OS_CODENAME=$(lsb_release -cs 2>/dev/null || echo "")

        if [ "$OS" = "debian" ] || [ "$OS" = "armbian" ] || [ "$OS" = "raspbian" ]; then
            DOCKER_BASE_OS="debian"
            [ -z "$OS_CODENAME" ] && OS_CODENAME="bookworm"
        elif [ "$OS" = "ubuntu" ] || [ "$OS" = "pop" ] || [ "$OS" = "linuxmint" ]; then
            DOCKER_BASE_OS="ubuntu"
            [ -z "$OS_CODENAME" ] && OS_CODENAME="jammy"
        else
            if [ -f /etc/debian_version ]; then
                DOCKER_BASE_OS="debian"
                [ -z "$OS_CODENAME" ] && OS_CODENAME="bookworm"
            else
                DOCKER_BASE_OS="ubuntu"
                [ -z "$OS_CODENAME" ] && OS_CODENAME="jammy"
            fi
        fi

        echo "$OS:$OS_VERSION:$OS_CODENAME:$IS_WSL:$DOCKER_BASE_OS"
    else
        echo "unknown:unknown:unknown:false:ubuntu"
    fi
}

wait_for_dpkg_lock() {
    local max_wait=300
    local waited=0

    while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || fuser /var/lib/dpkg/lock >/dev/null 2>&1; do
        [ $waited -eq 0 ] && { [ "$LANG_CODE" = "id" ] && print_warning "Menunggu proses apt lain selesai..." || print_warning "Waiting for other apt processes to finish..."; }
        sleep 2
        waited=$((waited + 2))
        [ $waited -ge $max_wait ] && { [ "$LANG_CODE" = "id" ] && print_error "Timeout menunggu dpkg lock" || print_error "Timeout waiting for dpkg lock"; return 1; }
        [ $((waited % 10)) -eq 0 ] && { [ "$LANG_CODE" = "id" ] && echo "  Menunggu ${waited} detik..." || echo "  Waiting ${waited} seconds..."; }
    done

    [ $waited -gt 0 ] && { [ "$LANG_CODE" = "id" ] && print_success "Proses apt lain selesai" || print_success "Other apt processes finished"; sleep 2; }
    return 0
}

kill_apt_processes() {
    if [ "$LANG_CODE" = "id" ]; then
        print_warning "Mendeteksi proses apt yang berjalan..."
        read -p "Paksa hentikan proses apt? (y/n): " confirm
    else
        print_warning "Detected running apt processes..."
        read -p "Force kill apt processes? (y/n): " confirm
    fi

    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        [ "$LANG_CODE" = "id" ] && print_info "Menghentikan proses apt..." || print_info "Killing apt processes..."
        killall apt-get 2>/dev/null; killall apt 2>/dev/null; killall dpkg 2>/dev/null
        rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock 2>/dev/null
        dpkg --configure -a 2>/dev/null
        sleep 2
        [ "$LANG_CODE" = "id" ] && print_success "Proses apt dihentikan" || print_success "Apt processes killed"
        return 0
    else
        return 1
    fi
}

safe_apt_get() {
    local cmd="$@"
    local max_retries=3
    local retry=0

    while [ $retry -lt $max_retries ]; do
        if wait_for_dpkg_lock; then
            eval "$cmd" && return 0
            retry=$((retry + 1))
            [ $retry -lt $max_retries ] && { [ "$LANG_CODE" = "id" ] && print_warning "Percobaan ke-$retry gagal, mencoba lagi..." || print_warning "Attempt $retry failed, retrying..."; sleep 3; }
        else
            kill_apt_processes || return 1
        fi
    done
    return 1
}

check_ufw_status() {
    if command -v ufw &> /dev/null; then
        ufw status | grep -q "Status: active" && echo "active" || echo "inactive"
    else
        echo "not_installed"
    fi
}

configure_firewall() {
    local ports=("$@")
    local ufw_status=$(check_ufw_status)

    echo ""
    [ "$LANG_CODE" = "id" ] && print_info "Memeriksa status firewall..." || print_info "Checking firewall status..."

    case $ufw_status in
        active)
            if [ "$LANG_CODE" = "id" ]; then
                print_warning "UFW Firewall terdeteksi AKTIF"
                print_info "Port yang perlu dibuka: ${ports[*]}"
                read -p "Buka port secara otomatis? (y/n): " confirm
            else
                print_warning "UFW Firewall detected ACTIVE"
                print_info "Ports that need to be opened: ${ports[*]}"
                read -p "Open ports automatically? (y/n): " confirm
            fi

            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                [ "$LANG_CODE" = "id" ] && print_info "Membuka port di firewall..." || print_info "Opening ports in firewall..."
                for port in "${ports[@]}"; do
                    ufw allow "$port" &> /dev/null \
                        && { [ "$LANG_CODE" = "id" ] && print_success "Port $port berhasil dibuka" || print_success "Port $port opened successfully"; } \
                        || { [ "$LANG_CODE" = "id" ] && print_error "Gagal membuka port $port" || print_error "Failed to open port $port"; }
                done
                [ "$LANG_CODE" = "id" ] && print_info "Reload UFW..." || print_info "Reloading UFW..."
                ufw reload &> /dev/null
                [ "$LANG_CODE" = "id" ] && print_success "Konfigurasi firewall selesai!" || print_success "Firewall configuration completed!"
            else
                [ "$LANG_CODE" = "id" ] && print_warning "Port tidak dibuka otomatis" || print_warning "Ports not opened automatically"
                [ "$LANG_CODE" = "id" ] && print_info "Anda perlu membuka port berikut secara manual:" || print_info "You need to manually open the following ports:"
                for port in "${ports[@]}"; do echo "  sudo ufw allow $port"; done
            fi
            ;;
        inactive)
            [ "$LANG_CODE" = "id" ] && print_info "UFW Firewall: Nonaktif - Melanjutkan instalasi..." || print_info "UFW Firewall: Inactive - Continuing installation..."
            ;;
        not_installed)
            [ "$LANG_CODE" = "id" ] && print_info "UFW tidak terinstall - Melanjutkan instalasi..." || print_info "UFW not installed - Continuing installation..."
            ;;
    esac
    echo ""
}

show_firewall_status() {
    local ufw_status=$(check_ufw_status)
    case $ufw_status in
        active)
            [ "$LANG_CODE" = "id" ] && print_success "UFW Firewall: Aktif" || print_success "UFW Firewall: Active"
            echo ""
            ufw status numbered
            ;;
        inactive)
            [ "$LANG_CODE" = "id" ] && print_warning "UFW Firewall: Nonaktif" || print_warning "UFW Firewall: Inactive"
            ;;
        not_installed)
            [ "$LANG_CODE" = "id" ] && print_info "UFW Firewall: Tidak Terinstall" || print_info "UFW Firewall: Not Installed"
            ;;
    esac
}

# ============================================================
# Animation and loading functions
# ============================================================
show_spinner() {
    local pid=$1
    local message=$2
    local delay=0.1
    local spinstr='|/-\'

    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c] %s" "$spinstr" "$message"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

show_progress_bar() {
    local duration=$1
    local message=$2
    local bar_length=40

    printf "\n%s\n" "$message"
    for ((i=0; i<=duration; i++)); do
        local progress=$((i * bar_length / duration))
        local percentage=$((i * 100 / duration))
        printf "\r["
        for ((j=0; j<progress; j++)); do printf "="; done
        if [ $i -lt $duration ]; then
            printf ">"
            for ((j=progress+1; j<bar_length; j++)); do printf " "; done
        else
            for ((j=progress; j<bar_length; j++)); do printf "="; done
        fi
        printf "] %d%%" $percentage
        sleep 0.1
    done
    printf "\n\n"
}

animated_text() {
    local text="$1"
    local delay="${2:-0.03}"
    for ((i=0; i<${#text}; i++)); do
        printf "${text:$i:1}"
        sleep "$delay"
    done
    printf "\n"
}

show_installation_header() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                    GenieACS Installer                    ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

loading_animation() {
    local message="$1"
    local duration="${2:-3}"
    printf "%s " "$message"
    for ((i=0; i<duration; i++)); do printf "."; sleep 1; done
    printf " ✓\n"
}

show_system_info() {
    echo ""
    echo "========================================================="
    [ "$LANG_CODE" = "id" ] && echo "           INFORMASI SISTEM" || echo "           SYSTEM INFORMATION"
    echo "========================================================="

    ARCH=$(detect_architecture)
    OS_INFO=$(detect_os)
    IFS=':' read -r OS OS_VERSION OS_CODENAME IS_WSL DOCKER_BASE_OS <<< "$OS_INFO"

    print_info "OS: $OS $OS_VERSION ($OS_CODENAME)"
    [ "$LANG_CODE" = "id" ] && print_info "Arsitektur: $ARCH" || print_info "Architecture: $ARCH"
    [ "$LANG_CODE" = "id" ] && print_info "Kernel: $(uname -r)" || print_info "Kernel: $(uname -r)"
    [ "$IS_WSL" = "true" ] && { [ "$LANG_CODE" = "id" ] && print_warning "Environment: WSL (Windows Subsystem for Linux)" || print_warning "Environment: WSL (Windows Subsystem for Linux)"; }

    if [ "$DOCKER_BASE_OS" = "debian" ]; then
        [ "$LANG_CODE" = "id" ] && print_info "Docker Repository: Debian ($OS_CODENAME)" || print_info "Docker Repository: Debian ($OS_CODENAME)"
    else
        [ "$LANG_CODE" = "id" ] && print_info "Docker Repository: Ubuntu ($OS_CODENAME)" || print_info "Docker Repository: Ubuntu ($OS_CODENAME)"
    fi

    [ "$LANG_CODE" = "id" ] && print_info "IP Server: $(get_server_ip)" || print_info "Server IP: $(get_server_ip)"
    [ "$LANG_CODE" = "id" ] && print_info "Total RAM: $(get_total_ram) MB" || print_info "Total RAM: $(get_total_ram) MB"
    [ "$LANG_CODE" = "id" ] && print_info "RAM Tersedia: $(get_available_ram) MB" || print_info "Available RAM: $(get_available_ram) MB"

    echo "---------------------------------------------------------"
    show_firewall_status
    echo "========================================================="
    echo ""
}

check_system_compatibility() {
    ARCH=$(detect_architecture)
    OS_INFO=$(detect_os)
    IFS=':' read -r OS OS_VERSION OS_CODENAME IS_WSL DOCKER_BASE_OS <<< "$OS_INFO"

    [ "$ARCH" = "unknown" ] && { [ "$LANG_CODE" = "id" ] && print_error "Arsitektur sistem tidak didukung: $(uname -m)" || print_error "System architecture not supported: $(uname -m)"; return 1; }
    [ "$OS" = "unknown" ]   && { [ "$LANG_CODE" = "id" ] && print_error "Sistem operasi tidak dapat dideteksi" || print_error "Operating system cannot be detected"; return 1; }
    return 0
}

get_available_ram() { free -m | awk 'NR==2{print $7}'; }
get_total_ram()     { free -m | awk 'NR==2{print $2}'; }

choose_memory_limit() {
    local service_name=$1
    local auto_mode=${2:-false}
    TOTAL_RAM=$(get_total_ram)
    RAM_50=$((TOTAL_RAM * 50 / 100))

    if [ "$auto_mode" = "true" ]; then
        if [ $TOTAL_RAM -ge 4096 ]; then
            [ "$LANG_CODE" = "id" ] && print_info "RAM Sistem: ${TOTAL_RAM} MB - Menggunakan mode Unlimited" >&2 || print_info "System RAM: ${TOTAL_RAM} MB - Using Unlimited mode" >&2
            echo "unlimited"
        else
            [ "$LANG_CODE" = "id" ] && print_info "RAM Sistem: ${TOTAL_RAM} MB - Menggunakan limit 50% (${RAM_50} MB)" >&2 || print_info "System RAM: ${TOTAL_RAM} MB - Using 50% limit (${RAM_50} MB)" >&2
            echo $RAM_50
        fi
        return
    fi

    echo "" >&2
    if [ "$LANG_CODE" = "id" ]; then
        print_info "Total RAM Sistem: ${TOTAL_RAM} MB" >&2
        print_info "Pilih limit RAM untuk $service_name:" >&2
        echo "  [1] 50% dari total RAM (${RAM_50} MB)" >&2
        echo "  [2] Unlimited (Tidak ada limit)" >&2
        echo "" >&2
        read -p "Pilih 1 atau 2 (kosongkan untuk otomatis): " ram_choice
    else
        print_info "Total System RAM: ${TOTAL_RAM} MB" >&2
        print_info "Choose RAM limit for $service_name:" >&2
        echo "  [1] 50% of total RAM (${RAM_50} MB)" >&2
        echo "  [2] Unlimited (No limit)" >&2
        echo "" >&2
        read -p "Choose 1 or 2 (leave empty for auto): " ram_choice
    fi

    if [ -z "$ram_choice" ]; then
        if [ $TOTAL_RAM -ge 4096 ]; then
            [ "$LANG_CODE" = "id" ] && print_info "Otomatis: Menggunakan Unlimited (RAM ≥ 4GB)" >&2 || print_info "Auto: Using Unlimited (RAM ≥ 4GB)" >&2
            echo "unlimited"
        else
            [ "$LANG_CODE" = "id" ] && print_info "Otomatis: Menggunakan 50% RAM (${RAM_50} MB)" >&2 || print_info "Auto: Using 50% RAM (${RAM_50} MB)" >&2
            echo $RAM_50
        fi
        return
    fi

    case $ram_choice in
        1) echo $RAM_50;;
        2) echo "unlimited";;
        *) [ "$LANG_CODE" = "id" ] && print_warning "Pilihan tidak valid, menggunakan mode otomatis" >&2 || print_warning "Invalid choice, using auto mode" >&2; choose_memory_limit "$service_name" true;;
    esac
}

# ============================================================
# INSTALL DOCKER
# ============================================================
install_docker() {
    show_installation_header
    [ "$LANG_CODE" = "id" ] && animated_text "🐳 Memulai instalasi Docker dan Docker Compose..." 0.05 || animated_text "🐳 Starting Docker and Docker Compose installation..." 0.05

    show_system_info
    check_system_compatibility || { [ "$LANG_CODE" = "id" ] && print_error "Sistem tidak kompatibel!" || print_error "System not compatible!"; return 1; }

    if command -v docker &> /dev/null; then
        [ "$LANG_CODE" = "id" ] && print_warning "Docker sudah terinstall!" || print_warning "Docker is already installed!"
        docker --version
        docker compose version &> /dev/null && return 0
    fi

    OS_INFO=$(detect_os)
    IFS=':' read -r OS OS_VERSION OS_CODENAME IS_WSL DOCKER_BASE_OS <<< "$OS_INFO"
    ARCH=$(detect_architecture)

    echo ""
    [ "$LANG_CODE" = "id" ] && print_info "Deteksi Sistem:" || print_info "System Detection:"
    echo "  - OS Base: $OS"
    echo "  - Codename: $OS_CODENAME"
    echo "  - Docker Repo: $DOCKER_BASE_OS"
    echo "  - Architecture: $ARCH"
    echo ""

    [ "$LANG_CODE" = "id" ] && loading_animation "📦 Mengupdate package list" || loading_animation "📦 Updating package list"
    safe_apt_get apt-get update || { [ "$LANG_CODE" = "id" ] && print_error "Gagal update package list" || print_error "Failed to update package list"; return 1; }

    [ "$LANG_CODE" = "id" ] && loading_animation "🔧 Menginstall prerequisites" || loading_animation "🔧 Installing prerequisites"
    safe_apt_get apt-get install -y ca-certificates curl gnupg lsb-release software-properties-common apt-transport-https || { [ "$LANG_CODE" = "id" ] && print_error "Gagal install prerequisites" || print_error "Failed to install prerequisites"; return 1; }

    [ "$LANG_CODE" = "id" ] && loading_animation "🔍 Memeriksa konfigurasi Docker yang ada" || loading_animation "🔍 Checking existing Docker configuration"

    if grep -Rq "download.docker.com" /etc/apt/ 2>/dev/null; then
        [ "$LANG_CODE" = "id" ] && print_warning "Ditemukan konfigurasi Docker lama, membersihkan..." || print_warning "Found old Docker configuration, cleaning..."
    fi

    rm -f /etc/apt/keyrings/docker.gpg /usr/share/keyrings/docker-archive-keyring.gpg \
          /etc/apt/sources.list.d/docker.list /etc/apt/sources.list.d/docker.list.save 2>/dev/null
    [ -f /etc/apt/sources.list ] && sed -i '/download.docker.com/d' /etc/apt/sources.list 2>/dev/null

    [ "$LANG_CODE" = "id" ] && loading_animation "🧹 Membersihkan cache APT" || loading_animation "🧹 Cleaning APT cache"
    apt-get clean 2>/dev/null || true
    apt-get autoclean 2>/dev/null || true

    [ "$LANG_CODE" = "id" ] && loading_animation "📋 Memperbarui daftar repository" || loading_animation "📋 Updating repository list"
    apt-get update 2>/dev/null || true

    [ "$LANG_CODE" = "id" ] && loading_animation "🔐 Menambahkan Docker GPG key" || loading_animation "🔐 Adding Docker GPG key"
    install -m 0755 -d /etc/apt/keyrings

    SYSTEM_ARCH=$(dpkg --print-architecture)
    SYSTEM_CODENAME=$(lsb_release -cs 2>/dev/null || echo "")

    if [ "$DOCKER_BASE_OS" = "debian" ]; then
        DOCKER_REPO_URL="https://download.docker.com/linux/debian"
        DOCKER_GPG_URL="https://download.docker.com/linux/debian/gpg"
    else
        DOCKER_REPO_URL="https://download.docker.com/linux/ubuntu"
        DOCKER_GPG_URL="https://download.docker.com/linux/ubuntu/gpg"
    fi

    [ "$LANG_CODE" = "id" ] && print_info "Menggunakan repository $DOCKER_BASE_OS untuk Docker..." || print_info "Using $DOCKER_BASE_OS repository for Docker..."

    curl -fsSL $DOCKER_GPG_URL | gpg --dearmor -o /etc/apt/keyrings/docker.gpg || { [ "$LANG_CODE" = "id" ] && print_error "Gagal menambahkan Docker GPG key" || print_error "Failed to add Docker GPG key"; return 1; }
    chmod a+r /etc/apt/keyrings/docker.gpg

    [ "$LANG_CODE" = "id" ] && loading_animation "📦 Menambahkan Docker repository ($DOCKER_BASE_OS ${SYSTEM_CODENAME})" || loading_animation "📦 Adding Docker repository ($DOCKER_BASE_OS ${SYSTEM_CODENAME})"
    echo "deb [arch=${SYSTEM_ARCH} signed-by=/etc/apt/keyrings/docker.gpg] ${DOCKER_REPO_URL} ${SYSTEM_CODENAME} stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    [ "$LANG_CODE" = "id" ] && loading_animation "🔄 Mengupdate package list dari repository Docker" || loading_animation "🔄 Updating package list from Docker repository"
    safe_apt_get apt-get update || { [ "$LANG_CODE" = "id" ] && print_error "Gagal update package list dari repository Docker" || print_error "Failed to update package list from Docker repository"; return 1; }

    [ "$LANG_CODE" = "id" ] && animated_text "🐳 Menginstall Docker..." 0.08 || animated_text "🐳 Installing Docker..." 0.08
    safe_apt_get apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || {
        [ "$LANG_CODE" = "id" ] && print_warning "Gagal install dengan plugin, mencoba tanpa plugin..." || print_warning "Failed to install with plugins, trying without plugins..."
        safe_apt_get apt-get install -y docker-ce docker-ce-cli containerd.io || { [ "$LANG_CODE" = "id" ] && print_error "Instalasi Docker gagal total" || print_error "Docker installation failed completely"; return 1; }
    }

    [ "$LANG_CODE" = "id" ] && loading_animation "⚡ Menjalankan Docker service" || loading_animation "⚡ Starting Docker service"
    if [ "$IS_WSL" = "true" ]; then
        [ "$LANG_CODE" = "id" ] && print_warning "WSL terdeteksi - menggunakan service start khusus..." || print_warning "WSL detected - using special service start..."
        service docker start 2>/dev/null || systemctl start docker 2>/dev/null
    else
        systemctl start docker && systemctl enable docker
    fi

    [ "$LANG_CODE" = "id" ] && show_progress_bar 20 "⏳ Menunggu Docker siap..." || show_progress_bar 20 "⏳ Waiting for Docker to be ready..."

    if docker --version; then
        [ "$LANG_CODE" = "id" ] && print_success "✅ Docker berhasil diinstall!" || print_success "✅ Docker installed successfully!"

        if docker compose version &> /dev/null; then
            [ "$LANG_CODE" = "id" ] && print_success "✅ Docker Compose plugin tersedia!" || print_success "✅ Docker Compose plugin available!"
            docker compose version
        else
            [ "$LANG_CODE" = "id" ] && print_warning "Docker Compose plugin tidak tersedia, menginstall standalone..." || print_warning "Docker Compose plugin not available, installing standalone..."
            [ "$LANG_CODE" = "id" ] && loading_animation "📦 Menginstall Docker Compose standalone" || loading_animation "📦 Installing Docker Compose standalone"
            COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
            curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
            ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
            docker-compose --version && { [ "$LANG_CODE" = "id" ] && print_success "✅ Docker Compose standalone berhasil diinstall!" || print_success "✅ Docker Compose standalone installed successfully!"; }
        fi

        echo ""
        echo "╔══════════════════════════════════════════════════════════╗"
        [ "$LANG_CODE" = "id" ] && echo "║                    INSTALASI SELESAI!                   ║" || echo "║                  INSTALLATION COMPLETE!                 ║"
        echo "║               Docker & Docker Compose                   ║"
        [ "$LANG_CODE" = "id" ] && echo "║                berhasil diinstall! 🐳                   ║" || echo "║              successfully installed! 🐳                 ║"
        echo "╚══════════════════════════════════════════════════════════╝"
        return 0
    else
        [ "$LANG_CODE" = "id" ] && print_error "❌ Instalasi Docker gagal diverifikasi" || print_error "❌ Docker installation verification failed"
        return 1
    fi
}

# ============================================================
# UNINSTALL DOCKER
# ============================================================
uninstall_docker() {
    echo ""
    if [ "$LANG_CODE" = "id" ]; then
        print_warning "PERINGATAN: Ini akan menghapus Docker, semua container, images, volumes, dan networks!"
        read -p "Apakah Anda yakin? (y/n): " confirm
    else
        print_warning "WARNING: This will remove Docker, all containers, images, volumes, and networks!"
        read -p "Are you sure? (y/n): " confirm
    fi

    [ "$confirm" != "y" ] && [ "$confirm" != "Y" ] && { [ "$LANG_CODE" = "id" ] && print_info "Uninstall dibatalkan" || print_info "Uninstall cancelled"; return 1; }

    if ! command -v docker &> /dev/null; then
        [ "$LANG_CODE" = "id" ] && print_warning "Docker tidak terinstall!" || print_warning "Docker is not installed!"
        return 0
    fi

    echo ""
    echo "========================================================="
    [ "$LANG_CODE" = "id" ] && print_info "Memulai proses uninstall Docker..." || print_info "Starting Docker uninstall process..."
    echo "========================================================="
    echo ""

    [ "$LANG_CODE" = "id" ] && print_info "Menghentikan semua container..." || print_info "Stopping all containers..."
    CONTAINERS=$(docker ps -aq 2>/dev/null)
    [ -n "$CONTAINERS" ] && docker stop $CONTAINERS 2>&1 | grep -v "No such container" || true

    [ "$LANG_CODE" = "id" ] && print_info "Menghapus semua container..." || print_info "Removing all containers..."
    CONTAINERS=$(docker ps -aq 2>/dev/null)
    [ -n "$CONTAINERS" ] && docker rm $CONTAINERS 2>&1 | grep -v "No such container" || true

    [ "$LANG_CODE" = "id" ] && print_info "Menghapus semua images..." || print_info "Removing all images..."
    IMAGES=$(docker images -aq 2>/dev/null)
    [ -n "$IMAGES" ] && docker rmi -f $IMAGES 2>&1 | grep -v "No such image" || true

    [ "$LANG_CODE" = "id" ] && print_info "Menghapus semua volumes..." || print_info "Removing all volumes..."
    VOLUMES=$(docker volume ls -q 2>/dev/null)
    [ -n "$VOLUMES" ] && docker volume rm $VOLUMES 2>&1 | grep -v "No such volume" || true

    [ "$LANG_CODE" = "id" ] && print_info "Menghapus semua networks..." || print_info "Removing all networks..."
    NETWORKS=$(docker network ls -q --filter type=custom 2>/dev/null)
    [ -n "$NETWORKS" ] && docker network rm $NETWORKS 2>&1 | grep -v "No such network\|cannot be removed" || true

    echo ""
    [ "$LANG_CODE" = "id" ] && print_info "Membersihkan sistem Docker..." || print_info "Pruning Docker system..."
    docker system prune -af --volumes

    OS_INFO=$(detect_os)
    IFS=':' read -r OS OS_VERSION OS_CODENAME IS_WSL DOCKER_BASE_OS <<< "$OS_INFO"

    [ "$LANG_CODE" = "id" ] && print_info "Menghentikan Docker service..." || print_info "Stopping Docker service..."
    if [ "$IS_WSL" = "true" ]; then
        service docker stop 2>/dev/null
    else
        systemctl stop docker 2>/dev/null; systemctl stop docker.socket 2>/dev/null
        systemctl disable docker 2>/dev/null; systemctl disable docker.socket 2>/dev/null
    fi

    [ "$LANG_CODE" = "id" ] && print_info "Menghapus Docker packages..." || print_info "Removing Docker packages..."
    safe_apt_get apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose || { [ "$LANG_CODE" = "id" ] && print_error "Gagal menghapus Docker packages" || print_error "Failed to remove Docker packages"; return 1; }

    [ "$LANG_CODE" = "id" ] && print_info "Menghapus direktori Docker..." || print_info "Removing Docker directories..."
    rm -rf /var/lib/docker /var/lib/containerd /etc/docker /etc/apt/keyrings/docker.gpg \
           /etc/apt/sources.list.d/docker.list /usr/local/bin/docker-compose /usr/bin/docker-compose

    [ "$LANG_CODE" = "id" ] && print_info "Membersihkan paket yang tidak digunakan..." || print_info "Cleaning up unused packages..."
    safe_apt_get apt-get autoremove -y
    safe_apt_get apt-get autoclean

    [ "$LANG_CODE" = "id" ] && print_success "Docker berhasil dihapus dari sistem!" || print_success "Docker successfully removed from system!"
    return 0
}

# ============================================================
# INSTALL GENIEACS
# ============================================================
install_genieacs() {
    show_installation_header
    [ "$LANG_CODE" = "id" ] && animated_text "🚀 Memulai instalasi GenieACS..." 0.05 || animated_text "🚀 Starting GenieACS installation..." 0.05

    if ! command -v docker &> /dev/null; then
        [ "$LANG_CODE" = "id" ] && print_error "Docker belum terinstall! Silakan install Docker terlebih dahulu" || print_error "Docker is not installed! Please install Docker first"
        return 1
    fi

    configure_firewall "3000/tcp" "7547/tcp" "7557/tcp" "7567/tcp"

    [ "$LANG_CODE" = "id" ] && loading_animation "📁 Menyiapkan direktori GenieACS" || loading_animation "📁 Preparing GenieACS directory"
    cd /root || return 1

    if [ -d "genieacs" ]; then
        if [ "$LANG_CODE" = "id" ]; then
            print_warning "Direktori genieacs sudah ada!"
            read -p "Hapus dan buat ulang? (y/n): " confirm
        else
            print_warning "GenieACS directory already exists!"
            read -p "Remove and recreate? (y/n): " confirm
        fi

        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            [ "$LANG_CODE" = "id" ] && loading_animation "🗑️  Menghapus container yang ada" || loading_animation "🗑️  Removing existing containers"
            docker stop genieacs mongo-genieacs 2>/dev/null
            docker rm genieacs mongo-genieacs 2>/dev/null
            rm -rf genieacs
        else
            return 1
        fi
    fi

    mkdir -p genieacs && cd genieacs || return 1

    MEMORY_LIMIT=$(choose_memory_limit "GenieACS")
    [ "$MEMORY_LIMIT" = "unlimited" ] \
        && { [ "$LANG_CODE" = "id" ] && print_info "Memory limit: Unlimited" || print_info "Memory limit: Unlimited"; } \
        || { [ "$LANG_CODE" = "id" ] && print_info "Memory limit: ${MEMORY_LIMIT}M" || print_info "Memory limit: ${MEMORY_LIMIT}M"; }

    [ "$LANG_CODE" = "id" ] && loading_animation "📝 Membuat konfigurasi Docker Compose" || loading_animation "📝 Creating Docker Compose configuration"

    GENIEACS_JWT_SECRET=$(openssl rand -hex 32)

    if [ "$MEMORY_LIMIT" = "unlimited" ]; then
        cat > docker-compose.yml <<EOF
services:
  genieacs:
    cpu_shares: 90
    container_name: genieacs
    depends_on:
      - mongo
    environment:
      - GENIEACS_CWMP_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-cwmp-access.log
      - GENIEACS_DEBUG_FILE=/var/log/genieacs/genieacs-debug.yaml
      - GENIEACS_EXT_DIR=/opt/genieacs/ext
      - GENIEACS_FS_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-fs-access.log
      - GENIEACS_MONGODB_CONNECTION_URL=mongodb://mongo/genieacs
      - GENIEACS_NBI_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-nbi-access.log
      - GENIEACS_UI_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-ui-access.log
      - GENIEACS_UI_JWT_SECRET=${GENIEACS_JWT_SECRET}
    hostname: genieacs
    image: drumsergio/genieacs:latest
    ports:
      - "3000:3000"
      - "7547:7547"
      - "7557:7557"
      - "7567:7567"
    restart: always
    networks:
      - genieacs_network
  mongo:
    cpu_shares: 90
    container_name: mongo-genieacs
    environment:
      - MONGO_DATA_DIR=/data/db
      - MONGO_LOG_DIR=/var/log/mongodb
    hostname: mongo-genieacs
    image: mongo:4.4.6
    restart: always
    networks:
      - genieacs_network
    volumes:
      - ./mongo-data:/data/db
networks:
  genieacs_network:
    driver: bridge
EOF
    else
        cat > docker-compose.yml <<EOF
services:
  genieacs:
    cpu_shares: 90
    container_name: genieacs
    depends_on:
      - mongo
    deploy:
      resources:
        limits:
          memory: ${MEMORY_LIMIT}M
    environment:
      - GENIEACS_CWMP_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-cwmp-access.log
      - GENIEACS_DEBUG_FILE=/var/log/genieacs/genieacs-debug.yaml
      - GENIEACS_EXT_DIR=/opt/genieacs/ext
      - GENIEACS_FS_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-fs-access.log
      - GENIEACS_MONGODB_CONNECTION_URL=mongodb://mongo/genieacs
      - GENIEACS_NBI_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-nbi-access.log
      - GENIEACS_UI_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-ui-access.log
      - GENIEACS_UI_JWT_SECRET=${GENIEACS_JWT_SECRET}
    hostname: genieacs
    image: drumsergio/genieacs:latest
    ports:
      - "3000:3000"
      - "7547:7547"
      - "7557:7557"
      - "7567:7567"
    restart: always
    networks:
      - genieacs_network
  mongo:
    cpu_shares: 90
    container_name: mongo-genieacs
    deploy:
      resources:
        limits:
          memory: ${MEMORY_LIMIT}M
    environment:
      - MONGO_DATA_DIR=/data/db
      - MONGO_LOG_DIR=/var/log/mongodb
    hostname: mongo-genieacs
    image: mongo:4.4.6
    restart: always
    networks:
      - genieacs_network
    volumes:
      - ./mongo-data:/data/db
networks:
  genieacs_network:
    driver: bridge
EOF
    fi

    echo ""
    echo "========================================================="
    [ "$LANG_CODE" = "id" ] && animated_text "🐳 Memulai Docker Compose..." 0.08 || animated_text "🐳 Starting Docker Compose..." 0.08
    [ "$LANG_CODE" = "id" ] && print_info "Proses download dan start container akan terlihat di bawah:" || print_info "Download and container start process will be shown below:"
    echo "========================================================="
    echo ""

    if docker compose up -d; then
        COMPOSE_SUCCESS=true
    elif docker-compose up -d; then
        COMPOSE_SUCCESS=true
    else
        COMPOSE_SUCCESS=false
    fi

    echo ""
    echo "========================================================="

    if [ "$COMPOSE_SUCCESS" = true ]; then
        [ "$LANG_CODE" = "id" ] && print_success "🎉 Docker Compose berhasil dijalankan!" || print_success "🎉 Docker Compose started successfully!"
    else
        [ "$LANG_CODE" = "id" ] && print_error "❌ Gagal menjalankan Docker Compose" || print_error "❌ Failed to start Docker Compose"
        return 1
    fi
    echo "========================================================="
    echo ""

    [ "$LANG_CODE" = "id" ] && show_progress_bar 40 "⏳ Menunggu container GenieACS dan MongoDB siap..." || show_progress_bar 40 "⏳ Waiting for GenieACS and MongoDB containers to be ready..."

    if docker ps | grep -q genieacs && docker ps | grep -q mongo-genieacs; then
        [ "$LANG_CODE" = "id" ] && print_success "✅ GenieACS berhasil diinstall!" || print_success "✅ GenieACS installed successfully!"
        [ "$LANG_CODE" = "id" ] && animated_text "⚙️  Melanjutkan ke konfigurasi database..." 0.08 || animated_text "⚙️  Proceeding to database configuration..." 0.08
        configure_genieacs
        return $?
    else
        [ "$LANG_CODE" = "id" ] && print_error "❌ Container gagal berjalan" || print_error "❌ Containers failed to start"
        docker ps -a
        return 1
    fi
}

# ============================================================
# CONFIGURE GENIEACS (DB from GitHub Raw)
# ============================================================
configure_genieacs() {
    echo ""
    [ "$LANG_CODE" = "id" ] && animated_text "⚙️  Memulai konfigurasi GenieACS..." 0.05 || animated_text "⚙️  Starting GenieACS configuration..." 0.05

    if ! docker ps | grep -q mongo-genieacs; then
        [ "$LANG_CODE" = "id" ] && print_error "Container mongo-genieacs tidak berjalan! Install GenieACS terlebih dahulu" || print_error "Container mongo-genieacs is not running! Install GenieACS first"
        return 1
    fi

    [ "$LANG_CODE" = "id" ] && loading_animation "📁 Menyiapkan direktori temp" || loading_animation "📁 Preparing temp directory"
    cd /tmp || return 1
    [ -d "genieacs-db" ] && rm -rf genieacs-db
    mkdir -p genieacs-db

    DB_FILES=(
        "cache.bson"
        "cache.metadata.json"
        "config.bson"
        "config.metadata.json"
        "devices.metadata.json"
        "faults.metadata.json"
        "locks.metadata.json"
        "permissions.bson"
        "permissions.metadata.json"
        "presets.bson"
        "presets.metadata.json"
        "provisions.bson"
        "provisions.metadata.json"
        "tasks.metadata.json"
        "users.bson"
        "users.metadata.json"
        "virtualParameters.bson"
        "virtualParameters.metadata.json"
    )

    if [ "$LANG_CODE" = "id" ]; then
        print_info "Sumber DB: ${DB_URL}"
        loading_animation "📦 Mengunduh ${#DB_FILES[@]} file database dari GitHub"
    else
        print_info "DB Source: ${DB_URL}"
        loading_animation "📦 Downloading ${#DB_FILES[@]} database files from GitHub"
    fi

    local failed=0
    for file in "${DB_FILES[@]}"; do
        if curl -f -s -L -o "genieacs-db/$file" "${DB_URL}/${file}"; then
            echo "  ✓ $file"
        else
            [ "$LANG_CODE" = "id" ] && print_error "Gagal mengunduh $file dari ${DB_URL}/${file}" || print_error "Failed to download $file from ${DB_URL}/${file}"
            failed=$((failed + 1))
        fi
    done

    if [ $failed -gt 0 ]; then
        [ "$LANG_CODE" = "id" ] && print_error "❌ $failed file gagal diunduh. Periksa koneksi dan pastikan folder 'db' ada di repo GitHub." || print_error "❌ $failed files failed to download. Check connection and ensure 'db' folder exists in GitHub repo."
        return 1
    fi

    [ "$LANG_CODE" = "id" ] && loading_animation "✅ Memverifikasi file database" || loading_animation "✅ Verifying database files"
    ls -la genieacs-db/ || { [ "$LANG_CODE" = "id" ] && print_error "Direktori database tidak ditemukan" || print_error "Database directory not found"; return 1; }

    [ "$LANG_CODE" = "id" ] && loading_animation "📂 Menyalin file ke container" || loading_animation "📂 Copying files to container"
    docker cp genieacs-db/ mongo-genieacs:/tmp/db/ || { [ "$LANG_CODE" = "id" ] && print_error "Gagal menyalin file ke container" || print_error "Failed to copy files to container"; return 1; }

    [ "$LANG_CODE" = "id" ] && loading_animation "🔄 Merestore database" || loading_animation "🔄 Restoring database"
    docker exec mongo-genieacs mongorestore --drop --db genieacs /tmp/db/ || { [ "$LANG_CODE" = "id" ] && print_error "Gagal restore database" || print_error "Failed to restore database"; return 1; }

    [ "$LANG_CODE" = "id" ] && loading_animation "🔄 Merestart GenieACS" || loading_animation "🔄 Restarting GenieACS"
    docker restart genieacs || { [ "$LANG_CODE" = "id" ] && print_error "Gagal restart GenieACS" || print_error "Failed to restart GenieACS"; return 1; }

    [ "$LANG_CODE" = "id" ] && show_progress_bar 20 "⏳ Menunggu GenieACS siap..." || show_progress_bar 20 "⏳ Waiting for GenieACS to be ready..."

    [ "$LANG_CODE" = "id" ] && print_success "✅ Konfigurasi GenieACS berhasil!" || print_success "✅ GenieACS configuration successful!"

    SERVER_IP=$(get_server_ip)
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    [ "$LANG_CODE" = "id" ] && echo "║                    INSTALASI SELESAI!                   ║" || echo "║                  INSTALLATION COMPLETE!                 ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║  🌐 URL GenieACS : http://${SERVER_IP}:3000"
    echo "║  👤 Username     : admin                                 ║"
    echo "║  🔑 Password     : admin                                 ║"
    echo "╚══════════════════════════════════════════════════════════╝"

    cd /tmp && rm -rf genieacs-db
    return 0
}

# ============================================================
# UNINSTALL GENIEACS
# ============================================================
uninstall_genieacs() {
    echo ""
    if [ "$LANG_CODE" = "id" ]; then
        print_warning "PERINGATAN: Ini akan menghapus GenieACS, database, dan semua data!"
        read -p "Apakah Anda yakin? (y/n): " confirm
    else
        print_warning "WARNING: This will remove GenieACS, database, and all data!"
        read -p "Are you sure? (y/n): " confirm
    fi

    [ "$confirm" != "y" ] && [ "$confirm" != "Y" ] && { [ "$LANG_CODE" = "id" ] && print_info "Uninstall dibatalkan" || print_info "Uninstall cancelled"; return 1; }

    echo ""
    echo "========================================================="
    [ "$LANG_CODE" = "id" ] && print_info "Memulai proses uninstall GenieACS..." || print_info "Starting GenieACS uninstall process..."
    echo "========================================================="
    echo ""

    [ "$LANG_CODE" = "id" ] && print_info "Menghentikan dan menghapus container..." || print_info "Stopping and removing containers..."
    docker stop genieacs mongo-genieacs 2>/dev/null
    docker rm genieacs mongo-genieacs 2>/dev/null

    [ "$LANG_CODE" = "id" ] && print_info "Menghapus Docker images..." || print_info "Removing Docker images..."
    docker rmi drumsergio/genieacs:latest 2>/dev/null
    docker rmi mongo:4.4.6 2>/dev/null

    [ "$LANG_CODE" = "id" ] && print_info "Menghapus network..." || print_info "Removing network..."
    docker network rm genieacs_genieacs_network 2>&1 | grep -v "not found" || true

    [ "$LANG_CODE" = "id" ] && print_info "Menghapus direktori GenieACS..." || print_info "Removing GenieACS directory..."
    rm -rf /root/genieacs

    if [ "$(check_ufw_status)" = "active" ]; then
        echo ""
        [ "$LANG_CODE" = "id" ] && read -p "Hapus rules firewall GenieACS? (y/n): " remove_fw || read -p "Remove GenieACS firewall rules? (y/n): " remove_fw
        if [ "$remove_fw" = "y" ] || [ "$remove_fw" = "Y" ]; then
            ufw delete allow 3000/tcp 2>/dev/null; ufw delete allow 7547/tcp 2>/dev/null
            ufw delete allow 7557/tcp 2>/dev/null; ufw delete allow 7567/tcp 2>/dev/null
            ufw reload &> /dev/null
            [ "$LANG_CODE" = "id" ] && print_success "Rules firewall berhasil dihapus" || print_success "Firewall rules removed successfully"
        fi
    fi

    echo ""
    [ "$LANG_CODE" = "id" ] && print_info "Membersihkan sistem..." || print_info "Pruning system..."
    command -v docker &> /dev/null && docker system prune -f

    echo ""
    [ "$LANG_CODE" = "id" ] && print_success "GenieACS berhasil dihapus!" || print_success "GenieACS successfully removed!"
    return 0
}

# ============================================================
# INSTALL GENIEACS PANEL
# ============================================================
install_genieacs_panel() {
    show_installation_header
    [ "$LANG_CODE" = "id" ] && animated_text "🚀 Memulai instalasi GenieACS Panel..." 0.05 || animated_text "🚀 Starting GenieACS Panel installation..." 0.05

    if ! command -v docker &> /dev/null; then
        [ "$LANG_CODE" = "id" ] && print_error "Docker belum terinstall! Silakan install Docker terlebih dahulu" || print_error "Docker is not installed! Please install Docker first"
        return 1
    fi

    configure_firewall "1997/tcp"

    ARCH=$(detect_architecture)
    [ "$LANG_CODE" = "id" ] && print_info "Arsitektur terdeteksi: $ARCH" || print_info "Detected architecture: $ARCH"
    [ "$ARCH" = "unknown" ] && { [ "$LANG_CODE" = "id" ] && print_error "Arsitektur tidak didukung: $(uname -m)" || print_error "Unsupported architecture: $(uname -m)"; return 1; }

    [ "$LANG_CODE" = "id" ] && loading_animation "📁 Menyiapkan direktori GenieACS Panel" || loading_animation "📁 Preparing GenieACS Panel directory"
    cd /root || return 1

    if [ -d "genieacspanel" ]; then
        if [ "$LANG_CODE" = "id" ]; then
            print_warning "Direktori genieacspanel sudah ada!"
            read -p "Hapus dan buat ulang? (y/n): " confirm
        else
            print_warning "GenieACS Panel directory already exists!"
            read -p "Remove and recreate? (y/n): " confirm
        fi

        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            [ "$LANG_CODE" = "id" ] && loading_animation "🗑️  Menghapus container yang ada" || loading_animation "🗑️  Removing existing container"
            docker stop genieacs-panel-api 2>/dev/null; docker rm genieacs-panel-api 2>/dev/null
            rm -rf genieacspanel
        else
            return 1
        fi
    fi

    mkdir -p genieacspanel && cd genieacspanel || return 1

    MEMORY_LIMIT=$(choose_memory_limit "GenieACS Panel")
    [ "$MEMORY_LIMIT" = "unlimited" ] \
        && { [ "$LANG_CODE" = "id" ] && print_info "Memory limit: Unlimited" || print_info "Memory limit: Unlimited"; } \
        || { [ "$LANG_CODE" = "id" ] && print_info "Memory limit: ${MEMORY_LIMIT}M" || print_info "Memory limit: ${MEMORY_LIMIT}M"; }

    JWT_SECRET=$(openssl rand -hex 32)
    IMAGE="solusidigitalnet/genieacspanelapi:latest"

    [ "$LANG_CODE" = "id" ] && loading_animation "📝 Membuat konfigurasi Docker Compose" || loading_animation "📝 Creating Docker Compose configuration"

    if [ "$MEMORY_LIMIT" = "unlimited" ]; then
        cat > docker-compose.yml <<EOF
services:
  genieacs-panel-api:
    image: ${IMAGE}
    container_name: genieacs-panel-api
    ports:
      - "1997:1997"
    extra_hosts:
      - "host.docker.internal:host-gateway"
    environment:
      - JWT_SECRET=${JWT_SECRET}
      - JWT_EXPIRES_IN=1h
      - REFRESH_TOKEN_EXPIRES_IN=7d
      - add_wan=yes
      - NODE_ENV=production
    restart: unless-stopped
EOF
    else
        cat > docker-compose.yml <<EOF
services:
  genieacs-panel-api:
    image: ${IMAGE}
    container_name: genieacs-panel-api
    deploy:
      resources:
        limits:
          memory: ${MEMORY_LIMIT}M
    ports:
      - "1997:1997"
    extra_hosts:
      - "host.docker.internal:host-gateway"
    environment:
      - JWT_SECRET=${JWT_SECRET}
      - JWT_EXPIRES_IN=1h
      - REFRESH_TOKEN_EXPIRES_IN=7d
      - add_wan=yes
      - NODE_ENV=production
    restart: unless-stopped
EOF
    fi

    echo ""; echo "========================================================="; [ "$LANG_CODE" = "id" ] && animated_text "🐳 Memulai Docker Compose..." 0.08 || animated_text "🐳 Starting Docker Compose..." 0.08; echo "========================================================="; echo ""

    if docker compose up -d; then COMPOSE_SUCCESS=true; elif docker-compose up -d; then COMPOSE_SUCCESS=true; else COMPOSE_SUCCESS=false; fi

    echo ""; echo "========================================================="
    if [ "$COMPOSE_SUCCESS" = true ]; then
        [ "$LANG_CODE" = "id" ] && print_success "🎉 Docker Compose berhasil dijalankan!" || print_success "🎉 Docker Compose started successfully!"
    else
        [ "$LANG_CODE" = "id" ] && print_error "❌ Gagal menjalankan Docker Compose" || print_error "❌ Failed to start Docker Compose"
        return 1
    fi
    echo "========================================================="; echo ""

    [ "$LANG_CODE" = "id" ] && show_progress_bar 30 "⏳ Menunggu container siap..." || show_progress_bar 30 "⏳ Waiting for container to be ready..."

    if docker ps | grep -q genieacs-panel-api; then
        [ "$LANG_CODE" = "id" ] && print_success "✅ GenieACS Panel berhasil diinstall dan berjalan!" || print_success "✅ GenieACS Panel installed and running successfully!"
        SERVER_IP=$(get_server_ip)
        echo ""
        echo "╔══════════════════════════════════════════════════════════╗"
        [ "$LANG_CODE" = "id" ] && echo "║                    INSTALASI SELESAI!                   ║" || echo "║                  INSTALLATION COMPLETE!                 ║"
        echo "╠══════════════════════════════════════════════════════════╣"
        echo "║  🌐 URL Panel: http://${SERVER_IP}:1997"
        echo "║  👤 Username : admin                                     ║"
        echo "║  🔑 Password : solusidigitalnet                          ║"
        echo "╚══════════════════════════════════════════════════════════╝"
        return 0
    else
        [ "$LANG_CODE" = "id" ] && print_error "❌ Container gagal berjalan" || print_error "❌ Container failed to start"
        docker ps -a; docker logs genieacs-panel-api
        return 1
    fi
}

# ============================================================
# UNINSTALL GENIEACS PANEL
# ============================================================
uninstall_genieacs_panel() {
    show_installation_header
    [ "$LANG_CODE" = "id" ] && animated_text "⚠️  PERINGATAN: Ini akan menghapus GenieACS Panel!" 0.05 || animated_text "⚠️  WARNING: This will remove GenieACS Panel!" 0.05
    [ "$LANG_CODE" = "id" ] && read -p "Apakah Anda yakin? (y/n): " confirm || read -p "Are you sure? (y/n): " confirm
    [ "$confirm" != "y" ] && [ "$confirm" != "Y" ] && { [ "$LANG_CODE" = "id" ] && print_info "Uninstall dibatalkan" || print_info "Uninstall cancelled"; return 1; }

    echo ""; echo "========================================================="; [ "$LANG_CODE" = "id" ] && animated_text "🗑️  Memulai proses uninstall GenieACS Panel..." 0.08 || animated_text "🗑️  Starting GenieACS Panel uninstall process..." 0.08; echo "========================================================="; echo ""

    [ "$LANG_CODE" = "id" ] && loading_animation "🛑 Menghentikan dan menghapus container" || loading_animation "🛑 Stopping and removing container"
    docker stop genieacs-panel-api 2>/dev/null; docker rm genieacs-panel-api 2>/dev/null

    [ "$LANG_CODE" = "id" ] && loading_animation "🐳 Menghapus Docker image" || loading_animation "🐳 Removing Docker image"
    docker rmi solusidigitalnet/genieacspanelapi:latest 2>&1 | grep -v "No such image" || true

    [ "$LANG_CODE" = "id" ] && loading_animation "📁 Menghapus direktori GenieACS Panel" || loading_animation "📁 Removing GenieACS Panel directory"
    rm -rf /root/genieacspanel

    if [ "$(check_ufw_status)" = "active" ]; then
        echo ""
        [ "$LANG_CODE" = "id" ] && read -p "Hapus rules firewall GenieACS Panel? (y/n): " remove_fw || read -p "Remove GenieACS Panel firewall rules? (y/n): " remove_fw
        if [ "$remove_fw" = "y" ] || [ "$remove_fw" = "Y" ]; then
            [ "$LANG_CODE" = "id" ] && loading_animation "🔥 Menghapus rules firewall" || loading_animation "🔥 Removing firewall rules"
            ufw delete allow 1997/tcp 2>/dev/null; ufw reload &> /dev/null
            [ "$LANG_CODE" = "id" ] && print_success "✅ Rules firewall berhasil dihapus" || print_success "✅ Firewall rules removed successfully"
        fi
    fi

    [ "$LANG_CODE" = "id" ] && loading_animation "🧹 Membersihkan sistem" || loading_animation "🧹 Cleaning up system"
    command -v docker &> /dev/null && docker system prune -f

    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    [ "$LANG_CODE" = "id" ] && echo "║                    UNINSTALL SELESAI!                   ║" || echo "║                  UNINSTALL COMPLETE!                    ║"
    [ "$LANG_CODE" = "id" ] && echo "║          GenieACS Panel berhasil dihapus! ✅             ║" || echo "║        GenieACS Panel successfully removed! ✅           ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    return 0
}

# ============================================================
# INSTALL CUSTOMER PORTAL
# ============================================================
install_customer_portal() {
    show_installation_header
    [ "$LANG_CODE" = "id" ] && animated_text "🚀 Memulai instalasi Customer Portal..." 0.05 || animated_text "🚀 Starting Customer Portal installation..." 0.05

    if ! command -v docker &> /dev/null; then
        [ "$LANG_CODE" = "id" ] && print_error "Docker belum terinstall! Silakan install Docker terlebih dahulu" || print_error "Docker is not installed! Please install Docker first"
        return 1
    fi

    configure_firewall "1998/tcp"

    ARCH=$(detect_architecture)
    [ "$LANG_CODE" = "id" ] && print_info "Arsitektur terdeteksi: $ARCH" || print_info "Detected architecture: $ARCH"
    [ "$ARCH" = "unknown" ] && { [ "$LANG_CODE" = "id" ] && print_error "Arsitektur tidak didukung: $(uname -m)" || print_error "Unsupported architecture: $(uname -m)"; return 1; }

    [ "$LANG_CODE" = "id" ] && loading_animation "📁 Menyiapkan direktori Customer Portal" || loading_animation "📁 Preparing Customer Portal directory"
    cd /root || return 1

    if [ -d "customerportal" ]; then
        if [ "$LANG_CODE" = "id" ]; then
            print_warning "Direktori customerportal sudah ada!"
            read -p "Hapus dan buat ulang? (y/n): " confirm
        else
            print_warning "Customer Portal directory already exists!"
            read -p "Remove and recreate? (y/n): " confirm
        fi

        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            [ "$LANG_CODE" = "id" ] && loading_animation "🗑️  Menghapus container yang ada" || loading_animation "🗑️  Removing existing container"
            docker stop customerportal 2>/dev/null; docker rm customerportal 2>/dev/null
            rm -rf customerportal
        else
            return 1
        fi
    fi

    mkdir -p customerportal && cd customerportal || return 1

    MEMORY_LIMIT=$(choose_memory_limit "Customer Portal")
    [ "$MEMORY_LIMIT" = "unlimited" ] \
        && { [ "$LANG_CODE" = "id" ] && print_info "Memory limit: Unlimited" || print_info "Memory limit: Unlimited"; } \
        || { [ "$LANG_CODE" = "id" ] && print_info "Memory limit: ${MEMORY_LIMIT}M" || print_info "Memory limit: ${MEMORY_LIMIT}M"; }

    SESSION_SECRET=$(openssl rand -hex 32)

    echo ""
    if [ "$LANG_CODE" = "id" ]; then
        print_info "Konfigurasi Customer Portal:"
        echo "Masukkan PORTAL_API_KEY dari Panel Settings:"
        read -p "PORTAL_API_KEY: " PORTAL_API_KEY
        while [ -z "$PORTAL_API_KEY" ]; do
            print_error "PORTAL_API_KEY tidak boleh kosong!"
            read -p "PORTAL_API_KEY: " PORTAL_API_KEY
        done
    else
        print_info "Customer Portal Configuration:"
        echo "Enter PORTAL_API_KEY from Panel Settings:"
        read -p "PORTAL_API_KEY: " PORTAL_API_KEY
        while [ -z "$PORTAL_API_KEY" ]; do
            print_error "PORTAL_API_KEY cannot be empty!"
            read -p "PORTAL_API_KEY: " PORTAL_API_KEY
        done
    fi

    IMAGE="solusidigitalnet/customerportal:latest"
    [ "$LANG_CODE" = "id" ] && loading_animation "📝 Membuat konfigurasi Docker Compose" || loading_animation "📝 Creating Docker Compose configuration"

    if [ "$MEMORY_LIMIT" = "unlimited" ]; then
        cat > docker-compose.yml <<EOF
services:
  customerportal:
    image: ${IMAGE}
    container_name: customerportal
    ports:
      - "1998:1998"
    extra_hosts:
      - "host.docker.internal:host-gateway"
    environment:
      - NODE_ENV=production
      - PORT=1998
      - PANEL_URL=http://host.docker.internal:1997
      - PORTAL_API_KEY=${PORTAL_API_KEY}
      - SESSION_SECRET=${SESSION_SECRET}
      - WHATSAPP_FORGOT_CODE=1234567890
      - WHATSAPP_SUPPORT=1234567890
      - DISPLAY_SSID_24GHZ=1
      - DISPLAY_SSID_58GHZ=5
    restart: unless-stopped
EOF
    else
        cat > docker-compose.yml <<EOF
services:
  customerportal:
    image: ${IMAGE}
    container_name: customerportal
    deploy:
      resources:
        limits:
          memory: ${MEMORY_LIMIT}M
    ports:
      - "1998:1998"
    extra_hosts:
      - "host.docker.internal:host-gateway"
    environment:
      - NODE_ENV=production
      - PORT=1998
      - PANEL_URL=http://host.docker.internal:1997
      - PORTAL_API_KEY=${PORTAL_API_KEY}
      - SESSION_SECRET=${SESSION_SECRET}
      - WHATSAPP_FORGOT_CODE=1234567890
      - WHATSAPP_SUPPORT=1234567890
      - DISPLAY_SSID_24GHZ=1
      - DISPLAY_SSID_58GHZ=5
    restart: unless-stopped
EOF
    fi

    echo ""; echo "========================================================="; [ "$LANG_CODE" = "id" ] && animated_text "🐳 Memulai Docker Compose..." 0.08 || animated_text "🐳 Starting Docker Compose..." 0.08; echo "========================================================="; echo ""

    if docker compose up -d; then COMPOSE_SUCCESS=true; elif docker-compose up -d; then COMPOSE_SUCCESS=true; else COMPOSE_SUCCESS=false; fi

    echo ""; echo "========================================================="
    if [ "$COMPOSE_SUCCESS" = true ]; then
        [ "$LANG_CODE" = "id" ] && print_success "🎉 Docker Compose berhasil dijalankan!" || print_success "🎉 Docker Compose started successfully!"
    else
        [ "$LANG_CODE" = "id" ] && print_error "❌ Gagal menjalankan Docker Compose" || print_error "❌ Failed to start Docker Compose"
        return 1
    fi
    echo "========================================================="; echo ""

    [ "$LANG_CODE" = "id" ] && show_progress_bar 25 "⏳ Menunggu container siap..." || show_progress_bar 25 "⏳ Waiting for container to be ready..."

    if docker ps | grep -q customerportal; then
        [ "$LANG_CODE" = "id" ] && print_success "✅ Customer Portal berhasil diinstall dan berjalan!" || print_success "✅ Customer Portal installed and running successfully!"
        SERVER_IP=$(get_server_ip)
        echo ""
        echo "╔══════════════════════════════════════════════════════════╗"
        [ "$LANG_CODE" = "id" ] && echo "║                    INSTALASI SELESAI!                   ║" || echo "║                  INSTALLATION COMPLETE!                 ║"
        echo "╠══════════════════════════════════════════════════════════╣"
        echo "║  🌐 URL Portal: http://${SERVER_IP}:1998"
        echo "║  🔑 API Key   : ${PORTAL_API_KEY:0:20}..."
        [ "$LANG_CODE" = "id" ] && echo "║  📱 WhatsApp  : Sesuaikan di environment variables      ║" || echo "║  📱 WhatsApp  : Configure in environment variables      ║"
        echo "╚══════════════════════════════════════════════════════════╝"
        return 0
    else
        [ "$LANG_CODE" = "id" ] && print_error "❌ Container gagal berjalan" || print_error "❌ Container failed to start"
        docker ps -a; docker logs customerportal
        return 1
    fi
}

# ============================================================
# UNINSTALL CUSTOMER PORTAL
# ============================================================
uninstall_customer_portal() {
    show_installation_header
    [ "$LANG_CODE" = "id" ] && animated_text "⚠️  PERINGATAN: Ini akan menghapus Customer Portal!" 0.05 || animated_text "⚠️  WARNING: This will remove Customer Portal!" 0.05
    [ "$LANG_CODE" = "id" ] && read -p "Apakah Anda yakin? (y/n): " confirm || read -p "Are you sure? (y/n): " confirm
    [ "$confirm" != "y" ] && [ "$confirm" != "Y" ] && { [ "$LANG_CODE" = "id" ] && print_info "Uninstall dibatalkan" || print_info "Uninstall cancelled"; return 1; }

    echo ""; echo "========================================================="; [ "$LANG_CODE" = "id" ] && animated_text "🗑️  Memulai proses uninstall Customer Portal..." 0.08 || animated_text "🗑️  Starting Customer Portal uninstall process..." 0.08; echo "========================================================="; echo ""

    [ "$LANG_CODE" = "id" ] && loading_animation "🛑 Menghentikan dan menghapus container" || loading_animation "🛑 Stopping and removing container"
    docker stop customerportal 2>/dev/null; docker rm customerportal 2>/dev/null

    [ "$LANG_CODE" = "id" ] && loading_animation "🐳 Menghapus Docker image" || loading_animation "🐳 Removing Docker image"
    docker rmi solusidigitalnet/customerportal:latest 2>&1 | grep -v "No such image" || true

    [ "$LANG_CODE" = "id" ] && loading_animation "📁 Menghapus direktori Customer Portal" || loading_animation "📁 Removing Customer Portal directory"
    rm -rf /root/customerportal

    if [ "$(check_ufw_status)" = "active" ]; then
        echo ""
        [ "$LANG_CODE" = "id" ] && read -p "Hapus rules firewall Customer Portal? (y/n): " remove_fw || read -p "Remove Customer Portal firewall rules? (y/n): " remove_fw
        if [ "$remove_fw" = "y" ] || [ "$remove_fw" = "Y" ]; then
            [ "$LANG_CODE" = "id" ] && loading_animation "🔥 Menghapus rules firewall" || loading_animation "🔥 Removing firewall rules"
            ufw delete allow 1998/tcp 2>/dev/null; ufw reload &> /dev/null
            [ "$LANG_CODE" = "id" ] && print_success "✅ Rules firewall berhasil dihapus" || print_success "✅ Firewall rules removed successfully"
        fi
    fi

    [ "$LANG_CODE" = "id" ] && loading_animation "🧹 Membersihkan sistem" || loading_animation "🧹 Cleaning up system"
    command -v docker &> /dev/null && docker system prune -f

    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    [ "$LANG_CODE" = "id" ] && echo "║                    UNINSTALL SELESAI!                   ║" || echo "║                  UNINSTALL COMPLETE!                    ║"
    [ "$LANG_CODE" = "id" ] && echo "║          Customer Portal berhasil dihapus! ✅            ║" || echo "║        Customer Portal successfully removed! ✅          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    return 0
}

# ============================================================
# L2TP SERVER (BETA) - No IPsec
# ============================================================

# --- Helper: generate random suffix untuk password ---
generate_l2tp_password_suffix() {
    # Format: solusidigital-<random8hex>
    echo "solusidigital-$(openssl rand -hex 4)"
}

# --- Helper: dapatkan index akun berikutnya ---
get_next_account_index() {
    if [ ! -f "$L2TP_ACCOUNTS_FILE" ]; then
        echo 1
        return
    fi
    local count
    count=$(grep -c "^account" "$L2TP_ACCOUNTS_FILE" 2>/dev/null || echo "0")
    echo $((count + 1))
}

# --- Helper: dapatkan IP fixed untuk akun ke-N ---
get_account_ip() {
    local index=$1
    local octet=$(( L2TP_IP_POOL_OFFSET + index - 1 ))
    echo "${L2TP_IP_POOL_BASE}.${octet}"
}

# --- Cek apakah sistem support L2TP tanpa IPsec ---
check_l2tp_support() {
    local issues=()
    local warnings=()

    # Cek kernel module ppp
    if ! modprobe ppp 2>/dev/null && ! lsmod | grep -q "^ppp"; then
        issues+=("Kernel module 'ppp' tidak tersedia / not available")
    fi

    # Cek kernel module l2tp_ppp (opsional tapi dibutuhkan)
    if ! modprobe l2tp_ppp 2>/dev/null && ! lsmod | grep -q "^l2tp_ppp"; then
        issues+=("Kernel module 'l2tp_ppp' tidak tersedia / not available")
    fi

    # Cek apakah WSL (L2TP tidak support WSL)
    if grep -qi microsoft /proc/version 2>/dev/null || grep -qi wsl /proc/version 2>/dev/null; then
        issues+=("WSL (Windows Subsystem for Linux) tidak mendukung L2TP kernel modules")
    fi

    # Cek apakah container/VPS yang tidak support tun/ppp
    if [ ! -e /dev/ppp ] && ! mknod /dev/ppp c 108 0 2>/dev/null; then
        issues+=("Device /dev/ppp tidak dapat dibuat - mungkin berjalan di dalam container")
    fi

    # Cek xl2tpd tersedia di repo
    if ! apt-cache show xl2tpd &>/dev/null 2>&1; then
        warnings+=("xl2tpd tidak ditemukan di repository apt - akan mencoba install tetap")
    fi

    # Tampilkan hasil
    echo ""
    echo "========================================================="
    [ "$LANG_CODE" = "id" ] && echo "       CEK KOMPATIBILITAS L2TP (BETA)" || echo "       L2TP COMPATIBILITY CHECK (BETA)"
    echo "========================================================="

    if [ ${#issues[@]} -eq 0 ]; then
        print_success "✅ Sistem mendukung L2TP tanpa IPsec"
        [ ${#warnings[@]} -gt 0 ] && {
            echo ""
            for w in "${warnings[@]}"; do print_warning "⚠  $w"; done
        }
        echo "========================================================="
        return 0
    else
        print_error "❌ Sistem TIDAK mendukung L2TP:"
        echo ""
        for issue in "${issues[@]}"; do
            echo "  ✗ $issue"
        done
        [ ${#warnings[@]} -gt 0 ] && {
            echo ""
            for w in "${warnings[@]}"; do print_warning "⚠  $w"; done
        }
        echo ""
        print_beta "Ini adalah fitur BETA - mungkin tidak bekerja di semua environment"
        echo "========================================================="
        return 1
    fi
}

# --- Install L2TP Server ---
install_l2tp() {
    show_installation_header
    echo -e "${CYAN}"
    echo "  ██╗     ██████╗ ████████╗██████╗      ██████╗ "
    echo "  ██║     ╚════██╗╚══██╔══╝██╔══██╗     ╚════██╗"
    echo "  ██║      █████╔╝   ██║   ██████╔╝      █████╔╝"
    echo "  ██║     ██╔═══╝    ██║   ██╔═══╝      ██╔═══╝ "
    echo "  ███████╗███████╗   ██║   ██║          ███████╗"
    echo "  ╚══════╝╚══════╝   ╚═╝   ╚═╝          ╚══════╝"
    echo -e "${NC}"
    print_beta "=== L2TP SERVER (BETA) - Tanpa IPsec / No IPsec ==="
    echo ""

    # Cek kompatibilitas dulu
    if ! check_l2tp_support; then
        echo ""
        if [ "$LANG_CODE" = "id" ]; then
            print_warning "Sistem tidak kompatibel. Apakah tetap ingin lanjutkan? (tidak disarankan)"
            read -p "Lanjutkan paksa? (y/n): " force_continue
        else
            print_warning "System is not compatible. Do you still want to continue? (not recommended)"
            read -p "Force continue? (y/n): " force_continue
        fi
        [ "$force_continue" != "y" ] && [ "$force_continue" != "Y" ] && return 1
    fi

    echo ""
    if [ "$LANG_CODE" = "id" ]; then
        print_info "Memulai instalasi L2TP Server tanpa IPsec..."
        print_beta "Paket yang akan diinstall: xl2tpd, ppp"
    else
        print_info "Starting L2TP Server installation without IPsec..."
        print_beta "Packages to install: xl2tpd, ppp"
    fi
    echo ""

    [ "$LANG_CODE" = "id" ] && loading_animation "📦 Update package list" || loading_animation "📦 Updating package list"
    safe_apt_get apt-get update || { print_error "Gagal update package list"; return 1; }

    [ "$LANG_CODE" = "id" ] && loading_animation "📦 Menginstall xl2tpd dan ppp" || loading_animation "📦 Installing xl2tpd and ppp"
    safe_apt_get apt-get install -y xl2tpd ppp || {
        print_error "Gagal install xl2tpd/ppp"
        return 1
    }

    # Buat direktori konfigurasi kustom
    mkdir -p "$L2TP_CONFIG_DIR"
    touch "$L2TP_ACCOUNTS_FILE"
    touch "$L2TP_ROUTES_FILE"

    # Aktifkan IP forwarding permanen
    [ "$LANG_CODE" = "id" ] && loading_animation "🔧 Mengaktifkan IP Forwarding" || loading_animation "🔧 Enabling IP Forwarding"
    sysctl -w net.ipv4.ip_forward=1 > /dev/null 2>&1
    if ! grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf; then
        echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    else
        sed -i 's/^.*net.ipv4.ip_forward.*$/net.ipv4.ip_forward=1/' /etc/sysctl.conf
    fi

    # Pastikan /dev/ppp ada
    [ ! -e /dev/ppp ] && mknod /dev/ppp c 108 0 2>/dev/null && chmod 600 /dev/ppp
    modprobe l2tp_ppp 2>/dev/null || true
    modprobe ppp 2>/dev/null || true

    # Konfigurasi xl2tpd (L2TP tanpa IPsec)
    [ "$LANG_CODE" = "id" ] && loading_animation "📝 Membuat konfigurasi xl2tpd" || loading_animation "📝 Creating xl2tpd configuration"
    cat > /etc/xl2tpd/xl2tpd.conf <<EOF
[global]
ipsec saref = no
listen-addr = 0.0.0.0
port = 1701

[lns default]
ip range = ${L2TP_IP_POOL_BASE}.2-${L2TP_IP_POOL_BASE}.254
local ip = ${L2TP_SERVER_IP}
require chap = yes
refuse pap = yes
require authentication = yes
name = l2tpserver
ppp debug = no
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF

    # Konfigurasi PPP options (tanpa IPsec, tanpa enkripsi bawaan)
    [ "$LANG_CODE" = "id" ] && loading_animation "📝 Membuat konfigurasi PPP" || loading_animation "📝 Creating PPP configuration"
    cat > /etc/ppp/options.xl2tpd <<EOF
# L2TP tanpa IPsec - PPP Options
ipcp-accept-local
ipcp-accept-remote
ms-dns 8.8.8.8
ms-dns 8.8.4.4
noccp
noauth
mtu 1400
mru 1400
nodefaultroute
debug
logfile /var/log/xl2tpd.log
lock
proxyarp
EOF

    # Konfigurasi chap-secrets (akan diisi saat tambah akun)
    if [ ! -f /etc/ppp/chap-secrets ]; then
        cat > /etc/ppp/chap-secrets <<EOF
# Secrets for authentication using CHAP
# client        server  secret          IP addresses
EOF
    fi

    # Buka firewall port L2TP
    configure_firewall "1701/udp"

    # NAT / masquerade untuk klien L2TP bisa akses internet
    [ "$LANG_CODE" = "id" ] && loading_animation "🔥 Mengatur iptables NAT untuk L2TP" || loading_animation "🔥 Setting up iptables NAT for L2TP"
    MAIN_IFACE=$(ip route | grep default | awk '{print $5}' | head -1)
    if [ -n "$MAIN_IFACE" ]; then
        iptables -t nat -C POSTROUTING -s ${L2TP_IP_POOL_BASE}.0/24 -o "$MAIN_IFACE" -j MASQUERADE 2>/dev/null \
            || iptables -t nat -A POSTROUTING -s ${L2TP_IP_POOL_BASE}.0/24 -o "$MAIN_IFACE" -j MASQUERADE
        iptables -C FORWARD -s ${L2TP_IP_POOL_BASE}.0/24 -j ACCEPT 2>/dev/null \
            || iptables -A FORWARD -s ${L2TP_IP_POOL_BASE}.0/24 -j ACCEPT
        iptables -C FORWARD -d ${L2TP_IP_POOL_BASE}.0/24 -j ACCEPT 2>/dev/null \
            || iptables -A FORWARD -d ${L2TP_IP_POOL_BASE}.0/24 -j ACCEPT
    fi

    # Simpan iptables agar permanen
    if command -v iptables-save &>/dev/null; then
        if command -v netfilter-persistent &>/dev/null; then
            netfilter-persistent save 2>/dev/null
        else
            safe_apt_get apt-get install -y iptables-persistent 2>/dev/null
            iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
        fi
    fi

    # Buat systemd service untuk restore iptables dan routes saat boot
    [ "$LANG_CODE" = "id" ] && loading_animation "⚙️  Membuat service startup" || loading_animation "⚙️  Creating startup service"
    cat > /etc/systemd/system/l2tp-routes.service <<EOF
[Unit]
Description=L2TP Static Routes Restore
After=network.target xl2tpd.service
Wants=xl2tpd.service

[Service]
Type=oneshot
ExecStart=/bin/bash ${L2TP_CONFIG_DIR}/apply-routes.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

    # Script apply routes
    cat > "${L2TP_CONFIG_DIR}/apply-routes.sh" <<'ROUTESCRIPT'
#!/bin/bash
# Auto-apply L2TP static routes on boot
ROUTES_FILE="/etc/l2tp-server/routes.conf"
[ ! -f "$ROUTES_FILE" ] && exit 0

while IFS='|' read -r account_name via_ip dest_network comment; do
    [[ "$account_name" =~ ^#.*$ ]] && continue
    [ -z "$account_name" ] && continue
    if [ -n "$via_ip" ] && [ -n "$dest_network" ]; then
        ip route add "$dest_network" via "$via_ip" 2>/dev/null || \
        ip route replace "$dest_network" via "$via_ip" 2>/dev/null || true
    fi
done < "$ROUTES_FILE"
ROUTESCRIPT
    chmod +x "${L2TP_CONFIG_DIR}/apply-routes.sh"

    systemctl daemon-reload
    systemctl enable l2tp-routes 2>/dev/null || true

    # Start xl2tpd
    [ "$LANG_CODE" = "id" ] && loading_animation "🚀 Menjalankan xl2tpd" || loading_animation "🚀 Starting xl2tpd"
    systemctl enable xl2tpd 2>/dev/null
    systemctl restart xl2tpd 2>/dev/null

    [ "$LANG_CODE" = "id" ] && show_progress_bar 10 "⏳ Menunggu xl2tpd siap..." || show_progress_bar 10 "⏳ Waiting for xl2tpd to be ready..."

    echo ""
    if systemctl is-active --quiet xl2tpd 2>/dev/null; then
        print_success "✅ xl2tpd berjalan!"
    else
        print_warning "⚠ xl2tpd tidak berjalan - cek: systemctl status xl2tpd"
    fi

    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║             L2TP SERVER (BETA) - INSTALLED!              ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║  🔌 Port      : 1701/UDP (L2TP tanpa IPsec)             ║"
    echo "║  🌐 Server IP : ${L2TP_SERVER_IP}                          ║"
    echo "║  🔒 IPsec     : TIDAK DIGUNAKAN (plain L2TP)            ║"
    echo "║  📋 Config    : ${L2TP_CONFIG_DIR}                 ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    [ "$LANG_CODE" = "id" ] \
        && echo "║  ⚡ Langkah selanjutnya: Tambah akun L2TP               ║" \
        || echo "║  ⚡ Next step: Add L2TP accounts                         ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    print_beta "Fitur ini masih BETA - laporkan bug jika ditemukan"
    return 0
}

# --- Tambah Akun L2TP ---
l2tp_add_account() {
    echo ""
    [ "$LANG_CODE" = "id" ] && echo "=== TAMBAH AKUN L2TP ===" || echo "=== ADD L2TP ACCOUNT ==="
    echo ""

    if ! command -v xl2tpd &>/dev/null; then
        [ "$LANG_CODE" = "id" ] && print_error "L2TP Server belum diinstall!" || print_error "L2TP Server is not installed!"
        return 1
    fi

    # Hitung index akun baru
    local next_idx
    next_idx=$(get_next_account_index)
    local fixed_ip
    fixed_ip=$(get_account_ip "$next_idx")

    # Generate username dan password
    local default_user="akun${next_idx}"
    local auto_password
    auto_password=$(generate_l2tp_password_suffix)

    if [ "$LANG_CODE" = "id" ]; then
        print_info "Akun ke-${next_idx} akan mendapat IP fixed: ${fixed_ip}"
        echo ""
        read -p "Username [default: ${default_user}]: " input_user
        [ -z "$input_user" ] && input_user="$default_user"
        echo ""
        print_info "Password akan di-generate otomatis (format: solusidigital-<acak>)"
        read -p "Gunakan password otomatis? (y/n) [default: y]: " use_auto_pass
    else
        print_info "Account #${next_idx} will get fixed IP: ${fixed_ip}"
        echo ""
        read -p "Username [default: ${default_user}]: " input_user
        [ -z "$input_user" ] && input_user="$default_user"
        echo ""
        print_info "Password will be auto-generated (format: solusidigital-<random>)"
        read -p "Use auto password? (y/n) [default: y]: " use_auto_pass
    fi

    local final_password
    if [ "$use_auto_pass" = "n" ] || [ "$use_auto_pass" = "N" ]; then
        [ "$LANG_CODE" = "id" ] && read -p "Masukkan password: " final_password || read -p "Enter password: " final_password
        while [ -z "$final_password" ]; do
            [ "$LANG_CODE" = "id" ] && print_error "Password tidak boleh kosong!" || print_error "Password cannot be empty!"
            read -p "Password: " final_password
        done
    else
        final_password="$auto_password"
    fi

    # Cek apakah username sudah ada
    if grep -q "^${input_user}\s" /etc/ppp/chap-secrets 2>/dev/null; then
        [ "$LANG_CODE" = "id" ] && print_error "Username '${input_user}' sudah ada!" || print_error "Username '${input_user}' already exists!"
        return 1
    fi

    # Tambahkan ke chap-secrets dengan IP fixed
    echo "${input_user}    l2tpserver    ${final_password}    ${fixed_ip}" >> /etc/ppp/chap-secrets

    # Simpan ke file akun kustom kita
    mkdir -p "$L2TP_CONFIG_DIR"
    echo "account${next_idx}|${input_user}|${final_password}|${fixed_ip}" >> "$L2TP_ACCOUNTS_FILE"

    # Restart xl2tpd untuk apply
    systemctl restart xl2tpd 2>/dev/null

    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    [ "$LANG_CODE" = "id" ] && echo "║               AKUN L2TP BERHASIL DIBUAT!                ║" || echo "║               L2TP ACCOUNT CREATED!                     ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    printf "║  👤 Username : %-42s║\n" "${input_user}"
    printf "║  🔑 Password : %-42s║\n" "${final_password}"
    printf "║  🌐 IP Fixed : %-42s║\n" "${fixed_ip}"
    printf "║  🖥  Server  : %-42s║\n" "$(get_server_ip)"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║  🔌 Port L2TP : 1701/UDP                                ║"
    echo "║  🔒 IPsec     : TIDAK (plain L2TP)                     ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    return 0
}

# --- Hapus Akun L2TP ---
l2tp_delete_account() {
    echo ""
    [ "$LANG_CODE" = "id" ] && echo "=== HAPUS AKUN L2TP ===" || echo "=== DELETE L2TP ACCOUNT ==="
    echo ""

    if [ ! -f "$L2TP_ACCOUNTS_FILE" ] || [ ! -s "$L2TP_ACCOUNTS_FILE" ]; then
        [ "$LANG_CODE" = "id" ] && print_warning "Belum ada akun L2TP" || print_warning "No L2TP accounts found"
        return 1
    fi

    # Tampilkan daftar akun
    echo "  No | Username           | IP Fixed"
    echo "  ---|--------------------|---------------"
    local i=0
    while IFS='|' read -r acct_label username password ip; do
        i=$((i+1))
        printf "  %-3s| %-18s | %s\n" "$i" "$username" "$ip"
    done < "$L2TP_ACCOUNTS_FILE"

    echo ""
    [ "$LANG_CODE" = "id" ] && read -p "Masukkan username yang akan dihapus: " del_user || read -p "Enter username to delete: " del_user

    if ! grep -q "|${del_user}|" "$L2TP_ACCOUNTS_FILE" 2>/dev/null; then
        [ "$LANG_CODE" = "id" ] && print_error "Username '${del_user}' tidak ditemukan!" || print_error "Username '${del_user}' not found!"
        return 1
    fi

    # Hapus dari chap-secrets
    sed -i "/^${del_user}\s/d" /etc/ppp/chap-secrets 2>/dev/null

    # Hapus dari file akun kita
    sed -i "/|${del_user}|/d" "$L2TP_ACCOUNTS_FILE" 2>/dev/null

    # Hapus juga routes yang menggunakan akun ini
    if [ -f "$L2TP_ROUTES_FILE" ]; then
        sed -i "/^${del_user}|/d" "$L2TP_ROUTES_FILE" 2>/dev/null
    fi

    systemctl restart xl2tpd 2>/dev/null

    [ "$LANG_CODE" = "id" ] && print_success "✅ Akun '${del_user}' berhasil dihapus" || print_success "✅ Account '${del_user}' deleted successfully"
    return 0
}

# --- List Akun L2TP ---
l2tp_list_accounts() {
    echo ""
    echo "========================================================="
    [ "$LANG_CODE" = "id" ] && echo "            DAFTAR AKUN L2TP (BETA)" || echo "            L2TP ACCOUNT LIST (BETA)"
    echo "========================================================="

    if [ ! -f "$L2TP_ACCOUNTS_FILE" ] || [ ! -s "$L2TP_ACCOUNTS_FILE" ]; then
        [ "$LANG_CODE" = "id" ] && print_warning "Belum ada akun L2TP yang dibuat" || print_warning "No L2TP accounts created yet"
        echo ""
        return 0
    fi

    printf "  %-5s %-20s %-32s %-16s\n" "No" "Username" "Password" "IP Fixed"
    printf "  %-5s %-20s %-32s %-16s\n" "-----" "--------------------" "--------------------------------" "----------------"

    local i=0
    while IFS='|' read -r acct_label username password ip; do
        i=$((i+1))
        printf "  %-5s %-20s %-32s %-16s\n" "$i" "$username" "$password" "$ip"
    done < "$L2TP_ACCOUNTS_FILE"

    echo ""
    echo "  Total: $i akun"
    echo "========================================================="
}

# --- Manage Akun L2TP ---
manage_l2tp_accounts() {
    while true; do
        clear
        echo ""
        echo "========================================================="
        [ "$LANG_CODE" = "id" ] && echo "         KELOLA AKUN L2TP (BETA)" || echo "         MANAGE L2TP ACCOUNTS (BETA)"
        echo "========================================================="
        echo ""
        [ "$LANG_CODE" = "id" ] && echo "  [1] Tambah Akun L2TP" || echo "  [1] Add L2TP Account"
        [ "$LANG_CODE" = "id" ] && echo "  [2] Hapus Akun L2TP" || echo "  [2] Delete L2TP Account"
        [ "$LANG_CODE" = "id" ] && echo "  [3] Lihat Daftar Akun" || echo "  [3] List Accounts"
        echo "  [0] $MSG_BACK"
        echo ""
        echo "========================================================="
        read -p "$MSG_CHOOSE (0-3): " choice
        case $choice in
            1) l2tp_add_account; read -p "$MSG_PRESS_ENTER";;
            2) l2tp_delete_account; read -p "$MSG_PRESS_ENTER";;
            3) l2tp_list_accounts; read -p "$MSG_PRESS_ENTER";;
            0) return;;
            *) print_error "$MSG_INVALID_CHOICE"; read -p "$MSG_PRESS_ENTER";;
        esac
    done
}

# ============================================================
# L2TP IP ROUTE MANAGEMENT (Permanen)
# ============================================================

# --- Tambah IP Route via Akun L2TP ---
l2tp_add_route() {
    echo ""
    [ "$LANG_CODE" = "id" ] && echo "=== TAMBAH IP ROUTE PERMANEN ===" || echo "=== ADD PERMANENT IP ROUTE ==="
    echo ""

    if ! command -v xl2tpd &>/dev/null; then
        [ "$LANG_CODE" = "id" ] && print_error "L2TP Server belum diinstall!" || print_error "L2TP Server is not installed!"
        return 1
    fi

    if [ ! -f "$L2TP_ACCOUNTS_FILE" ] || [ ! -s "$L2TP_ACCOUNTS_FILE" ]; then
        [ "$LANG_CODE" = "id" ] && print_error "Belum ada akun L2TP! Tambah akun dulu." || print_error "No L2TP accounts! Add accounts first."
        return 1
    fi

    # Tampilkan daftar akun beserta IP-nya
    echo ""
    [ "$LANG_CODE" = "id" ] && print_info "Akun L2TP yang tersedia:" || print_info "Available L2TP accounts:"
    echo ""
    printf "  %-5s %-20s %-16s\n" "No" "Username" "IP Fixed (via)"
    printf "  %-5s %-20s %-16s\n" "-----" "--------------------" "----------------"
    local i=0
    local acct_list=()
    while IFS='|' read -r acct_label username password ip; do
        i=$((i+1))
        printf "  %-5s %-20s %-16s\n" "$i" "$username" "$ip"
        acct_list+=("$username:$ip")
    done < "$L2TP_ACCOUNTS_FILE"
    echo ""

    if [ "$LANG_CODE" = "id" ]; then
        read -p "Pilih nomor akun (1-${i}): " acct_choice
    else
        read -p "Choose account number (1-${i}): " acct_choice
    fi

    if ! [[ "$acct_choice" =~ ^[0-9]+$ ]] || [ "$acct_choice" -lt 1 ] || [ "$acct_choice" -gt "$i" ]; then
        print_error "$MSG_INVALID_CHOICE"; return 1
    fi

    local selected="${acct_list[$((acct_choice-1))]}"
    local sel_user="${selected%%:*}"
    local sel_ip="${selected##*:}"

    echo ""
    if [ "$LANG_CODE" = "id" ]; then
        print_info "Route akan diarahkan lewat akun: ${sel_user} (IP: ${sel_ip})"
        echo ""
        echo "Masukkan network tujuan yang ingin diakses dari server:"
        echo "Contoh: 172.10.10.0/24  atau  10.0.0.0/8  atau  192.168.1.0/24"
        read -p "Destination Network (CIDR): " dest_network
    else
        print_info "Route will go through account: ${sel_user} (IP: ${sel_ip})"
        echo ""
        echo "Enter destination network to be reached from server:"
        echo "Example: 172.10.10.0/24  or  10.0.0.0/8  or  192.168.1.0/24"
        read -p "Destination Network (CIDR): " dest_network
    fi

    # Validasi format CIDR sederhana
    if ! echo "$dest_network" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$'; then
        [ "$LANG_CODE" = "id" ] && print_error "Format network tidak valid! Gunakan format CIDR contoh: 192.168.1.0/24" \
            || print_error "Invalid network format! Use CIDR format e.g: 192.168.1.0/24"
        return 1
    fi

    [ "$LANG_CODE" = "id" ] && read -p "Komentar/label untuk route ini (opsional): " route_comment \
        || read -p "Comment/label for this route (optional): " route_comment
    [ -z "$route_comment" ] && route_comment="${sel_user}-to-${dest_network}"

    # Cek duplikat
    if [ -f "$L2TP_ROUTES_FILE" ] && grep -q "|${dest_network}|" "$L2TP_ROUTES_FILE" 2>/dev/null; then
        [ "$LANG_CODE" = "id" ] && print_warning "Route ke ${dest_network} sudah ada! Update?" || print_warning "Route to ${dest_network} already exists! Update?"
        read -p "(y/n): " do_update
        if [ "$do_update" = "y" ] || [ "$do_update" = "Y" ]; then
            sed -i "/|${dest_network}|/d" "$L2TP_ROUTES_FILE"
            # Hapus route lama dari kernel
            ip route del "$dest_network" 2>/dev/null || true
        else
            return 1
        fi
    fi

    # Simpan ke file routes (format: username|via_ip|dest_network|comment)
    echo "${sel_user}|${sel_ip}|${dest_network}|${route_comment}" >> "$L2TP_ROUTES_FILE"

    # Apply route ke kernel sekarang (jika PPP interface sudah ada)
    local ppp_iface
    ppp_iface=$(ip link show | grep ppp | awk '{print $2}' | tr -d ':' | head -1)

    if [ -n "$ppp_iface" ]; then
        ip route add "$dest_network" via "$sel_ip" 2>/dev/null \
            && print_success "✅ Route berhasil ditambahkan ke kernel (aktif sekarang)" \
            || { ip route replace "$dest_network" via "$sel_ip" 2>/dev/null \
                && print_success "✅ Route di-update di kernel" \
                || print_warning "⚠ Route disimpan, akan aktif saat PPP terhubung"; }
    else
        [ "$LANG_CODE" = "id" ] \
            && print_warning "⚠ PPP interface belum aktif. Route akan di-apply saat klien terhubung." \
            || print_warning "⚠ PPP interface not active. Route will be applied when client connects."
    fi

    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    [ "$LANG_CODE" = "id" ] && echo "║             ROUTE PERMANEN BERHASIL DITAMBAH!           ║" || echo "║             PERMANENT ROUTE ADDED SUCCESSFULLY!         ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    printf "║  🌐 Network  : %-42s║\n" "${dest_network}"
    printf "║  ➡  Via IP   : %-42s║\n" "${sel_ip} (${sel_user})"
    printf "║  📝 Label    : %-42s║\n" "${route_comment}"
    echo "╠══════════════════════════════════════════════════════════╣"
    [ "$LANG_CODE" = "id" ] \
        && echo "║  💾 Route disimpan permanen di: ${L2TP_ROUTES_FILE}         ║" \
        || echo "║  💾 Route saved permanently at: ${L2TP_ROUTES_FILE}         ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    return 0
}

# --- Hapus IP Route ---
l2tp_delete_route() {
    echo ""
    [ "$LANG_CODE" = "id" ] && echo "=== HAPUS IP ROUTE ===" || echo "=== DELETE IP ROUTE ==="
    echo ""

    if [ ! -f "$L2TP_ROUTES_FILE" ] || [ ! -s "$L2TP_ROUTES_FILE" ]; then
        [ "$LANG_CODE" = "id" ] && print_warning "Belum ada route yang dikonfigurasi" || print_warning "No routes configured yet"
        return 1
    fi

    echo ""
    [ "$LANG_CODE" = "id" ] && print_info "Daftar route yang ada:" || print_info "Existing routes:"
    echo ""
    printf "  %-5s %-20s %-18s %-18s %s\n" "No" "Via Akun" "Via IP" "Destination" "Label"
    printf "  %-5s %-20s %-18s %-18s %s\n" "-----" "--------------------" "------------------" "------------------" "-----"
    local i=0
    local route_list=()
    while IFS='|' read -r acct_name via_ip dest_net comment; do
        [[ "$acct_name" =~ ^#.*$ ]] && continue
        [ -z "$acct_name" ] && continue
        i=$((i+1))
        printf "  %-5s %-20s %-18s %-18s %s\n" "$i" "$acct_name" "$via_ip" "$dest_net" "$comment"
        route_list+=("${via_ip}:${dest_net}")
    done < "$L2TP_ROUTES_FILE"

    if [ $i -eq 0 ]; then
        [ "$LANG_CODE" = "id" ] && print_warning "Belum ada route" || print_warning "No routes found"
        return 1
    fi

    echo ""
    [ "$LANG_CODE" = "id" ] && read -p "Pilih nomor route yang akan dihapus (1-${i}): " del_choice \
        || read -p "Choose route number to delete (1-${i}): " del_choice

    if ! [[ "$del_choice" =~ ^[0-9]+$ ]] || [ "$del_choice" -lt 1 ] || [ "$del_choice" -gt "$i" ]; then
        print_error "$MSG_INVALID_CHOICE"; return 1
    fi

    local selected="${route_list[$((del_choice-1))]}"
    local del_via="${selected%%:*}"
    local del_net="${selected##*:}"

    # Hapus dari file
    sed -i "/|${del_net}|/d" "$L2TP_ROUTES_FILE"

    # Hapus dari kernel
    ip route del "$del_net" via "$del_via" 2>/dev/null \
        && { [ "$LANG_CODE" = "id" ] && print_success "✅ Route dihapus dari kernel" || print_success "✅ Route removed from kernel"; } \
        || { [ "$LANG_CODE" = "id" ] && print_info "Route sudah tidak aktif di kernel" || print_info "Route was not active in kernel"; }

    [ "$LANG_CODE" = "id" ] && print_success "✅ Route ${del_net} berhasil dihapus dari konfigurasi permanen" \
        || print_success "✅ Route ${del_net} removed from permanent configuration"
    return 0
}

# --- Lihat semua route ---
l2tp_list_routes() {
    echo ""
    echo "========================================================="
    [ "$LANG_CODE" = "id" ] && echo "        IP ROUTE L2TP - KONFIGURASI PERMANEN" || echo "        L2TP IP ROUTES - PERMANENT CONFIGURATION"
    echo "========================================================="

    if [ ! -f "$L2TP_ROUTES_FILE" ] || [ ! -s "$L2TP_ROUTES_FILE" ]; then
        [ "$LANG_CODE" = "id" ] && print_warning "Belum ada route yang dikonfigurasi" || print_warning "No routes configured yet"
        echo "========================================================="
        return 0
    fi

    printf "  %-5s %-18s %-18s %-20s %s\n" "No" "Via Akun" "Via IP" "Destination" "Label"
    printf "  %-5s %-18s %-18s %-20s %s\n" "-----" "------------------" "------------------" "--------------------" "-----"
    local i=0
    while IFS='|' read -r acct_name via_ip dest_net comment; do
        [[ "$acct_name" =~ ^#.*$ ]] && continue
        [ -z "$acct_name" ] && continue
        i=$((i+1))
        # Cek apakah route aktif di kernel
        local status="❌"
        ip route show "$dest_net" via "$via_ip" &>/dev/null 2>&1 && status="✅"
        printf "  %-5s %-18s %-18s %-20s %s %s\n" "$i" "$acct_name" "$via_ip" "$dest_net" "$comment" "$status"
    done < "$L2TP_ROUTES_FILE"

    echo ""
    echo "  (✅ = aktif di kernel / active in kernel)"
    echo ""
    [ "$LANG_CODE" = "id" ] && echo "  Kernel route saat ini:" || echo "  Current kernel routes:"
    echo "  -----------------------------------------"
    ip route show | grep -v "^default" | head -20 || true
    echo "========================================================="
}

# --- Apply semua route sekarang ---
l2tp_apply_routes() {
    echo ""
    [ "$LANG_CODE" = "id" ] && loading_animation "🔄 Menerapkan semua route dari konfigurasi" || loading_animation "🔄 Applying all routes from configuration"

    if [ ! -f "$L2TP_ROUTES_FILE" ] || [ ! -s "$L2TP_ROUTES_FILE" ]; then
        [ "$LANG_CODE" = "id" ] && print_warning "Tidak ada route untuk di-apply" || print_warning "No routes to apply"
        return 0
    fi

    local applied=0
    local failed=0
    while IFS='|' read -r acct_name via_ip dest_net comment; do
        [[ "$acct_name" =~ ^#.*$ ]] && continue
        [ -z "$acct_name" ] && continue
        if ip route add "$dest_net" via "$via_ip" 2>/dev/null || ip route replace "$dest_net" via "$via_ip" 2>/dev/null; then
            print_success "✅ Route ${dest_net} via ${via_ip} applied"
            applied=$((applied+1))
        else
            print_warning "⚠ Gagal apply route ${dest_net} via ${via_ip} (mungkin PPP belum terhubung)"
            failed=$((failed+1))
        fi
    done < "$L2TP_ROUTES_FILE"

    echo ""
    [ "$LANG_CODE" = "id" ] \
        && print_info "Selesai: ${applied} route berhasil, ${failed} gagal" \
        || print_info "Done: ${applied} routes applied, ${failed} failed"
}

# --- Manage IP Routes ---
manage_l2tp_routes() {
    while true; do
        clear
        echo ""
        echo "========================================================="
        [ "$LANG_CODE" = "id" ] && echo "       KELOLA IP ROUTE L2TP (BETA)" || echo "       MANAGE L2TP IP ROUTES (BETA)"
        echo "========================================================="
        echo ""
        [ "$LANG_CODE" = "id" ] && echo "  [1] Tambah IP Route Permanen" || echo "  [1] Add Permanent IP Route"
        [ "$LANG_CODE" = "id" ] && echo "  [2] Hapus IP Route" || echo "  [2] Delete IP Route"
        [ "$LANG_CODE" = "id" ] && echo "  [3] Lihat Semua Route" || echo "  [3] View All Routes"
        [ "$LANG_CODE" = "id" ] && echo "  [4] Apply Semua Route Sekarang" || echo "  [4] Apply All Routes Now"
        echo "  [0] $MSG_BACK"
        echo ""
        echo "========================================================="
        read -p "$MSG_CHOOSE (0-4): " choice
        case $choice in
            1) l2tp_add_route; read -p "$MSG_PRESS_ENTER";;
            2) l2tp_delete_route; read -p "$MSG_PRESS_ENTER";;
            3) l2tp_list_routes; read -p "$MSG_PRESS_ENTER";;
            4) l2tp_apply_routes; read -p "$MSG_PRESS_ENTER";;
            0) return;;
            *) print_error "$MSG_INVALID_CHOICE"; read -p "$MSG_PRESS_ENTER";;
        esac
    done
}

# --- Status L2TP ---
show_l2tp_status() {
    show_installation_header
    echo -e "${CYAN}=== L2TP SERVER STATUS (BETA) ===${NC}"
    echo ""

    # Status service
    echo "---------------------------------------------------------"
    if command -v xl2tpd &>/dev/null; then
        print_success "✅ xl2tpd: Terinstall / Installed"
        if systemctl is-active --quiet xl2tpd 2>/dev/null; then
            print_success "✅ xl2tpd service: Berjalan / Running"
        else
            print_warning "⚠  xl2tpd service: Tidak berjalan / Not running"
            echo "     Run: systemctl start xl2tpd"
        fi
    else
        print_error "❌ xl2tpd: Tidak terinstall / Not installed"
    fi

    echo ""
    # PPP interfaces aktif
    echo "---------------------------------------------------------"
    [ "$LANG_CODE" = "id" ] && echo "  PPP Interfaces aktif (klien terhubung):" || echo "  Active PPP Interfaces (connected clients):"
    local ppp_count
    ppp_count=$(ip link show 2>/dev/null | grep -c "ppp" || echo "0")
    if [ "$ppp_count" -gt 0 ]; then
        ip link show | grep "ppp" | while read -r line; do
            echo "    $line"
        done
    else
        [ "$LANG_CODE" = "id" ] && echo "    Tidak ada klien terhubung" || echo "    No clients connected"
    fi

    echo ""
    # Daftar akun
    echo "---------------------------------------------------------"
    l2tp_list_accounts

    echo ""
    # Daftar route
    echo "---------------------------------------------------------"
    l2tp_list_routes

    echo ""
    # IP Forwarding status
    echo "---------------------------------------------------------"
    local ipfwd
    ipfwd=$(cat /proc/sys/net/ipv4/ip_forward)
    if [ "$ipfwd" = "1" ]; then
        print_success "✅ IP Forwarding: Aktif / Active"
    else
        print_warning "⚠  IP Forwarding: Nonaktif / Inactive"
        echo "     Run: sysctl -w net.ipv4.ip_forward=1"
    fi

    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║              L2TP QUICK REFERENCE (BETA)                ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    printf "║  🌐 Server IP  : %-40s║\n" "$(get_server_ip)"
    echo "║  🔌 L2TP Port  : 1701/UDP                               ║"
    echo "║  🔒 IPsec      : TIDAK / NO (Plain L2TP)               ║"
    echo "║  📋 Config     : /etc/xl2tpd/xl2tpd.conf               ║"
    echo "║  📋 PPP Opts   : /etc/ppp/options.xl2tpd               ║"
    echo "║  📋 Accounts   : /etc/ppp/chap-secrets                 ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║  📜 Logs       : /var/log/xl2tpd.log                   ║"
    echo "║  📜 PPP Logs   : /var/log/syslog                       ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    print_beta "Fitur BETA - laporkan bug ke maintainer"
}

# --- Uninstall L2TP ---
uninstall_l2tp() {
    echo ""
    if [ "$LANG_CODE" = "id" ]; then
        print_warning "PERINGATAN: Ini akan menghapus L2TP Server, semua akun, dan routes!"
        read -p "Apakah Anda yakin? (y/n): " confirm
    else
        print_warning "WARNING: This will remove L2TP Server, all accounts, and routes!"
        read -p "Are you sure? (y/n): " confirm
    fi
    [ "$confirm" != "y" ] && [ "$confirm" != "Y" ] && { [ "$LANG_CODE" = "id" ] && print_info "Uninstall dibatalkan" || print_info "Uninstall cancelled"; return 1; }

    echo ""
    [ "$LANG_CODE" = "id" ] && loading_animation "🛑 Menghentikan xl2tpd" || loading_animation "🛑 Stopping xl2tpd"
    systemctl stop xl2tpd 2>/dev/null
    systemctl disable xl2tpd 2>/dev/null
    systemctl stop l2tp-routes 2>/dev/null
    systemctl disable l2tp-routes 2>/dev/null

    [ "$LANG_CODE" = "id" ] && loading_animation "📦 Menghapus paket xl2tpd" || loading_animation "📦 Removing xl2tpd packages"
    safe_apt_get apt-get purge -y xl2tpd 2>/dev/null

    [ "$LANG_CODE" = "id" ] && loading_animation "🔥 Menghapus iptables rules L2TP" || loading_animation "🔥 Removing L2TP iptables rules"
    MAIN_IFACE=$(ip route | grep default | awk '{print $5}' | head -1)
    [ -n "$MAIN_IFACE" ] && {
        iptables -t nat -D POSTROUTING -s ${L2TP_IP_POOL_BASE}.0/24 -o "$MAIN_IFACE" -j MASQUERADE 2>/dev/null || true
        iptables -D FORWARD -s ${L2TP_IP_POOL_BASE}.0/24 -j ACCEPT 2>/dev/null || true
        iptables -D FORWARD -d ${L2TP_IP_POOL_BASE}.0/24 -j ACCEPT 2>/dev/null || true
    }

    # Hapus routes dari kernel
    if [ -f "$L2TP_ROUTES_FILE" ]; then
        while IFS='|' read -r acct_name via_ip dest_net comment; do
            [ -z "$dest_net" ] && continue
            ip route del "$dest_net" 2>/dev/null || true
        done < "$L2TP_ROUTES_FILE"
    fi

    [ "$LANG_CODE" = "id" ] && loading_animation "🗑️  Menghapus konfigurasi" || loading_animation "🗑️  Removing configuration"
    rm -f /etc/xl2tpd/xl2tpd.conf /etc/ppp/options.xl2tpd
    rm -f /etc/systemd/system/l2tp-routes.service
    rm -rf "$L2TP_CONFIG_DIR"

    # Hapus entri L2TP dari chap-secrets (semua baris non-comment)
    if [ -f /etc/ppp/chap-secrets ]; then
        # Backup dulu
        cp /etc/ppp/chap-secrets /etc/ppp/chap-secrets.l2tp-backup 2>/dev/null
        # Kembalikan ke state minimal
        cat > /etc/ppp/chap-secrets <<'EOF'
# Secrets for authentication using CHAP
# client        server  secret          IP addresses
EOF
    fi

    systemctl daemon-reload

    [ "$LANG_CODE" = "id" ] && print_info "Membersihkan paket tidak terpakai..." || print_info "Cleaning unused packages..."
    safe_apt_get apt-get autoremove -y 2>/dev/null

    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    [ "$LANG_CODE" = "id" ] && echo "║            L2TP SERVER BERHASIL DIHAPUS! ✅             ║" || echo "║           L2TP SERVER SUCCESSFULLY REMOVED! ✅          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    return 0
}

# ============================================================
# SHOW STATUS
# ============================================================
show_status() {
    show_installation_header
    [ "$LANG_CODE" = "id" ] && animated_text "📊 Memeriksa status layanan GenieACS..." 0.05 || animated_text "📊 Checking GenieACS services status..." 0.05

    show_system_info
    SERVER_IP=$(get_server_ip)

    [ "$LANG_CODE" = "id" ] && loading_animation "🐳 Memeriksa status Docker" || loading_animation "🐳 Checking Docker status"

    if command -v docker &> /dev/null; then
        [ "$LANG_CODE" = "id" ] && print_success "✅ Docker: Terinstall" || print_success "✅ Docker: Installed"
        docker --version
        docker compose version &> /dev/null && docker compose version || (docker-compose --version &> /dev/null && docker-compose --version)

        echo ""
        [ "$LANG_CODE" = "id" ] && loading_animation "📋 Memeriksa status container" || loading_animation "📋 Checking container status"
        echo ""
        echo "========================================"
        [ "$LANG_CODE" = "id" ] && echo "         STATUS CONTAINER" || echo "         CONTAINER STATUS"
        echo "========================================"

        if docker inspect genieacs >/dev/null 2>&1 && [ "$(docker inspect -f '{{.State.Running}}' genieacs 2>/dev/null)" = "true" ]; then
            [ "$LANG_CODE" = "id" ] && print_success "✅ GenieACS: Berjalan" || print_success "✅ GenieACS: Running"
            echo "  🌐 URL: http://${SERVER_IP}:3000"
            echo "  👤 admin / admin"
            [ "$LANG_CODE" = "id" ] && echo "  🔌 Port: 3000, 7547, 7557, 7567" || echo "  🔌 Ports: 3000, 7547, 7557, 7567"
        else
            [ "$LANG_CODE" = "id" ] && print_warning "⚠️  GenieACS: Tidak Berjalan" || print_warning "⚠️  GenieACS: Not Running"
        fi

        echo ""

        if docker inspect genieacs-panel-api >/dev/null 2>&1 && [ "$(docker inspect -f '{{.State.Running}}' genieacs-panel-api 2>/dev/null)" = "true" ]; then
            [ "$LANG_CODE" = "id" ] && print_success "✅ GenieACS Panel: Berjalan" || print_success "✅ GenieACS Panel: Running"
            echo "  🌐 URL: http://${SERVER_IP}:1997"
            echo "  👤 admin / solusidigitalnet"
            [ "$LANG_CODE" = "id" ] && echo "  🔌 Port: 1997" || echo "  🔌 Port: 1997"
        else
            [ "$LANG_CODE" = "id" ] && print_warning "⚠️  GenieACS Panel: Tidak Berjalan" || print_warning "⚠️  GenieACS Panel: Not Running"
        fi

        echo ""

        if docker inspect customerportal >/dev/null 2>&1 && [ "$(docker inspect -f '{{.State.Running}}' customerportal 2>/dev/null)" = "true" ]; then
            [ "$LANG_CODE" = "id" ] && print_success "✅ Customer Portal: Berjalan" || print_success "✅ Customer Portal: Running"
            echo "  🌐 URL: http://${SERVER_IP}:1998"
            [ "$LANG_CODE" = "id" ] && echo "  🔌 Port: 1998" || echo "  🔌 Port: 1998"
        else
            [ "$LANG_CODE" = "id" ] && print_warning "⚠️  Customer Portal: Tidak Berjalan" || print_warning "⚠️  Customer Portal: Not Running"
        fi

        RUNNING_CONTAINERS=$(docker ps -q 2>/dev/null | wc -l)
        if [ "$RUNNING_CONTAINERS" -gt 0 ]; then
            echo ""
            [ "$LANG_CODE" = "id" ] && loading_animation "📈 Mengumpulkan statistik resource usage" || loading_animation "📈 Collecting resource usage statistics"
            echo ""
            echo "========================================"
            echo "      RESOURCE USAGE (DOCKER STATS)"
            echo "========================================"
            echo ""
            timeout 10 docker stats --no-stream 2>/dev/null || { [ "$LANG_CODE" = "id" ] && print_warning "⚠️  Tidak dapat menampilkan stats" || print_warning "⚠️  Cannot display stats"; }
        fi
    else
        [ "$LANG_CODE" = "id" ] && print_error "❌ Docker: Tidak Terinstall" || print_error "❌ Docker: Not Installed"
    fi

    echo ""
    echo "========================================"
    [ "$LANG_CODE" = "id" ] && echo "       STATUS L2TP SERVER (BETA)" || echo "       L2TP SERVER STATUS (BETA)"
    echo "========================================"
    if command -v xl2tpd &>/dev/null; then
        if systemctl is-active --quiet xl2tpd 2>/dev/null; then
            [ "$LANG_CODE" = "id" ] && print_success "✅ L2TP Server: Berjalan (port 1701/UDP)" || print_success "✅ L2TP Server: Running (port 1701/UDP)"
        else
            [ "$LANG_CODE" = "id" ] && print_warning "⚠️  L2TP Server: Terinstall tapi tidak berjalan" || print_warning "⚠️  L2TP Server: Installed but not running"
        fi
        # Jumlah akun
        local acct_count=0
        [ -f "$L2TP_ACCOUNTS_FILE" ] && acct_count=$(grep -c "^account" "$L2TP_ACCOUNTS_FILE" 2>/dev/null || echo "0")
        [ "$LANG_CODE" = "id" ] && print_info "  Total Akun L2TP: ${acct_count}" || print_info "  Total L2TP Accounts: ${acct_count}"
    else
        [ "$LANG_CODE" = "id" ] && print_warning "⚠️  L2TP Server: Tidak Terinstall" || print_warning "⚠️  L2TP Server: Not Installed"
    fi

    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    [ "$LANG_CODE" = "id" ] && echo "║                   STATUS CHECK SELESAI                  ║" || echo "║                  STATUS CHECK COMPLETE                  ║"
    echo "╚══════════════════════════════════════════════════════════╝"
}

# ============================================================
# MENUS
# ============================================================
show_menu() {
    clear
    echo ""
    echo "    ███████╗ ██████╗ ██╗     ██╗   ██╗███████╗██╗"
    echo "    ██╔════╝██╔═══██╗██║     ██║   ██║██╔════╝██║"
    echo "    ███████╗██║   ██║██║     ██║   ██║███████╗██║"
    echo "    ╚════██║██║   ██║██║     ██║   ██║╚════██║██║"
    echo "    ███████║╚██████╔╝███████╗╚██████╔╝███████║██║"
    echo "    ╚══════╝ ╚═════╝ ╚══════╝ ╚═════╝ ╚══════╝╚═╝"
    echo ""
    echo "    ██████╗ ██╗ ██████╗ ██╗████████╗ █████╗ ██╗"
    echo "    ██╔══██╗██║██╔════╝ ██║╚══██╔══╝██╔══██╗██║"
    echo "    ██║  ██║██║██║  ███╗██║   ██║   ███████║██║"
    echo "    ██║  ██║██║██║   ██║██║   ██║   ██╔══██║██║"
    echo "    ██████╔╝██║╚██████╔╝██║   ██║   ██║  ██║███████╗"
    echo "    ╚═════╝ ╚═╝ ╚═════╝ ╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝"
    echo ""
    echo "            ███╗   ██╗███████╗████████╗"
    echo "            ████╗  ██║██╔════╝╚══██╔══╝"
    echo "            ██╔██╗ ██║█████╗     ██║"
    echo "            ██║╚██╗██║██╔══╝     ██║"
    echo "            ██║ ╚████║███████╗   ██║"
    echo "            ╚═╝  ╚═══╝╚══════╝   ╚═╝"
    echo ""
    echo "========================================================="
    echo "  $MSG_TITLE v${INSTALLER_VERSION}"
    echo "========================================================="
    echo ""
    echo "  [1] $MENU_DOCKER"
    echo "  [2] $MENU_GENIEACS"
    echo "  [3] $MENU_PANEL"
    echo "  [4] $MENU_CUSTOMER_PORTAL"
    echo -e "  [5] ${CYAN}$MENU_L2TP${NC}"
    echo "  [6] $MENU_STATUS"
    echo "  [7] $MENU_EXIT"
    echo ""
    echo "========================================================="
}

show_docker_menu() {
    clear; echo ""; echo "========================================================="; echo "                  $MENU_DOCKER"; echo "========================================================="; echo ""
    echo "  [1] $SUBMENU_INSTALL_DOCKER"; echo "  [2] $SUBMENU_UNINSTALL_DOCKER"; echo "  [0] $MSG_BACK"; echo ""; echo "========================================================="
}

show_genieacs_menu() {
    clear; echo ""; echo "========================================================="; echo "                  $MENU_GENIEACS"; echo "========================================================="; echo ""
    echo "  [1] $SUBMENU_INSTALL_GENIEACS"; echo "  [2] $SUBMENU_CONFIG_GENIEACS"; echo "  [3] $SUBMENU_UNINSTALL_GENIEACS"; echo "  [0] $MSG_BACK"; echo ""; echo "========================================================="
}

show_panel_menu() {
    clear; echo ""; echo "========================================================="; echo "                  $MENU_PANEL"; echo "========================================================="; echo ""
    echo "  [1] $SUBMENU_INSTALL_PANEL"; echo "  [2] $SUBMENU_UNINSTALL_PANEL"; echo "  [0] $MSG_BACK"; echo ""; echo "========================================================="
}

show_customer_portal_menu() {
    clear; echo ""; echo "========================================================="; echo "                  $MENU_CUSTOMER_PORTAL"; echo "========================================================="; echo ""
    echo "  [1] $SUBMENU_INSTALL_CUSTOMER_PORTAL"; echo "  [2] $SUBMENU_UNINSTALL_CUSTOMER_PORTAL"; echo "  [0] $MSG_BACK"; echo ""; echo "========================================================="
}

show_l2tp_menu() {
    clear
    echo ""
    echo -e "${CYAN}=========================================================${NC}"
    echo -e "${CYAN}           $MENU_L2TP${NC}"
    echo -e "${CYAN}   L2TP tanpa IPsec / L2TP without IPsec${NC}"
    echo -e "${CYAN}=========================================================${NC}"
    echo ""
    echo "  [1] $SUBMENU_INSTALL_L2TP"
    echo "  [2] $SUBMENU_MANAGE_L2TP_ACCOUNTS"
    echo "  [3] $SUBMENU_MANAGE_L2TP_ROUTES"
    echo "  [4] $SUBMENU_SHOW_L2TP_STATUS"
    echo "  [5] $SUBMENU_UNINSTALL_L2TP"
    echo "  [0] $MSG_BACK"
    echo ""
    echo -e "${CYAN}=========================================================${NC}"
    print_beta "Fitur ini masih dalam tahap percobaan (BETA)"
    echo ""
}

docker_menu() {
    while true; do
        show_docker_menu
        read -p "$MSG_CHOOSE (0-2): " choice
        case $choice in
            1) install_docker && print_success "$MSG_PROCESS_COMPLETE" || print_error "$MSG_PROCESS_FAILED"; read -p "$MSG_PRESS_ENTER";;
            2) uninstall_docker && print_success "$MSG_PROCESS_COMPLETE" || print_error "$MSG_PROCESS_FAILED"; read -p "$MSG_PRESS_ENTER";;
            0) return;;
            *) print_error "$MSG_INVALID_CHOICE"; read -p "$MSG_PRESS_ENTER";;
        esac
    done
}

genieacs_menu() {
    while true; do
        show_genieacs_menu
        read -p "$MSG_CHOOSE (0-3): " choice
        case $choice in
            1) install_genieacs && print_success "$MSG_PROCESS_COMPLETE" || print_error "$MSG_PROCESS_FAILED"; read -p "$MSG_PRESS_ENTER";;
            2) configure_genieacs && print_success "$MSG_PROCESS_COMPLETE" || print_error "$MSG_PROCESS_FAILED"; read -p "$MSG_PRESS_ENTER";;
            3) uninstall_genieacs && print_success "$MSG_PROCESS_COMPLETE" || print_error "$MSG_PROCESS_FAILED"; read -p "$MSG_PRESS_ENTER";;
            0) return;;
            *) print_error "$MSG_INVALID_CHOICE"; read -p "$MSG_PRESS_ENTER";;
        esac
    done
}

panel_menu() {
    while true; do
        show_panel_menu
        read -p "$MSG_CHOOSE (0-2): " choice
        case $choice in
            1) install_genieacs_panel && print_success "$MSG_PROCESS_COMPLETE" || print_error "$MSG_PROCESS_FAILED"; read -p "$MSG_PRESS_ENTER";;
            2) uninstall_genieacs_panel && print_success "$MSG_PROCESS_COMPLETE" || print_error "$MSG_PROCESS_FAILED"; read -p "$MSG_PRESS_ENTER";;
            0) return;;
            *) print_error "$MSG_INVALID_CHOICE"; read -p "$MSG_PRESS_ENTER";;
        esac
    done
}

customer_portal_menu() {
    while true; do
        show_customer_portal_menu
        read -p "$MSG_CHOOSE (0-2): " choice
        case $choice in
            1) install_customer_portal && print_success "$MSG_PROCESS_COMPLETE" || print_error "$MSG_PROCESS_FAILED"; read -p "$MSG_PRESS_ENTER";;
            2) uninstall_customer_portal && print_success "$MSG_PROCESS_COMPLETE" || print_error "$MSG_PROCESS_FAILED"; read -p "$MSG_PRESS_ENTER";;
            0) return;;
            *) print_error "$MSG_INVALID_CHOICE"; read -p "$MSG_PRESS_ENTER";;
        esac
    done
}

l2tp_menu() {
    while true; do
        show_l2tp_menu
        read -p "$MSG_CHOOSE (0-5): " choice
        case $choice in
            1) install_l2tp && print_success "$MSG_PROCESS_COMPLETE" || print_error "$MSG_PROCESS_FAILED"; read -p "$MSG_PRESS_ENTER";;
            2) manage_l2tp_accounts;;
            3) manage_l2tp_routes;;
            4) show_l2tp_status; read -p "$MSG_PRESS_ENTER";;
            5) uninstall_l2tp && print_success "$MSG_PROCESS_COMPLETE" || print_error "$MSG_PROCESS_FAILED"; read -p "$MSG_PRESS_ENTER";;
            0) return;;
            *) print_error "$MSG_INVALID_CHOICE"; read -p "$MSG_PRESS_ENTER";;
        esac
    done
}

main() {
    while true; do
        show_menu
        read -p "$MSG_CHOOSE (1-7): " choice
        case $choice in
            1) docker_menu;;
            2) genieacs_menu;;
            3) panel_menu;;
            4) customer_portal_menu;;
            5) l2tp_menu;;
            6) show_status; read -p "$MSG_PRESS_ENTER";;
            7) print_info "$MSG_THANK_YOU"; exit 0;;
            *) print_error "$MSG_INVALID_CHOICE"; read -p "$MSG_PRESS_ENTER";;
        esac
    done
}

# ============================================================
# ROOT CHECK
# ============================================================
if [ "$EUID" -ne 0 ]; then
    clear; echo ""
    echo "========================================================="
    [ "$LANG_CODE" = "id" ] && echo -e "${RED}ERROR: Script harus dijalankan sebagai ROOT!${NC}" || echo -e "${RED}ERROR: Script must be run as ROOT!${NC}"
    echo "========================================================="
    echo ""
    if [ "$LANG_CODE" = "id" ]; then
        echo "Gunakan salah satu cara berikut:"
        echo "  1. sudo bash $0"
        echo "  2. su - root, lalu jalankan: bash $0"
        echo ""
        echo "Atau install langsung via:"
    else
        echo "Use one of the following methods:"
        echo "  1. sudo bash $0"
        echo "  2. su - root, then run: bash $0"
        echo ""
        echo "Or install directly via:"
    fi
    echo "  bash <(curl -fsSL https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/install.sh)"
    echo ""
    echo "========================================================="
    echo ""
    exit 1
fi

main