# Example NixOS Configuration
#
# This is an example of how to integrate this flake into your NixOS configuration.
# Copy this to /etc/nixos/configuration.nix or include it in your existing config.

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Example: Add this flake as an input in your system flake.nix:
  # inputs.dotfiles.url = "github:willriver-dev/dotfiles";
  # 
  # Then in your configuration:
  # environment.systemPackages = (import inputs.dotfiles).packages.${system};

  # Or use it directly:
  # sudo nixos-rebuild switch --flake github:willriver-dev/dotfiles#default

  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Users
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
  };

  # System state version
  system.stateVersion = "25.11";
}
