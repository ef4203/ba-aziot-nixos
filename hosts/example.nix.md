/*

# TODO: Rename me!

## Installation

To test the system locally, run in `..`:
```bash
 nix run .#example -- run-qemu --install=always
```
See `nix run .#example -- --help` for options and more commands.


## Implementation

```nix
#*/# end of MarkDown, beginning of NixOS config flake input:
dirname: inputs: { config, pkgs, lib, name, ... }: let lib = inputs.self.lib.__internal__; in let
in { preface = {
}; imports = [ ({ ## Hardware

  nixpkgs.hostPlatform = "x86_64-linux"; system.stateVersion = "23.11";

  boot.loader.systemd-boot.enable = true;
  setup.bootpart.enable = true;
  setup.temproot = { enable = true; temp.type = "tmpfs"; local.type = "bind"; local.bind.base = "f2fs"; remote.type = "none"; };
  #setup.disks.devices.primary.size = ...;
  boot.kernelParams = [ "console=ttyS0" ]; # Only during testing in VM.

}) ({ ## Base Config

  documentation.enable = false; # sometimes takes quite long to build
  services.getty.autologinUser = "root"; # users.users.root.password = "root";

}) ({ ## Enable SSHd
  services.openssh.enable = true;
  environment.systemPackages = [ pkgs.curl ];
  systemd.tmpfiles.rules = [
    (lib.fun.mkTmpfile { type = "L+"; path = "/root/.ssh"; argument = "/remote/root/.ssh/"; })
    (lib.fun.mkTmpfile { type = "d"; path = "/remote/root/.ssh/"; mode = "700"; })
    (lib.fun.mkTmpfile { type = "f"; path = "/remote/root/.ssh/authorized_keys"; mode = "600"; })
  ];

}) ({ ## Azure IoT Edge Config

  services.aziot-edge.enable = true;
  virtualisation.docker.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

}) ]; }
