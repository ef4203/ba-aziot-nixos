{ pkgs }: rec {
  package = import ../packages/aziot-edge.nix { pkgs = pkgs; };
  users = {
    groups = {
      iotedge = { name = "iotedge"; };
    };
    users = {
      iotedge = {
        name = "iotedge";
        home = "/var/lib/aziot/edged";
        isNormalUser = true;
        createHome = true;
        group = users.groups.iotedge.name;
        shell = "/sbin/nologin";
        description = "iotedge user";
        extraGroups = [ "docker" "systemd-journal" "aziotcs" "aziotks" "aziotid" ];
      };
      edgeagentuser = {
        name = "edgeagentuser";
        uid = 13622;
        isNormalUser = true;
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
    etc = {
      "/logrotate.d/aziot-edge" = {
        text = builtins.readFile "${package}/etc/logrotate.d/aziot-edge";
        user = "root";
        group = "root";
      };
    };
  };
  systemd = {
    tmpfiles.rules = [
        "d /var/lib/aziot 0777 root root -"
        "d /var/lib/aziot/edged 0770 ${users.users.iotedge.name} ${users.groups.iotedge.name} -"
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
          SocketUser = users.users.edgeagentuser.name;
          SocketGroup = users.groups.iotedge.name;
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
          SocketUser = users.users.iotedge.name;
          SocketGroup = users.groups.iotedge.name;
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
          ExecStart = "${package}/usr/libexec/aziot/aziot-edged";
          KillMode = "process";
          TimeoutStartSec = "600";
          TimeoutStopSec = "40";
          Restart = "on-failure";
          RestartPreventExitStatus = "153";
          RestartSec = "5";
          User = users.users.iotedge.name;
          Group = users.groups.iotedge.name;
        };
      };
      aziot-edge-envfix = {
        description = "Azure IoT Edge Environment Fixes";
        wantedBy = [ "multi-user.target" ];
        script = ''
          cp -r ${package}/etc/* /var
          mkdir -p /var/log/aziot/edged
          chown ${users.users.iotedge.name}:${users.groups.iotedge.name} /var/log/aziot/edged
          chown ${users.users.iotedge.name}:${users.groups.iotedge.name} /var/aziot/edged/
          chown ${users.users.iotedge.name}:${users.groups.iotedge.name} /var/aziot/edged/config.d/
          chown ${users.users.iotedge.name}:${users.groups.iotedge.name} /var/aziot/edged/config.toml.default
          chmod 755 /var/log/aziot/edged
          chmod 600 /var/aziot/config.toml.edge.template
          chmod 400 /var/aziot/edged/config.toml.default
          chmod 700 /var/aziot/edged/config.d
        '';
      };
    };
  };
}
