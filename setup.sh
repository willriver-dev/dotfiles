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
        read -s -p "$(echo -e "${BLUE}?${NC} Confirm password: ")" password2
        echo
        
        if [ "$password1" = "$password2" ]; then
            if [ -z "$password1" ]; then
                print_warning "Password cannot be empty"
                continue
            fi
            echo "$password1"
            return 0
        else
            print_warning "Passwords do not match. Please try again."
        fi
    done
}

# Function to validate username
validate_username() {
    local username="$1"
    if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        print_error "Invalid username"
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
        print_error "Invalid hostname"
        print_info "Hostname must follow RFC 1123: lowercase letters, numbers, and hyphens (not at start/end)"
        return 1
    fi
    if [ ${#hostname} -gt 253 ]; then
        print_error "Hostname too long (max 253 characters)"
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
        print_success "Backed up: $file"
    fi
}

# Main script
clear
echo "================================================="
echo "      NixOS Dotfiles - Automated Setup      "
echo "================================================="
echo ""

# Check if running in the dotfiles directory
if [ ! -f "flake.nix" ] || [ ! -f "example-configuration.nix" ]; then
    print_error "Error: Please run this script from the dotfiles directory"
    exit 1
fi

print_info "This script will help you configure username, hostname, and password"
echo ""

# Prompt for username
while true; do
    USERNAME=$(prompt_input "Enter username" "$USER")
    if validate_username "$USERNAME"; then
        print_success "Username: $USERNAME"
        break
    fi
done

# Prompt for hostname
while true; do
    HOSTNAME=$(prompt_input "Enter hostname" "nixos")
    if validate_hostname "$HOSTNAME"; then
        print_success "Hostname: $HOSTNAME"
        break
    fi
done

# Ask if user wants to set password now
echo ""
print_info "Do you want to set a password now?"
print_warning "Note: A simple default password 'initial' will be used if you skip this step"
print_warning "Password will be stored as plain text in configuration.nix (for initial setup only)"
print_warning "You MUST change it after first login using 'passwd' command"
read -p "$(echo -e "${BLUE}?${NC} (y/n) [y]: ")" SET_PASSWORD
SET_PASSWORD="${SET_PASSWORD:-y}"

if [[ "$SET_PASSWORD" =~ ^[Yy]$ ]]; then
    PASSWORD=$(prompt_password "Enter password")
    print_success "Password has been set"
    HAS_PASSWORD=true
    IS_DEFAULT_PASSWORD=false
else
    print_warning "Skipping password setup"
    print_info "Initial default password will be set to: 'initial'"
    print_warning "Remember to change password immediately after first login!"
    print_info "Use this command to change password: passwd"
    PASSWORD="initial"
    HAS_PASSWORD=true
    IS_DEFAULT_PASSWORD=true
fi

echo ""
print_info "Updating configuration..."
echo ""

# Backup files
backup_file "flake.nix"
backup_file "example-configuration.nix"

# Update flake.nix - change username in homeConfigurations
print_info "Updating flake.nix..."
sed -i "s/username = \".*\";/username = \"$USERNAME\";/" flake.nix
print_success "Updated flake.nix"

# Update example-configuration.nix - change hostname and username
print_info "Updating example-configuration.nix..."
sed -i "s/networking\.hostName = \".*\";/networking.hostName = \"$HOSTNAME\";/" example-configuration.nix
# Use more specific pattern to match username in users.users.<username>
sed -i "s/users\.users\.[a-z_][a-z0-9_-]* = {/users.users.$USERNAME = {/" example-configuration.nix
print_success "Updated example-configuration.nix"

# Create a personalized configuration.nix
print_info "Creating configuration.nix..."

# Detect NixOS version from os-release if available
STATE_VERSION="24.05"
if [ -f /etc/os-release ]; then
    # Try to extract version from VERSION_ID (e.g., "24.05")
    DETECTED_VERSION=$(grep "^VERSION_ID=" /etc/os-release | cut -d'"' -f2 || echo "")
    if [ -n "$DETECTED_VERSION" ]; then
        STATE_VERSION="$DETECTED_VERSION"
        print_info "Detected NixOS version: $STATE_VERSION"
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
    # Use plain password directly - NixOS will handle it at build time
    # This avoids dependencies on mkpasswd, python3, or openssl
    # Note: initialPassword is stored in plain text but only used for first login
    cat >> configuration.nix << EOF
    initialPassword = "$PASSWORD";
EOF
    # Clear password from memory immediately
    unset PASSWORD
fi

cat >> configuration.nix << EOF
  };

  # System state version
  # Note: This should match your NixOS version. Change if you're using a different version.
  # See https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "$STATE_VERSION";
}
EOF

print_success "Created configuration.nix"

# Function to generate or copy hardware configuration
generate_hardware_config() {
    # Try to generate hardware config
    if sudo nixos-generate-config --show-hardware-config 2>/dev/null | sudo tee hardware-configuration.nix > /dev/null; then
        print_success "Auto-generated hardware-configuration.nix"
        return 0
    else
        print_warning "Cannot auto-generate, copying from /etc/nixos/"
        if sudo cp /etc/nixos/hardware-configuration.nix . 2>/dev/null; then
            print_success "Copied hardware-configuration.nix"
            return 0
        else
            print_warning "Cannot find /etc/nixos/hardware-configuration.nix"
            print_info "You will need to create this file with:"
            echo "   ${GREEN}sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix${NC}"
            return 1
        fi
    fi
}

# Generate hardware configuration automatically
echo ""
print_info "Creating hardware-configuration.nix..."

# Check if hardware-configuration.nix already exists
if [ -f "hardware-configuration.nix" ]; then
    print_warning "hardware-configuration.nix already exists"
    read -p "$(echo -e "${BLUE}?${NC} Overwrite? (y/n) [n]: ")" OVERWRITE_HW
    OVERWRITE_HW="${OVERWRITE_HW:-n}"
    
    if [[ ! "$OVERWRITE_HW" =~ ^[Yy]$ ]]; then
        print_info "Keeping existing hardware-configuration.nix"
    else
        generate_hardware_config
    fi
else
    generate_hardware_config
fi

echo ""
echo "================================================="
print_success "Setup completed!"
echo "================================================="
echo ""

print_info "Files have been updated:"
echo "  ✓ flake.nix"
echo "  ✓ example-configuration.nix"
echo "  ✓ configuration.nix (new)"
echo "  ✓ hardware-configuration.nix"
echo ""

print_info "Next steps:"
echo ""
echo "1. Review configuration:"
echo "   ${GREEN}cat configuration.nix${NC}"
echo ""
echo "2. Build and apply configuration:"
echo "   ${GREEN}sudo nixos-rebuild switch --flake .#default${NC}"
echo ""
echo "3. Reboot:"
echo "   ${GREEN}sudo reboot${NC}"
echo ""

if [ "$IS_DEFAULT_PASSWORD" = true ]; then
    print_warning "⚠️  IMPORTANT ⚠️"
    print_warning "Default password is 'initial'"
    print_warning "Change password immediately after first login!"
    echo "   ${YELLOW}passwd${NC}"
    echo ""
fi

print_info "For detailed instructions, see README.md or docs/README.vi-VN.md"
