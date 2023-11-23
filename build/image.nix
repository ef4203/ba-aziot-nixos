{ pkgs, modulesPath, lib, ... }:
let
  moduleConfig = (import ../modules { lib = lib; pkgs = pkgs; });
  config = {
    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
    };
    environment = {
      systemPackages = [ pkgs.openssh ];
    };
  };
in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../modules/aziot-edge.nix
  ];
  users = moduleConfig.users;
  environment = lib.mkMerge [ config.environment moduleConfig.environment ];
  systemd = moduleConfig.systemd;
  boot = config.boot;
  services.aziot-edge.enable = true;
  virtualisation.docker.enable = true;
}
