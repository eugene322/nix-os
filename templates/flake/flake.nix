# Minimal per-project devShell. Activate with an `.envrc` of `use flake`.
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          git
          # add your project toolchain here:
          # cargo rustc
          # python3
          # nodejs
        ];
      };
    };
}
