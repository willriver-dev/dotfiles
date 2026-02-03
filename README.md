# NixOS Dotfiles with Niri

A simple NixOS configuration using Flakes with the Niri Wayland compositor.

**[🇻🇳 Tiếng Việt](./docs/README.vi-VN.md)**

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

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Default Configuration](#default-configuration)
- [Post-Installation](#post-installation)
- [Usage](#usage)
- [Common Tasks](#common-tasks)
- [Troubleshooting](#troubleshooting)
- [Structure](#structure)
- [Customization](#customization)

## Prerequisites

Before installing, ensure you have:

- A working NixOS installation (version 25.11 or later recommended)
- Flakes enabled in your NixOS configuration
- Internet connection for downloading packages
- Sudo/root access for system-level installation

### Enable Flakes

If you haven't enabled flakes yet, add this to your `/etc/nixos/configuration.nix`:

```nix
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```

Then rebuild your system:

```bash
sudo nixos-rebuild switch
```

## Installation

### Quick Setup (Recommended)

Use the automated setup script to configure username, hostname, and password:

```bash
# 1. Clone this repository
git clone https://github.com/willriver-dev/dotfiles.git
cd dotfiles

# 2. Run the setup script (it will auto-generate hardware config)
./setup.sh

# 3. Follow the prompts to configure:
#    - Username (default: current user)
#    - Hostname (default: nixos)
#    - Timezone (default: Asia/Ho_Chi_Minh)
#    - Password (set custom or use default 'initial')

# 4. Build and switch to the new configuration
sudo nixos-rebuild switch --flake .#default

# 5. Reboot to apply all changes
sudo reboot
```

The setup script will automatically:
- Update `flake.nix` with your username
- Update `example-configuration.nix` with your hostname and username
- Create a personalized `configuration.nix` with your settings including:
  - Timezone (default: Asia/Ho_Chi_Minh)
  - Internationalization (en_US.UTF-8)
  - Keyboard layout (us)
  - Allow unfree packages
- Set a password (custom or default 'initial')
- Auto-generate `hardware-configuration.nix` for your system

### Method 1: System-Level Installation (Manual)

This method installs the configuration system-wide:

```bash
# 1. Clone this repository
git clone https://github.com/willriver-dev/dotfiles.git
cd dotfiles

# 2. Review the configuration (optional but recommended)
cat flake.nix
cat example-configuration.nix

# 3. Build and switch to the new configuration
sudo nixos-rebuild switch --flake .#default

# 4. Reboot to apply all changes
sudo reboot
```

### Method 2: Home Manager (User-Level Only)

For user-level configuration without system-level changes:

```bash
# 1. Clone this repository
git clone https://github.com/willriver-dev/dotfiles.git
cd dotfiles

# 2. Build the home-manager configuration
nix build .#homeConfigurations.default.activationPackage

# 3. Activate the configuration
./result/activate
```

**Note**: This method doesn't include Docker and Niri compositor (system-level features).

### Method 3: Integration with Existing NixOS Configuration

If you have an existing NixOS configuration, you can integrate this flake:

1. Add this flake as an input in your system's `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    dotfiles.url = "github:willriver-dev/dotfiles";
  };
}
```

2. Import and use the packages in your configuration:

```nix
environment.systemPackages = dotfiles.packages.${system};
```

See `example-configuration.nix` for a complete example.

## Default Configuration

### Default User

- **Username**: `user`
- **Home Directory**: `/home/user`
- **Groups**: `wheel`, `docker`, `networkmanager`

**Important**: The default username is `user`. You should change this to match your actual username.

### Default Hostname

- **Hostname**: `nixos` (as shown in `example-configuration.nix`)

You can change the hostname by editing your `/etc/nixos/configuration.nix` or by modifying the flake configuration.

### System State Version

- **State Version**: `25.11`

This refers to NixOS version 25.11. Keep this consistent with your NixOS release.

## Post-Installation

### 1. Set User Password

After installation, you **must** set a password for your user:

```bash
# Set password for the default 'user' account
sudo passwd user

# Or for your custom username
sudo passwd your-username
```

**Security Note**: Always set a strong password immediately after installation!

### 2. Configure Your User

If you're not using the default `user` username, update the configuration:

1. Edit `flake.nix` and change line 86:

```nix
username = "your-actual-username";
```

2. Update your system configuration to create your user:

```nix
users.users.your-username = {
  isNormalUser = true;
  extraGroups = [ "wheel" "docker" "networkmanager" ];
};
```

3. Rebuild the system:

```bash
sudo nixos-rebuild switch --flake .#default
```

### 3. Configure Hostname (Optional)

To change your hostname:

1. Edit your `/etc/nixos/configuration.nix`:

```nix
networking.hostName = "your-hostname";
```

2. Rebuild:

```bash
sudo nixos-rebuild switch
```

### 4. Add Your User to Docker Group

If Docker isn't working, ensure your user is in the docker group:

```bash
sudo usermod -aG docker $USER
```

Then log out and log back in for the changes to take effect.

### 5. Configure Niri Compositor

After reboot, you should be able to select Niri as your compositor in your display manager. If you need to configure Niri settings:

```bash
# Niri configuration is typically at:
# ~/.config/niri/config.kdl
```

## Usage

### Starting Niri

If you installed system-wide and rebooted:

1. At the login screen, select "Niri" as your session
2. Log in with your username and password
3. Niri should start automatically

### Using Home Manager Configuration

If you used Method 2 (Home Manager):

```bash
# Navigate to the dotfiles directory
cd ~/dotfiles

# Rebuild and activate
nix build .#homeConfigurations.default.activationPackage
./result/activate
```

### Accessing Applications

After installation, all applications are available in your system:

```bash
# Open a terminal
ghostty  # or alacritty

# Text editing
helix filename.txt
vim filename.txt
code .  # VS Code

# Browsers
firefox
chromium

# Development tools
node --version
python3 --version
go version
rustc --version

# System info
fastfetch
htop

# Git operations
git status
gh repo list
```

## Common Tasks

### Updating the Configuration

When you make changes to `flake.nix`:

```bash
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#default
```

### Adding New Packages

1. Edit `flake.nix`
2. Add packages to the `commonPackages` list (around line 19)
3. Rebuild:

```bash
sudo nixos-rebuild switch --flake .#default
```

### Updating All Packages

```bash
cd ~/dotfiles

# Update flake inputs
nix flake update

# Rebuild with updated packages
sudo nixos-rebuild switch --flake .#default
```

### Removing Packages

1. Edit `flake.nix`
2. Remove packages from `commonPackages`
3. Rebuild:

```bash
sudo nixos-rebuild switch --flake .#default
```

### Checking System Information

```bash
# System info
fastfetch

# NixOS version
nixos-version

# Installed packages
nix-env -q

# System resources
htop
```

### Working with Docker

```bash
# Check Docker status
sudo systemctl status docker

# Run a container
docker run hello-world

# List running containers
docker ps

# List all containers
docker ps -a
```

## Troubleshooting

### Problem: "command not found" for installed packages

**Solution**: Log out and log back in, or source your profile:

```bash
source /etc/profile
```

### Problem: Docker permission denied

**Solution**: Add your user to the docker group:

```bash
sudo usermod -aG docker $USER
```

Then log out and log back in.

### Problem: Niri won't start

**Solutions**:

1. Check if Niri is enabled:
   ```bash
   systemctl status niri
   ```

2. Check Xorg/Wayland session files:
   ```bash
   ls /usr/share/wayland-sessions/
   ```

3. Try starting Niri manually:
   ```bash
   niri
   ```

4. Check logs:
   ```bash
   journalctl -u display-manager
   ```

### Problem: Flakes not working

**Solution**: Ensure flakes are enabled in `/etc/nixos/configuration.nix`:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

### Problem: Build fails with "error: getting status of '/nix/store/...': No such file or directory"

**Solutions**:

1. Clean up and try again:
   ```bash
   nix-collect-garbage
   sudo nixos-rebuild switch --flake .#default
   ```

2. Update the flake lock:
   ```bash
   nix flake update
   ```

### Problem: Out of disk space

**Solution**: Clean old generations and garbage collect:

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Delete old generations (keep last 3)
sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system

# Garbage collect
sudo nix-collect-garbage -d

# Or do it all at once
sudo nix-collect-garbage --delete-older-than 7d
```

### Problem: Package not available

**Solution**: The package might not be in nixpkgs. Search for it:

```bash
# Search for a package
nix search nixpkgs package-name

# Check if it's available in unstable
nix search nixpkgs#package-name
```

### Problem: Configuration errors

**Solution**: Test your configuration before switching:

```bash
# Test the build without activating
sudo nixos-rebuild test --flake .#default

# Or just build it
sudo nixos-rebuild build --flake .#default
```

### Getting Help

If you're still having issues:

1. Check NixOS documentation: https://nixos.org/manual/nixos/stable/
2. Visit NixOS Discourse: https://discourse.nixos.org/
3. Check Niri documentation: https://github.com/YaLTeR/niri
4. Open an issue on this repository: https://github.com/willriver-dev/dotfiles/issues

## Structure

```
dotfiles/
├── flake.nix                    # Main configuration with packages and Niri
├── example-configuration.nix    # Example NixOS system configuration
├── setup.sh                     # Automated setup script (NEW!)
├── README.md                    # This file (English)
└── docs/
    └── README.vi-VN.md         # Vietnamese documentation
```

The `setup.sh` script automates the tedious manual configuration process. Instead of manually editing files to set your username, hostname, and password, just run the script and answer a few prompts!

## Customization

### Modifying Packages

Edit `flake.nix` around line 19-58 to add or remove packages from the `commonPackages` list:

```nix
commonPackages = with pkgs; [
  # Add your packages here
  neovim
  tmux
  # ...
];
```

### Customizing Niri

Modify the Niri section in `flake.nix` (around line 67):

```nix
programs.niri.enable = true;
# Add more Niri configuration here
```

### Changing System Settings

Edit the system configuration section in `flake.nix` or use `example-configuration.nix` as a template for your `/etc/nixos/configuration.nix`.

### Using a Different NixOS Version

In `flake.nix`, change the nixpkgs input (line 5):

```nix
nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";  # or another version
```

Then update:

```bash
nix flake update
sudo nixos-rebuild switch --flake .#default
```

## License

This configuration is provided as-is for personal use. Feel free to fork and modify for your needs.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.
