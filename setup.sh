#!/usr/bin/env bash

# NixOS Dotfiles Setup Script
# Automates configuration of username, hostname, and password

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to prompt for input with default value
prompt_input() {
    local prompt="$1"
    local default="$2"
    local result
    
    if [ -n "$default" ]; then
        read -p "$(echo -e "${BLUE}?${NC} $prompt [$default]: ")" result
        result="${result:-$default}"
    else
        read -p "$(echo -e "${BLUE}?${NC} $prompt: ")" result
    fi
    
    echo "$result"
}

# Function to prompt for password
prompt_password() {
    local prompt="$1"
    local password1
    local password2
    
    while true; do
        read -s -p "$(echo -e "${BLUE}?${NC} $prompt: ")" password1
        echo
        read -s -p "$(echo -e "${BLUE}?${NC} Xác nhận mật khẩu / Confirm password: ")" password2
        echo
        
        if [ "$password1" = "$password2" ]; then
            if [ -z "$password1" ]; then
                print_warning "Mật khẩu không được để trống / Password cannot be empty"
                continue
            fi
            echo "$password1"
            return 0
        else
            print_warning "Mật khẩu không khớp / Passwords do not match. Vui lòng thử lại / Please try again."
        fi
    done
}

# Function to validate username
validate_username() {
    local username="$1"
    if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        print_error "Tên người dùng không hợp lệ / Invalid username"
        print_info "Username phải bắt đầu bằng chữ thường hoặc gạch dưới và chỉ chứa chữ thường, số, gạch dưới và gạch ngang"
        print_info "Username must start with lowercase letter or underscore and contain only lowercase letters, numbers, underscores, and hyphens"
        return 1
    fi
    return 0
}

# Function to validate hostname
validate_hostname() {
    local hostname="$1"
    # Check RFC 1123 compliance
    if [[ ! "$hostname" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?(\.[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?)*$ ]]; then
        print_error "Hostname không hợp lệ / Invalid hostname"
        print_info "Hostname phải tuân theo RFC 1123: chỉ chữ thường, số và dấu gạch ngang (không ở đầu/cuối)"
        print_info "Hostname must follow RFC 1123: lowercase letters, numbers, and hyphens (not at start/end)"
        return 1
    fi
    if [ ${#hostname} -gt 253 ]; then
        print_error "Hostname quá dài (tối đa 253 ký tự) / Hostname too long (max 253 characters)"
        return 1
    fi
    return 0
}

# Function to backup a file
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        # Add nanoseconds to ensure unique backup names
        local backup_name="${file}.backup.$(date +%Y%m%d_%H%M%S_%N)"
        cp "$file" "$backup_name"
        print_success "Đã sao lưu / Backed up: $file"
    fi
}

# Main script
clear
echo "================================================="
echo "  NixOS Dotfiles - Thiết lập tự động / Setup  "
echo "================================================="
echo ""

# Check if running in the dotfiles directory
if [ ! -f "flake.nix" ] || [ ! -f "example-configuration.nix" ]; then
    print_error "Lỗi: Vui lòng chạy script này trong thư mục dotfiles"
    print_error "Error: Please run this script from the dotfiles directory"
    exit 1
fi

print_info "Script này sẽ giúp bạn cấu hình username, hostname và password"
print_info "This script will help you configure username, hostname, and password"
echo ""

# Prompt for username
while true; do
    USERNAME=$(prompt_input "Nhập tên người dùng / Enter username" "$USER")
    if validate_username "$USERNAME"; then
        print_success "Username: $USERNAME"
        break
    fi
done

# Prompt for hostname
while true; do
    HOSTNAME=$(prompt_input "Nhập hostname" "nixos")
    if validate_hostname "$HOSTNAME"; then
        print_success "Hostname: $HOSTNAME"
        break
    fi
done

# Ask if user wants to set password now
echo ""
print_info "Bạn có muốn đặt mật khẩu ngay bây giờ không?"
print_info "Do you want to set a password now?"
print_warning "Lưu ý: Mật khẩu sẽ được lưu trong /etc/nixos/configuration.nix (an toàn)"
print_warning "Note: Password will be stored in /etc/nixos/configuration.nix (secure)"
read -p "$(echo -e "${BLUE}?${NC} (y/n) [y]: ")" SET_PASSWORD
SET_PASSWORD="${SET_PASSWORD:-y}"

if [[ "$SET_PASSWORD" =~ ^[Yy]$ ]]; then
    PASSWORD=$(prompt_password "Nhập mật khẩu / Enter password")
    print_success "Mật khẩu đã được thiết lập / Password has been set"
    HAS_PASSWORD=true
else
    print_warning "Bỏ qua đặt mật khẩu / Skipping password setup"
    print_info "Bạn sẽ cần đặt mật khẩu sau bằng: sudo passwd $USERNAME"
    print_info "You will need to set password later with: sudo passwd $USERNAME"
    HAS_PASSWORD=false
fi

echo ""
print_info "Đang cập nhật cấu hình / Updating configuration..."
echo ""

# Backup files
backup_file "flake.nix"
backup_file "example-configuration.nix"

# Update flake.nix - change username in homeConfigurations
print_info "Đang cập nhật flake.nix..."
sed -i "s/username = \".*\";/username = \"$USERNAME\";/" flake.nix
print_success "Đã cập nhật flake.nix"

# Update example-configuration.nix - change hostname and username
print_info "Đang cập nhật example-configuration.nix..."
sed -i "s/networking\.hostName = \".*\";/networking.hostName = \"$HOSTNAME\";/" example-configuration.nix
# Use more specific pattern to match username in users.users.<username>
sed -i "s/users\.users\.[a-z_][a-z0-9_-]* = {/users.users.$USERNAME = {/" example-configuration.nix
print_success "Đã cập nhật example-configuration.nix"

# Create a personalized configuration.nix
print_info "Đang tạo configuration.nix..."

# Detect NixOS version from os-release if available
STATE_VERSION="24.05"
if [ -f /etc/os-release ]; then
    # Try to extract version from VERSION_ID (e.g., "24.05")
    DETECTED_VERSION=$(grep "^VERSION_ID=" /etc/os-release | cut -d'"' -f2 || echo "")
    if [ -n "$DETECTED_VERSION" ]; then
        STATE_VERSION="$DETECTED_VERSION"
        print_info "Phát hiện NixOS phiên bản / Detected NixOS version: $STATE_VERSION"
    fi
fi

cat > configuration.nix << EOF
# NixOS Configuration
# Generated by setup.sh on $(date)

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "$HOSTNAME";
  networking.networkmanager.enable = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # User configuration
  users.users.$USERNAME = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
EOF

if [ "$HAS_PASSWORD" = true ]; then
    # Generate hashed password using openssl
    HASHED_PASSWORD=$(openssl passwd -6 "$PASSWORD")
    # Clear password from memory immediately
    unset PASSWORD
    cat >> configuration.nix << EOF
    hashedPassword = "$HASHED_PASSWORD";
EOF
    unset HASHED_PASSWORD
fi

cat >> configuration.nix << EOF
  };

  # System state version
  # Note: This should match your NixOS version. Change if you're using a different version.
  # See https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "$STATE_VERSION";
}
EOF

print_success "Đã tạo configuration.nix"

echo ""
echo "================================================="
print_success "Thiết lập hoàn tất / Setup completed!"
echo "================================================="
echo ""

print_info "Các file đã được cập nhật / Files have been updated:"
echo "  ✓ flake.nix"
echo "  ✓ example-configuration.nix"
echo "  ✓ configuration.nix (mới / new)"
echo ""

print_info "Các bước tiếp theo / Next steps:"
echo ""
echo "1. Xem lại cấu hình / Review configuration:"
echo "   ${GREEN}cat configuration.nix${NC}"
echo ""
echo "2. Sao chép hardware-configuration.nix nếu chưa có:"
echo "   Copy hardware-configuration.nix if not exists:"
echo "   ${GREEN}sudo cp /etc/nixos/hardware-configuration.nix .${NC}"
echo ""
echo "3. Build và apply cấu hình / Build and apply configuration:"
echo "   ${GREEN}sudo nixos-rebuild switch --flake .#default${NC}"
echo ""
echo "4. Khởi động lại / Reboot:"
echo "   ${GREEN}sudo reboot${NC}"
echo ""

if [ "$HAS_PASSWORD" = false ]; then
    print_warning "Nhớ đặt mật khẩu sau khi cài đặt:"
    print_warning "Remember to set password after installation:"
    echo "   ${YELLOW}sudo passwd $USERNAME${NC}"
    echo ""
fi

print_info "Để xem hướng dẫn chi tiết, xem README.md hoặc docs/README.vi-VN.md"
print_info "For detailed instructions, see README.md or docs/README.vi-VN.md"
