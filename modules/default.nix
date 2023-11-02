{ lib, pkgs }: rec {
  modules = [
    (import ./azure-identity-service.nix { pkgs = pkgs; })
    (import ./aziot-edge.nix { pkgs = pkgs;})
  ];

  users = lib.mkMerge (map (x: x.users) modules);
  environment = lib.mkMerge (map (x: x.environment) modules);
  systemd = lib.mkMerge (map (x: x.systemd) modules);
}
