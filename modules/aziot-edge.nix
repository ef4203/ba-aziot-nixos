dirname: inputs: { config, lib, pkgs, ... }:

let
  cfg = config.services.aziot-edge;
  package = pkgs.aziot-edge;
in

{
  # Options for Azure Iot Edge
  options = {
    services.aziot-edge = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc ''
          Wheter to enable the Azure IoT Edge runtime.
        '';
      };
    };
  };

  # Configuration for Azure IoT Edge
  config = lib.mkIf cfg.enable {
    services.azure-identity-service.enable = true;
    users = {
      groups = {
        iotedge = {
          gid = 1004;
          name = "iotedge";
        };
      };
      users = {
        iotedge = {
          uid = 904;
          name = "iotedge";
          home = "/var/lib/aziot/edged";
          isSystemUser = true;
          createHome = true;
          group = "iotedge";
          shell = "/sbin/nologin";
          description = "iotedge user";
          extraGroups = [ "docker" "systemd-journal" "aziotcs" "aziotks" "aziotid" ];
        };
        edgeagentuser = {
          name = "edgeagentuser";
          uid = 13622;
          isSystemUser = true;
          createHome = false;
          group = "users";
          shell = "/sbin/nologin";
          description = "edgeagentuser user";
        };
        edgehubuser = {
          name = "edgehubuser";
          uid = 13623;
          isSystemUser = true;
          createHome = false;
          group = "users";
          shell = "/sbin/nologin";
          description = "edgehubuser user";
        };
      };
    };
    environment = {
      systemPackages = [ package ];
      etc = { };
    };
    systemd = {
      tmpfiles.rules = [
        "d /var/lib/aziot 0770 root root -"
        "d /var/lib/aziot/edged 0770 iotedge iotedge -"
        "d /var/log/aziot/edged 0755 iotedge iotedge -"
      ];
      sockets = {
        "aziot-edged.mgmt" = {
          description = "Azure IoT Edge daemon management socket";
          partOf = [ "aziot-edged.service" ];
          wantedBy = [ "sockets.target" ];
          socketConfig = {
            ListenStream = "/var/run/iotedge/mgmt.sock";
            SocketMode = "0660";
            DirectoryMode = "0755";
            SocketUser = "iotedge";
            SocketGroup = "iotedge";
            Service = "aziot-edged.service";
          };
        };
        "aziot-edged.workload" = {
          description = "Azure IoT Edge daemon workload socket";
          partOf = [ "aziot-edged.service" ];
          wantedBy = [ "sockets.target" ];
          socketConfig = {
            ListenStream = "/var/run/iotedge/workload.sock";
            SocketMode = "0660";
            DirectoryMode = "0755";
            SocketUser = "iotedge";
            SocketGroup = "iotedge";
            Service = "aziot-edged.service";
          };
        };
      };
      services = {
        aziot-edged = {
          description = "Azure IoT Edge daemon";
          requires = [ "aziot-edged.workload.socket" "aziot-edged.mgmt.socket" "aziot-edge-envfix.service" ];
          after = [ "network-online.target" "docker.service" "aziot-edged.workload.socket" "aziot-edged.mgmt.socket" "aziot-edge-envfix.service" ];
          wants = [ "network-online.target" "docker.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${package}/bin/aziot-edged";
            KillMode = "process";
            TimeoutStartSec = "600";
            TimeoutStopSec = "40";
            Restart = "on-failure";
            RestartPreventExitStatus = "153";
            RestartSec = "5";
            # User = "iotedge";
            # Group = "iotedge";
          };
        };
        aziot-edge-envfix = {
          description = "Azure IoT Edge Environment Fixes";
          wantedBy = [ "multi-user.target" ];
          script = ''
            mkdir -p /etc/aziot/edged/config.d
            chown iotedge:iotedge /etc/aziot/edged/
            chown iotedge:iotedge /etc/aziot/edged/config.d/
          '';
        };
      };
    };
  };
}
