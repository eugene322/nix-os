# NVIDIA proprietary driver (+ optional CUDA). Remove this module's import in
# modules/nixos/default.nix on AMD/Intel-only machines.
{
  config,
  pkgs,
  ...
}:
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true; # required for Wayland
    nvidiaSettings = true;
    open = true; # open kernel module — fine for Turing+ (RTX 20xx and newer)
    powerManagement.enable = false; # desktop; enable for laptops

    # Driver branch. `stable` suits most desktops; RTX 50xx (Blackwell) may
    # need `beta` or `production` until support lands in stable.
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
    # package = config.boot.kernelPackages.nvidiaPackages.beta;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

  environment.systemPackages = [ pkgs.nvtopPackages.nvidia ];

  # CUDA toolkit is large but the cuda-maintainers cache (see nix.nix) serves
  # prebuilt binaries. Uncomment if you actually need CUDA on this host:
  # environment.systemPackages = with pkgs; [
  #   cudaPackages.cudatoolkit
  #   cudaPackages.cudnn
  # ];

  # GPU inside containers (needs docker/podman):
  # hardware.nvidia-container-toolkit.enable = true;
}
