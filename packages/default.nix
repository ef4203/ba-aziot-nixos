{ pkgs }:
[
    (import ./aziot-edge.nix { pkgs = pkgs; })
    (import ./aziot-identity-service.nix { pkgs = pkgs; })
]
