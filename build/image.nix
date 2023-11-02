{ pkgs, modulesPath, lib, ... }:
let
  config = (import ../modules { lib = lib; pkgs = pkgs; });
in
{
  imports = ["${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];
  users = config.users;
  environment = config.environment;
  systemd = config.systemd;
  virtualisation.docker.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
