dirname: inputs: { config, pkgs, lib, name, ... }:
let
  lib = inputs.self.lib.__internal__;
in
{
  preface = { };
  imports = [
    ({
      ## Hardware
      nixpkgs.hostPlatform = "x86_64-linux";
      system.stateVersion = "23.11";
      boot.loader.systemd-boot.enable = true;
      boot.kernelParams = [ "console=ttyS0" ]; # Only during testing in VM.
      setup.bootpart.enable = true;
      setup.temproot = { enable = true; temp.type = "tmpfs"; local.type = "bind"; local.bind.base = "f2fs"; remote.type = "none"; };
      #setup.disks.devices.primary.size = ...;
    })
    ({
      ## Base Config
      documentation.enable = false; # sometimes takes quite long to build
      services.getty.autologinUser = "root"; # users.users.root.password = "root";
    })
    ({
      ## Enable SSHd
      services.openssh.enable = true;
      environment.systemPackages = [ pkgs.curl ];
      systemd.tmpfiles.rules = [
        (lib.fun.mkTmpfile { type = "L+"; path = "/root/.ssh"; argument = "/remote/root/.ssh/"; })
        (lib.fun.mkTmpfile { type = "d"; path = "/remote/root/.ssh/"; mode = "700"; })
        (lib.fun.mkTmpfile { type = "f"; path = "/remote/root/.ssh/authorized_keys"; mode = "600"; })
      ];
    })
    ({
      ## Azure IoT Edge Config
      services.aziot-edge.enable = true;
      # services.aziot-device-update-agent.enable = true;
      # virtualisation.docker.enable = true;
      virtualisation.podman.enable = true;
      virtualisation.podman.dockerCompat = true;
      boot.kernelPackages = pkgs.linuxPackages_latest;
    })
    ({
      # Pre-install container images
      ba-efk.preinstalled-container-images.enable = true;
      ba-efk.preinstalled-container-images.container = [
        ({
          imageName = "ubuntu";
          imageDigest = "sha256:bce129bec07bab56ada102d312ebcfe70463885bdf68fb32182974bd994816e0";
          sha256 = "sha256-LKWYygBgygXoRbwUN4HpNOQO3GNZ/IkoCUU3Wh7M0io=";
          os = "linux";
          arch = "x86_64";
        })
        ({
          imageName = "busybox";
          imageDigest = "sha256:462231a4068d238616e330a49aa4c0896a61c4003adde5cbe6879caa7f1992de";
          sha256 = "sha256-rg31gcBFWmL5uFc2iq43qUQ4TQmSW6peEoxy1cBGSpI=";
          os = "linux";
          arch = "x86_64";
        })
      ];
    })
  ];
}
