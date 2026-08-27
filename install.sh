#!/bin/bash
# Docker Hub account
DOCKER_HUB_USER="solusidigitalnet"

# ============================================================
# CONFIGURATION - GitHub Repository
# ============================================================
GITHUB_USER="zlabkeeb"
GITHUB_REPO="DidotsServ"
GITHUB_BRANCH="main"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}"
DB_URL="${GITHUB_RAW_BASE}/db"

INSTALLER_VERSION="6"

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

        PREFLIGHT_TITLE="CEK KESIAPAN SISTEM"
        PREFLIGHT_CHECKING="Memeriksa kesiapan sistem..."
        PREFLIGHT_OS="Sistem Operasi"
        PREFLIGHT_ARCH="Arsitektur"
        PREFLIGHT_INTERNET="Koneksi internet"
        PREFLIGHT_DEPS="Dependencies"
        PREFLIGHT_DOCKER="Docker"
        PREFLIGHT_PASS="LOLOS"
        PREFLIGHT_FAIL="GAGAL"
        PREFLIGHT_INSTALL_DOCKER_PROMPT="Docker belum terinstall. Install Docker sekarang?"
        DOCKER_LOGIN_TITLE="AKSES TOKEN DIBUTUHKAN"
        DOCKER_LOGIN_PROMPT="Masukkan Akses Token"
        DOCKER_LOGIN_SUCCESS="Akses token valid"
        DOCKER_LOGIN_FAILED="Akses token tidak valid"
        DOCKER_LOGIN_RETRY="Token tidak valid, coba lagi"
        DOCKER_LOGIN_EXIT="Gagal setelah 3 percobaan. Keluar."
        ACCESS_TOKEN_CONTACT="Hubungi saya untuk mendapatkan Akses Token:"
        ACCESS_TOKEN_DONATE="Silakan donate untuk mendapatkan akses token dan hubungi kontak di atas."
        DOCKER_LOGOUT="Logout dari Docker Hub"
        DOCKER_LOGOUT_DONE="Berhasil logout dari Docker Hub"
        DOCKER_LOGOUT_NONE="Tidak ada sesi Docker Hub untuk di-logout"
        EXIT_MESSAGE="Keluar dari installer"

        MENU_DOCKER="Docker"
        MENU_GENIEACS="GenieACS"
        MENU_PANEL="GenieACS Panel"
        MENU_CUSTOMER_PORTAL="Customer Portal"
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

        PREFLIGHT_TITLE="SYSTEM READINESS CHECK"
        PREFLIGHT_CHECKING="Checking system readiness..."
        PREFLIGHT_OS="Operating System"
        PREFLIGHT_ARCH="Architecture"
        PREFLIGHT_INTERNET="Internet connection"
        PREFLIGHT_DEPS="Dependencies"
        PREFLIGHT_DOCKER="Docker"
        PREFLIGHT_PASS="PASS"
        PREFLIGHT_FAIL="FAIL"
        PREFLIGHT_INSTALL_DOCKER_PROMPT="Docker is not installed. Install Docker now?"
        DOCKER_LOGIN_TITLE="ACCESS TOKEN REQUIRED"
        DOCKER_LOGIN_PROMPT="Enter Access Token"
        DOCKER_LOGIN_SUCCESS="Access token valid"
        DOCKER_LOGIN_FAILED="Access token invalid"
        DOCKER_LOGIN_RETRY="Invalid token, please try again"
        DOCKER_LOGIN_EXIT="Failed after 3 attempts. Exiting."
        ACCESS_TOKEN_CONTACT="Contact me to get an Access Token:"
        ACCESS_TOKEN_DONATE="Please donate to get an access token and contact me above."
        DOCKER_LOGOUT="Logging out from Docker Hub"
        DOCKER_LOGOUT_DONE="Successfully logged out from Docker Hub"
        DOCKER_LOGOUT_NONE="No Docker Hub session to logout"
        EXIT_MESSAGE="Exiting installer"

        MENU_DOCKER="Docker"
        MENU_GENIEACS="GenieACS"
        MENU_PANEL="GenieACS Panel"
        MENU_CUSTOMER_PORTAL="Customer Portal"
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
        ;;
esac

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}[${MSG_SUCCESS}]${NC} $1"; }
print_error()   { echo -e "${RED}[${MSG_ERROR}]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[${MSG_WARNING}]${NC} $1"; }
print_info()    { echo -e "${BLUE}[${MSG_INFO}]${NC} $1"; }

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
    local max_retries=3
    local retry=0

    while [ $retry -lt $max_retries ]; do
        if wait_for_dpkg_lock; then
            "$@" && return 0
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
show_progress_bar() {
    local duration=$1
    local message=$2
    local bar_length=40

    [ "$duration" -lt 1 ] 2>/dev/null && duration=1
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

# ============================================================
# PREFLIGHT CHECK
# ============================================================
preflight_check() {
    show_installation_header
    [ "$LANG_CODE" = "id" ] && animated_text "🔍 $PREFLIGHT_CHECKING" 0.05 || animated_text "🔍 $PREFLIGHT_CHECKING" 0.05

    local fatal=0
    local check_name check_value check_status

    echo ""
    echo "========================================================="
    echo "                  $PREFLIGHT_TITLE"
    echo "========================================================="
    echo ""

    # OS
    OS_INFO=$(detect_os)
    IFS=':' read -r OS OS_VERSION OS_CODENAME IS_WSL DOCKER_BASE_OS <<< "$OS_INFO"
    if [ "$OS" != "unknown" ]; then
        check_value="$OS $OS_VERSION ($OS_CODENAME)"
        check_status="$PREFLIGHT_PASS"
    else
        check_value="$OS"
        check_status="$PREFLIGHT_FAIL"
        fatal=$((fatal + 1))
    fi
    printf "  %-30s %-25s [ %s ]\n" "$PREFLIGHT_OS" "$check_value" "$check_status"

    # Architecture
    ARCH=$(detect_architecture)
    if [ "$ARCH" != "unknown" ]; then
        check_value="$ARCH"
        check_status="$PREFLIGHT_PASS"
    else
        check_value="$(uname -m)"
        check_status="$PREFLIGHT_FAIL"
        fatal=$((fatal + 1))
    fi
    printf "  %-30s %-25s [ %s ]\n" "$PREFLIGHT_ARCH" "$check_value" "$check_status"

    # Internet (multi-endpoint check for reliability)
    local internet_ok=false
    local endpoints=("https://hub.docker.com/" "https://www.google.com/" "https://www.cloudflare.com/")
    for endpoint in "${endpoints[@]}"; do
        if curl -fsSL --max-time 10 "$endpoint" > /dev/null 2>&1; then
            internet_ok=true
            break
        fi
    done
    if [ "$internet_ok" = true ]; then
        check_value="OK"
        check_status="$PREFLIGHT_PASS"
    else
        check_value="No connection"
        check_status="$PREFLIGHT_FAIL"
        fatal=$((fatal + 1))
    fi
    printf "  %-30s %-25s [ %s ]\n" "$PREFLIGHT_INTERNET" "$check_value" "$check_status"

    # Dependencies
    local deps=("curl" "openssl" "gpg" "awk" "free" "fuser")
    local missing_deps=()
    for dep in "${deps[@]}"; do
        command -v "$dep" &> /dev/null || missing_deps+=("$dep")
    done
    if [ ${#missing_deps[@]} -eq 0 ]; then
        check_value="OK"
        check_status="$PREFLIGHT_PASS"
    else
        check_value="missing: ${missing_deps[*]}"
        check_status="$PREFLIGHT_FAIL"
        [ "$LANG_CODE" = "id" ] && print_warning "Menginstall dependencies yang kurang..." || print_warning "Installing missing dependencies..."
        safe_apt_get apt-get update && safe_apt_get apt-get install -y curl openssl gnupg coreutils procps psmisc
        # Re-check
        missing_deps=()
        for dep in "${deps[@]}"; do
            command -v "$dep" &> /dev/null || missing_deps+=("$dep")
        done
        if [ ${#missing_deps[@]} -eq 0 ]; then
            check_value="OK"
            check_status="$PREFLIGHT_PASS"
        else
            check_value="still missing: ${missing_deps[*]}"
            check_status="$PREFLIGHT_FAIL"
            fatal=$((fatal + 1))
        fi
    fi
    printf "  %-30s %-25s [ %s ]\n" "$PREFLIGHT_DEPS" "$check_value" "$check_status"

    # Docker (optional at this stage but reported)
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        check_value="OK"
        check_status="$PREFLIGHT_PASS"
    elif command -v docker &> /dev/null; then
        check_value="installed, not running"
        check_status="$PREFLIGHT_FAIL"
    else
        check_value="not installed"
        check_status="$PREFLIGHT_FAIL"
    fi
    printf "  %-30s %-25s [ %s ]\n" "$PREFLIGHT_DOCKER" "$check_value" "$check_status"

    echo ""
    echo "========================================================="

    if [ $fatal -gt 0 ]; then
        [ "$LANG_CODE" = "id" ] && print_error "$fatal cek kesiapan gagal. Installer dihentikan." || print_error "$fatal readiness checks failed. Installer aborted."
        echo "========================================================="
        echo ""
        return 1
    fi

    [ "$LANG_CODE" = "id" ] && print_success "Semua cek kesiapan lolos!" || print_success "All readiness checks passed!"
    echo "========================================================="
    echo ""
    return 0
}

# ============================================================
# DOCKER HUB LOGIN / LOGOUT
# ============================================================
dockerhub_login() {
    show_installation_header
    [ "$LANG_CODE" = "id" ] && animated_text "🔐 $DOCKER_LOGIN_TITLE" 0.05 || animated_text "🔐 $DOCKER_LOGIN_TITLE" 0.05

    echo ""
    echo "========================================================="
    echo "                  $DOCKER_LOGIN_TITLE"
    echo "========================================================="
    echo ""
    echo "  $ACCESS_TOKEN_CONTACT"
    echo "    Facebook : vheriyan irvansyah (facebook.com/veriyan404)"
    echo "    WhatsApp : 0851-7671-5549"
    echo ""
    echo "  $ACCESS_TOKEN_DONATE"
    echo "========================================================="
    echo ""
    local attempts=0
    local max_attempts=3

    while [ $attempts -lt $max_attempts ]; do
        local token
        read -p "${DOCKER_LOGIN_PROMPT}: " token

        if [ -z "$token" ]; then
            [ "$LANG_CODE" = "id" ] && print_error "Access token tidak boleh kosong" || print_error "Access token cannot be empty"
            attempts=$((attempts + 1))
            [ $attempts -lt $max_attempts ] && { [ "$LANG_CODE" = "id" ] && print_warning "$DOCKER_LOGIN_RETRY" || print_warning "$DOCKER_LOGIN_RETRY"; }
            continue
        fi

        if echo "$token" | docker login -u "$DOCKER_HUB_USER" --password-stdin &> /dev/null; then
            DOCKER_HUB_LOGGED_IN=true
            unset token
            [ "$LANG_CODE" = "id" ] && print_success "$DOCKER_LOGIN_SUCCESS" || print_success "$DOCKER_LOGIN_SUCCESS"
            echo "========================================================="
            echo ""
            return 0
        else
            unset token
            attempts=$((attempts + 1))
            [ "$LANG_CODE" = "id" ] && print_error "$DOCKER_LOGIN_FAILED" || print_error "$DOCKER_LOGIN_FAILED"
            [ $attempts -lt $max_attempts ] && { [ "$LANG_CODE" = "id" ] && print_warning "$DOCKER_LOGIN_RETRY (percobaan $attempts/$max_attempts)" || print_warning "$DOCKER_LOGIN_RETRY (attempt $attempts/$max_attempts)"; }
        fi
    done

    [ "$LANG_CODE" = "id" ] && print_error "$DOCKER_LOGIN_EXIT" || print_error "$DOCKER_LOGIN_EXIT"
    echo "========================================================="
    echo ""
    return 1
}

cleanup_logout() {
    [ "$DOCKER_HUB_LOGGED_IN" != "true" ] && return 0
    if command -v docker &> /dev/null; then
        [ "$LANG_CODE" = "id" ] && print_info "$DOCKER_LOGOUT..." || print_info "$DOCKER_LOGOUT..."
        docker logout &> /dev/null && { [ "$LANG_CODE" = "id" ] && print_success "$DOCKER_LOGOUT_DONE" || print_success "$DOCKER_LOGOUT_DONE"; }
    fi
    DOCKER_HUB_LOGGED_IN=false
}

choose_memory_limit() {
    local service_name=$1
    local auto_mode=${2:-false}
    TOTAL_RAM=$(get_total_ram)
    [ -z "$TOTAL_RAM" ] && TOTAL_RAM=0
    RAM_50=$((TOTAL_RAM * 50 / 100))

    if [ "$auto_mode" = "true" ]; then
        [ "$LANG_CODE" = "id" ] && print_info "RAM Sistem: ${TOTAL_RAM} MB - Menggunakan mode Unlimited" >&2 || print_info "System RAM: ${TOTAL_RAM} MB - Using Unlimited mode" >&2
        echo "unlimited"
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
        [ "$LANG_CODE" = "id" ] && print_info "Otomatis: Menggunakan mode Unlimited" >&2 || print_info "Auto: Using Unlimited mode" >&2
        echo "unlimited"
        return
    fi

    case $ram_choice in
        1) echo $RAM_50;;
        2) echo "unlimited";;
        *) [ "$LANG_CODE" = "id" ] && print_warning "Pilihan tidak valid, menggunakan mode Unlimited" >&2 || print_warning "Invalid choice, using Unlimited mode" >&2; echo "unlimited";;
    esac
}

# ============================================================
# DOCKER COMPOSE COMMAND DETECTION
# ============================================================
# Resolves to 'docker compose' (plugin) or 'docker-compose' (standalone).
# Plugin is preferred. No blind fallback after a real failure, so real
# errors from 'up -d' are surfaced instead of being masked by a
# missing standalone binary.
compose_run() {
    if docker compose version &> /dev/null 2>&1; then
        docker compose "$@"
    elif command -v docker-compose &> /dev/null 2>&1; then
        docker-compose "$@"
    else
        return 127
    fi
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
        if compose_run version &> /dev/null; then
            return 0
        fi
        [ "$LANG_CODE" = "id" ] && print_warning "Docker Compose plugin tidak tersedia, menginstall..." || print_warning "Docker Compose plugin not available, installing..."
        if safe_apt_get apt-get install -y docker-compose-plugin 2>/dev/null && compose_run version &> /dev/null; then
            [ "$LANG_CODE" = "id" ] && print_success "✅ Docker Compose plugin terpasang!" || print_success "✅ Docker Compose plugin installed!"
            return 0
        fi
        [ "$LANG_CODE" = "id" ] && loading_animation "📦 Menginstall Docker Compose standalone" || loading_animation "📦 Installing Docker Compose standalone"
        COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
        curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
        docker-compose --version && { [ "$LANG_CODE" = "id" ] && print_success "✅ Docker Compose standalone terpasang!" || print_success "✅ Docker Compose standalone installed!"; }
        return 0
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
    safe_apt_get apt-get install -y ca-certificates curl gnupg lsb-release || { [ "$LANG_CODE" = "id" ] && print_error "Gagal install prerequisites" || print_error "Failed to install prerequisites"; return 1; }

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
    [ -z "$SYSTEM_CODENAME" ] && SYSTEM_CODENAME="$OS_CODENAME"

    # Docker belum selalu menyediakan repo untuk codename testing/unstable baru.
    # Gunakan bookworm sebagai fallback yang kompatibel untuk trixie.
    case "$SYSTEM_CODENAME" in
        trixie) SYSTEM_CODENAME="bookworm" ;;
    esac

    if [ "$DOCKER_BASE_OS" = "debian" ]; then
        DOCKER_REPO_URL="https://download.docker.com/linux/debian"
        DOCKER_GPG_URL="https://download.docker.com/linux/debian/gpg"
    else
        DOCKER_REPO_URL="https://download.docker.com/linux/ubuntu"
        DOCKER_GPG_URL="https://download.docker.com/linux/ubuntu/gpg"
    fi

    [ "$LANG_CODE" = "id" ] && print_info "Menggunakan repository $DOCKER_BASE_OS untuk Docker..." || print_info "Using $DOCKER_BASE_OS repository for Docker..."

    curl -fsSL "$DOCKER_GPG_URL" | gpg --dearmor -o /etc/apt/keyrings/docker.gpg || { [ "$LANG_CODE" = "id" ] && print_error "Gagal menambahkan Docker GPG key" || print_error "Failed to add Docker GPG key"; return 1; }
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

        if compose_run version &> /dev/null; then
            [ "$LANG_CODE" = "id" ] && print_success "✅ Docker Compose tersedia!" || print_success "✅ Docker Compose available!"
            compose_run version
        else
            [ "$LANG_CODE" = "id" ] && print_warning "Docker Compose tidak tersedia, menginstall standalone..." || print_warning "Docker Compose not available, installing standalone..."
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
        DEPLOY_BLOCK=""
    else
        DEPLOY_BLOCK="    deploy:
      resources:
        limits:
          memory: ${MEMORY_LIMIT}M"
    fi

    cat > docker-compose.yml <<EOF
services:
  genieacs:
    cpu_shares: 90
    container_name: genieacs
    depends_on:
      - mongo
${DEPLOY_BLOCK}
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
${DEPLOY_BLOCK}
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

    echo ""
    echo "========================================================="
    [ "$LANG_CODE" = "id" ] && animated_text "🐳 Memulai Docker Compose..." 0.08 || animated_text "🐳 Starting Docker Compose..." 0.08
    [ "$LANG_CODE" = "id" ] && print_info "Proses download dan start container akan terlihat di bawah:" || print_info "Download and container start process will be shown below:"
    echo "========================================================="
    echo ""

    if compose_run up -d; then
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
# DOWNLOAD HELPER WITH RETRY
# ============================================================
download_with_retry() {
    local file="$1"
    local url="$2"
    local max_retries=3
    local retry=0

    while [ $retry -lt $max_retries ]; do
        if curl -f -s -L -o "$file" "$url" && [ -s "$file" ]; then
            return 0
        fi
        rm -f "$file" 2>/dev/null
        retry=$((retry + 1))
        [ $retry -lt $max_retries ] && sleep 2
    done

    return 1
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

    # Database files to download from GitHub Raw
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
        if download_with_retry "genieacs-db/$file" "${DB_URL}/${file}"; then
            echo "  ✓ $file"
        else
            [ "$LANG_CODE" = "id" ] && print_error "Gagal mengunduh $file dari ${DB_URL}/${file} setelah 3 percobaan" || print_error "Failed to download $file from ${DB_URL}/${file} after 3 attempts"
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
    IMAGE="solusidigitalnet/genieacspanelapi:V2.2.0"

    [ "$LANG_CODE" = "id" ] && loading_animation "📝 Membuat konfigurasi Docker Compose" || loading_animation "📝 Creating Docker Compose configuration"

    if [ "$MEMORY_LIMIT" = "unlimited" ]; then
        DEPLOY_BLOCK=""
    else
        DEPLOY_BLOCK="    deploy:
      resources:
        limits:
          memory: ${MEMORY_LIMIT}M"
    fi

    cat > docker-compose.yml <<EOF
services:
  genieacs-panel-api:
    image: ${IMAGE}
    container_name: genieacs-panel-api
${DEPLOY_BLOCK}
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

    echo ""; echo "========================================================="; [ "$LANG_CODE" = "id" ] && animated_text "🐳 Memulai Docker Compose..." 0.08 || animated_text "🐳 Starting Docker Compose..." 0.08; echo "========================================================="; echo ""

    if compose_run up -d; then COMPOSE_SUCCESS=true; else COMPOSE_SUCCESS=false; fi

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
        echo "║  👤 Username : superadmin                                ║"
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
    docker rmi solusidigitalnet/genieacspanelapi:V2.2.0 2>&1 | grep -v "No such image" || true

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

        echo ""
        echo "Masukkan nomor WhatsApp untuk notifikasi Customer Portal"
        echo "(contoh: 6281234567890, tanpa 0 di depan, tanpa +):"
        while true; do
            read -p "No WhatsApp: " WA_NUMBER
            WA_NUMBER=$(echo "$WA_NUMBER" | tr -d ' -+')
            if [[ "$WA_NUMBER" =~ ^[0-9]{9,15}$ ]]; then
                if [[ "$WA_NUMBER" =~ ^0 ]]; then
                    print_error "Format salah! Jangan pakai 0 di depan. Gunakan kode negara. Contoh: 6281234567890"
                else
                    break
                fi
            else
                print_error "Format salah! Hanya angka, tanpa +, tanpa 0 di depan. Contoh: 6281234567890"
            fi
        done
    else
        print_info "Customer Portal Configuration:"
        echo "Enter PORTAL_API_KEY from Panel Settings:"
        read -p "PORTAL_API_KEY: " PORTAL_API_KEY
        while [ -z "$PORTAL_API_KEY" ]; do
            print_error "PORTAL_API_KEY cannot be empty!"
            read -p "PORTAL_API_KEY: " PORTAL_API_KEY
        done

        echo ""
        echo "Enter WhatsApp number for Customer Portal notifications"
        echo "(e.g. 6281234567890, no leading 0, no +):"
        while true; do
            read -p "WhatsApp number: " WA_NUMBER
            WA_NUMBER=$(echo "$WA_NUMBER" | tr -d ' -+')
            if [[ "$WA_NUMBER" =~ ^[0-9]{9,15}$ ]]; then
                if [[ "$WA_NUMBER" =~ ^0 ]]; then
                    print_error "Wrong format! No leading 0. Use country code. Example: 6281234567890"
                else
                    break
                fi
            else
                print_error "Invalid format! Digits only, no +, no leading 0. Example: 6281234567890"
            fi
        done
    fi

    IMAGE="solusidigitalnet/customerportal:latest"
    [ "$LANG_CODE" = "id" ] && loading_animation "📝 Membuat konfigurasi Docker Compose" || loading_animation "📝 Creating Docker Compose configuration"

    if [ "$MEMORY_LIMIT" = "unlimited" ]; then
        DEPLOY_BLOCK=""
    else
        DEPLOY_BLOCK="    deploy:
      resources:
        limits:
          memory: ${MEMORY_LIMIT}M"
    fi

    cat > docker-compose.yml <<EOF
services:
  customerportal:
    image: ${IMAGE}
    container_name: customerportal
${DEPLOY_BLOCK}
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
      - WHATSAPP_FORGOT_CODE=${WA_NUMBER}
      - WHATSAPP_SUPPORT=${WA_NUMBER}
      - DISPLAY_SSID_24GHZ=1
      - DISPLAY_SSID_58GHZ=5
    restart: unless-stopped
EOF

    echo ""; echo "========================================================="; [ "$LANG_CODE" = "id" ] && animated_text "🐳 Memulai Docker Compose..." 0.08 || animated_text "🐳 Starting Docker Compose..." 0.08; echo "========================================================="; echo ""

    if compose_run up -d; then COMPOSE_SUCCESS=true; else COMPOSE_SUCCESS=false; fi

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
        echo "║  📱 WhatsApp  : ${WA_NUMBER}"
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
        compose_run version 2>/dev/null || true

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
            echo "  👤 superadmin / solusidigitalnet"
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

        echo ""
        echo "╔══════════════════════════════════════════════════════════╗"
        [ "$LANG_CODE" = "id" ] && echo "║                   STATUS CHECK SELESAI                  ║" || echo "║                  STATUS CHECK COMPLETE                  ║"
        echo "╚══════════════════════════════════════════════════════════╝"
    else
        [ "$LANG_CODE" = "id" ] && print_error "❌ Docker: Tidak Terinstall" || print_error "❌ Docker: Not Installed"
        echo ""
        echo "╔══════════════════════════════════════════════════════════╗"
        echo "║                      DOCKER REQUIRED                    ║"
        [ "$LANG_CODE" = "id" ] && echo "║  Install Docker terlebih dahulu untuk menggunakan       ║" || echo "║  Please install Docker first to use GenieACS            ║"
        echo "║  📋 Menu: [1] Docker → [1] Install Docker               ║"
        echo "╚══════════════════════════════════════════════════════════╝"
    fi
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
    echo "  [5] $MENU_STATUS"
    echo "  [6] $MENU_EXIT"
    echo ""
    echo "========================================================="
}

show_docker_menu() {
    clear; echo ""; echo "========================================================="; echo "                  $MENU_DOCKER"; echo "========================================================="; echo ""
    echo "  [1] $SUBMENU_UNINSTALL_DOCKER"; echo "  [0] $MSG_BACK"; echo ""; echo "========================================================="
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

docker_menu() {
    while true; do
        show_docker_menu
        read -p "$MSG_CHOOSE (0-1): " choice
        case $choice in
            1) uninstall_docker && print_success "$MSG_PROCESS_COMPLETE" || print_error "$MSG_PROCESS_FAILED"; read -p "$MSG_PRESS_ENTER";;
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

main() {
    # Ensure cleanup runs on exit; Ctrl+C / termination exit immediately
    trap 'exit 0' INT TERM
    trap cleanup_logout EXIT

    # 1. Pre-flight readiness check
    preflight_check || exit 1

    # 2. Docker check / install prompt if not ready
    if ! command -v docker &> /dev/null || ! docker info &> /dev/null; then
        echo ""
        if [ "$LANG_CODE" = "id" ]; then
            print_warning "$PREFLIGHT_INSTALL_DOCKER_PROMPT"
            read -p "Install Docker sekarang? (y/n): " install_docker_now
        else
            print_warning "$PREFLIGHT_INSTALL_DOCKER_PROMPT"
            read -p "Install Docker now? (y/n): " install_docker_now
        fi

        if [ "$install_docker_now" = "y" ] || [ "$install_docker_now" = "Y" ]; then
            install_docker || { [ "$LANG_CODE" = "id" ] && print_error "Instalasi Docker gagal. Installer dihentikan." || print_error "Docker installation failed. Installer aborted."; exit 1; }
        else
            [ "$LANG_CODE" = "id" ] && print_error "Docker diperlukan untuk melanjutkan. Installer dihentikan." || print_error "Docker is required to continue. Installer aborted."
            exit 1
        fi
    fi

    # 3. Required Docker Hub login
    dockerhub_login || exit 1

    # 4. Main installer menu
    while true; do
        show_menu
        read -p "$MSG_CHOOSE (1-6): " choice
        case $choice in
            1) docker_menu;;
            2) genieacs_menu;;
            3) panel_menu;;
            4) customer_portal_menu;;
            5) show_status; read -p "$MSG_PRESS_ENTER";;
            6) print_info "$MSG_THANK_YOU"; print_info "$EXIT_MESSAGE"; exit 0;;
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