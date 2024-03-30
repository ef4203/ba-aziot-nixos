dirname: inputs: { config, lib, pkgs, ... }:

let
  lib = inputs.self.lib.__internal__;
  cfg = config.ba-efk.preinstalled-container-images;
in

{
  # Options for pre-installing Docker images for Azure IoT Edge.
  options = {
    ba-efk.preinstalled-container-images = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc ''
          Wheter to pre-install Docker images for Azure IoT Edge.
        '';
      };
      container = lib.mkOption {
        type = lib.types.listOf lib.types.anything;
        default = [ ];
        description = lib.mdDoc ''
          List of paths to Docker images to pre-install.
        '';
      };
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services = {
      import-preinstalled-container-images = {
        description = "Imports any pre-installed Docker images for Azure IoT Edge";
        after = [ "network-online.target" "docker.service" ];
        wantedBy = [ "multi-user.target" ];
        script = ''
          mkdir -p /var/preinst
          ${builtins.concatStringsSep "\n"
          (map (x: "mkdir -p /var/preinst/${x.imageName}\ncp -r ${pkgs.stdenv.mkDerivation {
            pname = x.imageName;
            version = x.imageDigest;
            phases = [ "installPhase" ];
            src = pkgs.dockerTools.pullImage x;
            allowedReferences = [];
            installPhase = ''
              mkdir -p $out
              mkdir -p build
              cd build
              tar -xf $src -C .
              layers=( $( ${pkgs.jq}/bin/jq -r '.[0].Layers|.[]' manifest.json ) )
              echo $layers
              for layer in $layers; do
                mkdir -p $layer.d
                tar -xvf $layer -C $layer.d
                rm -r $layer
              done
              cp -r . $out
            '';
          }}/* /var/preinst/${x.imageName}" +
          " # ${pkgs.docker}/bin/docker image load -i /var/preinst/${x.imageName}.tar")
          cfg.container)}
          # rm -rf /var/preinst
        '';
      };
    };
  };
}
#           . --numeric-owner --transform='s,^\./,,' >| /var/preinst/${x.imageName}.tar\n" +
