# NixOS Configuration
#
# This file can be customized by running ./setup.sh
# Or manually edit to match your system needs

{ config, pkgs, ... }:

{
  imports = [
    # Import hardware configuration
    # If this file doesn't exist yet, generate it with:
    # sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
    ./hardware-configuration.nix
  ];

  # Boot loader configuration
  # Choose one of the following:
  
  # For UEFI systems (most modern computers):
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # For BIOS/Legacy systems (uncomment and comment out the above):
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sda"; # Change to your boot device

  # Networking
  networking.hostName = "nixos"; # Change this to your preferred hostname
  networking.networkmanager.enable = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # User configuration
  # IMPORTANT: Change 'user' to your actual username
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
    # Set password after first boot with: passwd
    # Or uncomment and set initialPassword here (not recommended for security):
    # initialPassword = "changeme";
  };

  # System state version
  # This should match your NixOS version
  # Do not change this after installation unless you know what you're doing
  system.stateVersion = "25.11";
}
