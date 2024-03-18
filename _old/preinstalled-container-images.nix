dirname: inputs: { config, lib, pkgs, ... }:

let
  cfg = config.ba-efk.preinstalled-container-images;
  package = pkgs.stdenv.mkDerivation {
    pname = "preinstalled-container-images";
    version = "1.0.0";
    src = pkgs.dockerTools.pullImage {
      imageName = "ubuntu";
      imageDigest = "sha256:bce129bec07bab56ada102d312ebcfe70463885bdf68fb32182974bd994816e0";
      sha256 = "sha256-LKWYygBgygXoRbwUN4HpNOQO3GNZ/IkoCUU3Wh7M0io=";
      os = "linux";
      arch = "x86_64";
    };
    nativeBuildInputs = [ pkgs.sudo pkgs.docker pkgs.su ];
    requiredSystemFeatures = [ "uid-range" ];
    installPhase = ''
      # su -c "whoami" $tmpuser
      # echo "root ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers
      # echo "tmpusr:x:1000:1000:Temporary User:/home/tmpusr:/bin/bash" >> /etc/passwd
      # mkdir -p /home/tmpusr
      # chown tmpusr:tmpusr /home/tmpusr
      ${pkgs.docker}/bin/dockerd &
      # sudo -u tmpusr ${pkgs.docker}/bin/dockerd-rootless &
      # passwd -d nobody
      # sudo -u nobody --login -n -i echo test
      # su nobody -c "useradd -m tmpusr -u 1000 -s /bin/bash"
      sleep 5
      echo "asd"
      mkdir -p /usr/bin
      touch /usr/bin/chage
      chmod +x /usr/bin/chage
      chmod 777 /usr/bin/chage
      # ${pkgs.docker}/bin/docker load -i $src
      mkdir -p $out
      cp -r $src $out
    '';
    };

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
    environment = {
      systemPackages = [ package ];
    };

  };
}
