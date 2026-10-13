# Local LLM server; use CUDA when the NVIDIA module is enabled.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.ollama = {
    enable = true;
    package =
      if builtins.elem "nvidia" config.services.xserver.videoDrivers then
        pkgs.ollama-cuda
      else
        pkgs.ollama-cpu;
    user = "ollama"; # stable ownership for the persisted state directory
    group = "ollama";
    host = "0.0.0.0";
    port = 11434;
    openFirewall = true;
  };

  # systemd cannot migrate the impermanence bind mount into /var/lib/private.
  # The upstream module enables DynamicUser even with a static user configured.
  systemd.services.ollama.serviceConfig = {
    DynamicUser = lib.mkForce false;
    # ReadWritePaths requires models to exist before mount namespacing.
    # StateDirectory creates it with the service ownership before that step.
    StateDirectory = lib.mkAfter [ "ollama/models" ];
  };
}
