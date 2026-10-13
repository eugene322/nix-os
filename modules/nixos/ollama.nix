# Local LLM server; use CUDA when the NVIDIA module is enabled.
{
  config,
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
    host = "127.0.0.1";
    port = 11434;
    openFirewall = false;
  };
}
