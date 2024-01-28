dirname: inputs: { config, lib, pkgs, ... }:

let
  cfg = config.services.aziot-device-update-agent;
  package = pkgs.aziot-device-update-agent;
in

{
  # Options for Azure Device Update Agent
  options = {
    services.aziot-device-update-agent = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc ''
          Wheter to enable the Azure Device Update Agent.
        '';
      };
    };
  };

  # Configuration for Azure Device Update Agent
  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = [ package ];
    };
  };
}
