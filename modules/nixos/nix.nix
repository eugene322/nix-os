# Nix daemon settings: flakes, binary caches, GC, store dedup.
{ ... }:
{
  # Required for the proprietary NVIDIA driver, CUDA, etc.
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Hardlink identical files in the store.
      auto-optimise-store = true;

      # Use all cores for builds.
      max-jobs = "auto";

      # wheel users may add substituters / import store paths.
      trusted-users = [
        "root"
        "@wheel"
      ];

      # Binary caches — pull prebuilt binaries instead of compiling.
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://cuda-maintainers.cachix.org" # essential if you build CUDA
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkN8ET+Ntzska13W/MZOk="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };

    # Automatic garbage collection — keep /nix/store from ballooning.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
