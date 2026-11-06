{
  description = "NixOS + Hyprland + Caelestia";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    caelestia.url = "github:caelestia-dots/shell";

    zen-browser.url = "github:youwen5/zen-browser-flake";
    helium.url = "github:schembriaiden/helium-browser-nix-flake";
  };

  outputs = { self, nixpkgs, home-manager, nix-flatpak, caelestia, zen-browser, helium, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hm-backup"; # rename clashing files instead of failing
          home-manager.sharedModules = [ nix-flatpak.homeManagerModules.nix-flatpak ];
          home-manager.users.houdini = import ./home.nix;
        }

        ({ pkgs, ... }: {
          environment.systemPackages = [
            caelestia.packages.${pkgs.stdenv.hostPlatform.system}.with-cli
            caelestia.inputs.caelestia-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
            zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
            helium.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];
        })
      ];
    };
  };
}
