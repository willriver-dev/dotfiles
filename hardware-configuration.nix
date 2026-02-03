# Hardware Configuration
#
# This is a template file. You should replace this with your actual hardware configuration.
# Generate your hardware configuration with:
# sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  # IMPORTANT: This is a placeholder configuration
  # You MUST replace this with your actual hardware configuration!
  
  # Example filesystem configuration (edit to match your system):
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Example boot partition for UEFI systems:
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  # Example swap configuration:
  # swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  # Networking
  # networking.useDHCP = lib.mkDefault true;

  # Hardware settings
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
