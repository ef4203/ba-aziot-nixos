{ pkgs, modulesPath, lib, ... }:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../modules/aziot-edge.nix
    ../modules/azure-identity-service.nix
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelParams = [ "quiet" ];
  # networking.enableIPv6 = false;
  services.aziot-edge.enable = true;
  services.azure-identity-service.enable = true;
  virtualisation.docker.enable = true;
}
