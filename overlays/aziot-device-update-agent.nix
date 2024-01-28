dirname: inputs: final: prev:
let
  inherit (final) pkgs;
  lib = inputs.self.lib.__internal__;
in
{
  aziot-device-update-agent = pkgs.stdenv.mkDerivation rec {
    pname = "aziot-device-update-agent";
    version = "1.1.0";

    src = pkgs.fetchFromGitHub {
      owner = "Azure";
      repo = "iot-hub-device-update";
      rev = version;
      sha256 = "sha256-Si3SOJPllCkoD5EKaVF6F/MbIHPOMLSYCnxWuA7JLEo=";
    };

    nativeBuildInputs = [
        pkgs.cmake
        pkgs.ninja
        pkgs.python3
        pkgs.parson
        pkgs.curl
        pkgs.aziot-sdk-for-c
        pkgs.aziot-sdk-for-cpp
      ];

    meta = {
      description = "Device Update for IoT Hub agent";
      homepage = "https://github.com/Azure/iot-hub-device-update";
      changelog = "https://github.com/Azure/iot-hub-device-update/releases";
      license = pkgs.lib.licenses.mit;
      platforms = pkgs.lib.platforms.linux;
      maintainers = [ "Microsoft" "Elias Frank" ];
    };
  };
}
