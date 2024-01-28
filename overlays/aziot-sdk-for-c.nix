dirname: inputs: final: prev:
let
  inherit (final) pkgs;
  lib = inputs.self.lib.__internal__;
in
{
  aziot-sdk-for-c = pkgs.stdenv.mkDerivation rec {
    pname = "aziot-sdk-for-c";
    version = "1.10.1";

    src = pkgs.fetchgit {
      url = "https://github.com/Azure/azure-iot-sdk-c.git";
      deepClone = true;
      rev = version;
      sha256 = "sha256-1+PBK/HDbKL+n4lIjPfr97hN5GCkb6s7d9BbwZDz9F8=";
    };

    nativeBuildInputs = [
        pkgs.cmake
        pkgs.openssl
        pkgs.curl
        pkgs.libuuid
      ];

    meta = {
      description = "A C99 SDK for connecting devices to Microsoft Azure IoT services";
      homepage = "https://github.com/Azure/azure-iot-sdk-c";
      changelog = "https://github.com/Azure/azure-iot-sdk-c/releases";
      license = pkgs.lib.licenses.mit;
      platforms = pkgs.lib.platforms.linux;
      maintainers = [ "Microsoft" "Elias Frank" ];
    };
  };
}
