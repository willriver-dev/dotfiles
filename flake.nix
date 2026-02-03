{
  description = "Simple NixOS dotfiles with Niri";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    niri.url = "github:sodiboo/niri-flake";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
            system.stateVersion = "24.05";
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
            home.stateVersion = "24.05";

            # User packages
            home.packages = commonPackages;

            programs.home-manager.enable = true;
          })
        ];
      };
    };
}
