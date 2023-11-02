let pkgs = import <nixpkgs> {}; in
{
   aziot-edge = pkgs.callPackage ./packages/aziot-edge.nix { pkgs = pkgs; };
   aziot-identity-service = pkgs.callPackage ./packages/aziot-identity-service.nix { pkgs = pkgs; };
}
