dirname: inputs: { config, lib, pkgs, ... }:

let
  cfg = config.services.azure-identity-service;
  package = pkgs.aziot-identity-service;
in

{
  # Options for the Azure IoT Identity Services
  options = {
    services.azure-identity-service = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc ''
          Wheter to enable the Azure IoT Identity Services.
        '';
      };
    };
  };

  # Configuration for the Azure IoT Identity Services
  config = lib.mkIf cfg.enable rec {
    users = {
      groups = {
        aziotks = {
          gid = 1000;
          name = "aziotks";
        };
        aziottpm = {
          gid = 1001;
          name = "aziottpm";
        };
        aziotcs = {
          gid = 1002;
          name = "aziotcs";
        };
        aziotid = {
          gid = 1003;
          name = "aziotid";
        };
      };
      users = {
        aziotks = {
          uid = 900;
          name = "aziotks";
          home = "/var/lib/aziot/keyd";
          isSystemUser = true;
          createHome = true;
          group = users.groups.aziotks.name;
          shell = "/sbin/nologin";
          description = "aziot-keyd user";
        };
        aziottpm = {
          uid = 901;
          name = "aziottpm";
          home = "/var/lib/aziot/tpmd";
          isSystemUser = true;
          createHome = true;
          group = users.groups.aziottpm.name;
          shell = "/sbin/nologin";
          description = "aziot-tpmd user";
        };
        aziotcs = {
          uid = 902;
          name = "aziotcs";
          home = "/var/lib/aziot/certd";
          isSystemUser = true;
          createHome = true;
          group = users.groups.aziotcs.name;
          shell = "/sbin/nologin";
          description = "aziot-certd user";
          extraGroups = [
            users.groups.aziotks.name
          ];
        };
        aziotid = {
          uid = 903;
          name = "aziotid";
          home = "/var/lib/aziot/identityd";
          isSystemUser = true;
          createHome = true;
          group = users.groups.aziotid.name;
          shell = "/sbin/nologin";
          description = "aziot-identityd user";
          extraGroups = [
            users.groups.aziotks.name
            users.groups.aziottpm.name
            users.groups.aziotcs.name
          ];
        };
      };
    };
    environment = {
      systemPackages = [ package ];
      etc = { };
    };
    systemd = {
      tmpfiles.rules = [
        "d /var/lib/aziot/keyd 0770 aziotks aziotks -"
        "d /var/lib/aziot/tpmd 0770 aziottpm aziottpm -"
        "d /var/lib/aziot/certd 0770 aziotcs aziotcs -"
        "d /var/lib/aziot/identityd 0770 aziotid aziotid -"
      ];
      sockets = {
        aziot-certd = {
          description = "Azure IoT Certificates Service API socket";
          partOf = [ "aziot-certd.service" ];
          wantedBy = [ "sockets.target" ];
          socketConfig = {
            ListenStream = "/run/aziot/certd.sock";
            SocketMode = "0660";
            DirectoryMode = "0755";
            SocketUser = users.users.aziotcs.name;
            SocketGroup = users.groups.aziotcs.name;
          };
        };
        aziot-identityd = {
          description = "Azure IoT Identity Service API socket";
          partOf = [ "aziot-identityd.service" ];
          wantedBy = [ "sockets.target" ];
          socketConfig = {
            ListenStream = "/run/aziot/identityd.sock";
            SocketMode = "0660";
            DirectoryMode = "0755";
            SocketUser = users.users.aziotid.name;
            SocketGroup = users.groups.aziotid.name;
          };
        };
        aziot-keyd = {
          description = "Azure IoT Keys Service API socket";
          partOf = [ "aziot-keyd.service" ];
          wantedBy = [ "sockets.target" ];
          socketConfig = {
            ListenStream = "/run/aziot/keyd.sock";
            SocketMode = "0660";
            DirectoryMode = "0755";
            SocketUser = users.users.aziotks.name;
            SocketGroup = users.groups.aziotks.name;
          };
        };
        aziot-tpmd = {
          description = "Azure IoT TPM Service API socket";
          partOf = [ "aziot-tpmd.service" ];
          wantedBy = [ "sockets.target" ];
          socketConfig = {
            ListenStream = "/run/aziot/tpmd.sock";
            SocketMode = "0660";
            DirectoryMode = "0755";
            SocketUser = users.users.aziottpm.name;
            SocketGroup = users.groups.aziottpm.name;
          };
        };
      };
      services = {
        aziot-certd = {
          description = "Azure IoT Certificates Service";
          requires = [ "aziot-certd.socket" "aziot-idenity-service-envfix.service" ];
          after = [ "aziot-certd.socket" "aziot-idenity-service-envfix.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Environment = "LD_LIBRARY_PATH=${package}/usr/lib/aziot-identity-service";
            ExecStart = "${package}/usr/libexec/aziot-identity-service/aziot-certd";
            KillMode = "process";
            Restart = "on-failure";
            RestartSec = "5s";
            # User = users.users.aziotcs.name;
          };
        };
        aziot-identityd = {
          description = "Azure IoT Identity Service";
          requires = [ "aziot-identityd.socket" "aziot-idenity-service-envfix.service" ];
          after = [ "aziot-identityd.socket" "aziot-idenity-service-envfix.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Environment = "LD_LIBRARY_PATH=${package}/usr/lib/aziot-identity-service";
            ExecStart = "${package}/usr/libexec/aziot-identity-service/aziot-identityd";
            KillMode = "process";
            Restart = "on-failure";
            RestartSec = "5s";
            # User = users.users.aziotid.name;
          };
        };
        aziot-keyd = {
          description = "Azure IoT Keys Service";
          requires = [ "aziot-keyd.socket" "aziot-idenity-service-envfix.service" ];
          after = [ "aziot-keyd.socket" "aziot-idenity-service-envfix.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Environment = "LD_LIBRARY_PATH=${package}/usr/lib/aziot-identity-service";
            ExecStart = "${package}/usr/libexec/aziot-identity-service/aziot-keyd";
            KillMode = "process";
            Restart = "on-failure";
            RestartSec = "5s";
            # User = users.users.aziotks.name;
          };
        };
        aziot-tpmd = {
          description = "Azure IoT TPM Service";
          requires = [ "aziot-tpmd.socket" "aziot-idenity-service-envfix.service" ];
          after = [ "aziot-tpmd.socket" "aziot-idenity-service-envfix.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Environment = "LD_LIBRARY_PATH=${package}/usr/lib/aziot-identity-service";
            ExecStart = "${package}/usr/libexec/aziot-identity-service/aziot-tpmd";
            KillMode = "process";
            Restart = "on-failure";
            RestartSec = "5s";
            # User = users.users.aziottpm.name;
          };
        };
        aziot-idenity-service-envfix = {
          description = "Azure Idendity Service Environment Fixes";
          wantedBy = [ "multi-user.target" ];
          script = ''
            mkdir -p /etc/aziot/certd/config.d
            mkdir -p /etc/aziot/keyd/config.d
            mkdir -p /etc/aziot/identityd/config.d
            mkdir -p /etc/aziot/tpmd/config.d
            chown ${users.users.aziotcs.name}:${users.groups.aziotcs.name} /etc/aziot/certd/
            chown ${users.users.aziotcs.name}:${users.groups.aziotcs.name} /etc/aziot/certd/config.d/
            chown ${users.users.aziotid.name}:${users.groups.aziotid.name} /etc/aziot/identityd/
            chown ${users.users.aziotid.name}:${users.groups.aziotid.name} /etc/aziot/identityd/config.d/
            chown ${users.users.aziotks.name}:${users.groups.aziotks.name} /etc/aziot/keyd/
            chown ${users.users.aziotks.name}:${users.groups.aziotks.name} /etc/aziot/keyd/config.d/
            chown ${users.users.aziottpm.name}:${users.groups.aziottpm.name} /etc/aziot/tpmd/
            chown ${users.users.aziottpm.name}:${users.groups.aziottpm.name} /etc/aziot/tpmd/config.d/
          '';
        };
      };
    };
  };
}
