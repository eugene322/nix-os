# Networking baseline. Hostname is set per-host in hosts/<name>/configuration.nix.
{ ... }:
{
  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    # Open ports as needed, e.g. [ 22 ] for SSH from the LAN.
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };
}
