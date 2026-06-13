{
  description = "NixOS configuration — flakes + home-manager + disko + impermanence + sops + stylix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    # Declarative secrets (age/sops-encrypted).
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # System-wide theming from a single base16 palette + wallpaper.
    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Per-project reproducible dev shells (used via the templates/ dir).
    devenv.url = "github:cachix/devenv";

    # Ready-made profiles for concrete hardware (laptops, SBCs, ...).
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      disko,
      impermanence,
      sops-nix,
      stylix,
      devenv,
      nixos-hardware,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          sops-nix.nixosModules.sops
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users.eugene = import ./home;
            };
          }
          ./hosts/desktop/configuration.nix
        ];
      };

      # `nix develop` shell for working on this repo.
      devShells.${system}.default =
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.mkShell {
          packages = with pkgs; [
            git
            nixd # Nix LSP
            nixfmt-rfc-style # formatter
            sops # edit encrypted secrets
            age # key management for sops
          ];
        };
    };
}
