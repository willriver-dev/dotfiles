# NixOS Dotfiles with Niri

A simple NixOS configuration using Flakes with the Niri Wayland compositor.

## Features

- **Niri Compositor**: Modern Wayland compositor enabled
- **Language Runtimes**: Node.js, Python3, Go, Rust
- **Build Tools**: GCC, CMake, GNU Make
- **Version Control**: Git, GitHub CLI
- **Container Tools**: Docker
- **Editors**: Helix, Vim, VS Code
- **Browsers**: Firefox, Chromium
- **API Testing**: Postman, Insomnia
- **Utilities**: fastfetch, htop, wget, curl
- **Terminals**: Ghostty, Alacritty

## Usage

### NixOS System Configuration

To use this configuration on NixOS:

```bash
# Clone this repository
git clone https://github.com/willriver-dev/dotfiles.git
cd dotfiles

# Build the system configuration
sudo nixos-rebuild switch --flake .#default
```

### Home Manager (User-level)

For user-level configuration without system-level changes:

```bash
# Build the home-manager configuration
nix build .#homeConfigurations.default.activationPackage
./result/activate
```

## Structure

- `flake.nix` - Main Nix flake configuration with all packages and Niri setup

## Customization

Edit `flake.nix` to:
- Add or remove packages from `environment.systemPackages`
- Modify Niri settings
- Change system configuration options
