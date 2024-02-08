dirname: inputs: { config, lib, pkgs, ... }:

let
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
        type = lib.types.listOf lib.types.path;
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
          (map (x: "${pkgs.gnutar}/bin/tar cC ${pkgs.stdenv.mkDerivation {
            pname = builtins.hashFile "md5" x;
            version = "1.0";
            src = x;
            installPhase = ''
              mkdir -p $out
              tar -xvf $src -C $out
            '';
          }} . --numeric-owner --transform='s,^\./,,' >| /var/preinst/${builtins.hashFile "md5" x}.tar\n" +
          "${pkgs.docker}/bin/docker image load -i /var/preinst/${builtins.hashFile "md5" x}.tar")
          cfg.container)}
          rm -rf /var/preinst
        '';
      };
    };
  };
}
