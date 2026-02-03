{
  description = "Simple NixOS dotfiles with Niri";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    niri.url = "github:sodiboo/niri-flake";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

    nixConfig = {
    extra-substituters = [
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  outputs = { self, nixpkgs, niri, home-manager }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      
      # Common package list
      commonPackages = with pkgs; [
        # Language runtimes
        nodejs
        python3
        go
        rustc
        cargo

        # Build tools
        gcc
        cmake
        gnumake

        # Version control
        git
        gh

        # Editors
        helix
        vim
        vscodium

        # Browsers
        firefox
        chromium

        # API testing tools
        #postman
        insomnia

        # Other tools
        fastfetch
        htop
        wget
        curl
        starship  # Modern cross-shell prompt
        zsh       # Z shell - popular modern shell
        fish      # Friendly interactive shell

        # Terminals
        ghostty
        alacritty
      ];
    in
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Import the configuration.nix file (includes hardware-configuration.nix and boot loader setup)
          # If this file doesn't exist, run ./setup.sh first to generate it
          ./configuration.nix
          niri.nixosModules.niri
          ({ pkgs, ... }: {
            # Enable Niri compositor
            programs.niri.enable = true;

            # System packages
            environment.systemPackages = commonPackages ++ (with pkgs; [
              # Container tools (system-level)
              docker
            ]);

            # Enable Docker
            virtualisation.docker.enable = true;

            # Enable font configuration for Nerd Fonts
            fonts.packages = with pkgs; [
              (nerdfonts.override { fonts = [ "Lilex" ]; })
            ];

            # Basic system configuration
            system.stateVersion = "25.11";
          })
        ];
      };

      # Home Manager configuration for user-level setup
      homeConfigurations.default = let
        username = "user";
      in home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ({ pkgs, ... }: {
            home.username = username;
            home.homeDirectory = "/home/${username}";
            home.stateVersion = "25.11";

            # User packages
            home.packages = commonPackages;

            programs.home-manager.enable = true;
          })
        ];
      };
    };
}
