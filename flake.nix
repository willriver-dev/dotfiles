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
        vscode

        # Browsers
        firefox
        chromium

        # API testing tools
        postman
        insomnia

        # Other tools
        fastfetch
        htop
        wget
        curl

        # Terminals
        ghostty
        alacritty
      ];
    in
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
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
