{ description = (
  "Microsoft's Azure IoT Edge software as a NixOS package/service"
  # This flake file defines the inputs (other than except some files/archives fetched by hardcoded hash) and exports all results produced by this repository.
  # It should always pass »nix flake check« and »nix flake show --allow-import-from-derivation«, which means inputs and outputs comply with the flake convention.
); inputs = {

  # To update »./flake.lock«: $ nix flake update
  nixpkgs = { url = "github:NixOS/nixpkgs/nixos-23.11"; };
  functions = { url = "github:NiklasGollenstede/nix-functions"; inputs.nixpkgs.follows = "nixpkgs"; };
  installer = { url = "github:NiklasGollenstede/nixos-installer"; inputs.nixpkgs.follows = "nixpkgs"; inputs.functions.follows = "functions"; };
  systems.url = "github:nix-systems/default-linux";

}; outputs = inputs@{ self, ... }: inputs.functions.lib.importRepo inputs ./. (repo@{ overlays, ... }: let
  lib = repo.lib.__internal__;
in [ # Run »nix flake show --allow-import-from-derivation« to see what this merges to:
  repo # lib.* nixosModules.* overlays.*

  (lib.inst.mkSystemsFlake { inherit inputs; }) # nixosConfigurations.* apps.*-linux.* devShells.*-linux.* packages.*-linux.all-systems
  { packages = lib.fun.packagesFromOverlay { inherit inputs; }; } # packages.*.*
  { patches = (lib.fun.importWrapped inputs "${self}/patches").result; } # patches.*
]); }
