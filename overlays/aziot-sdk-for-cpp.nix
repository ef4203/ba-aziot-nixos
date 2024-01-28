dirname: inputs: final: prev:
let
  inherit (final) pkgs;
  lib = inputs.self.lib.__internal__;
in
{
  aziot-sdk-for-cpp = pkgs.stdenv.mkDerivation rec {
    pname = "aziot-sdk-for-cpp";
    version = "12.5.0";

    src = pkgs.fetchgit {
      url = "https://github.com/Azure/azure-sdk-for-cpp.git";
      deepClone = true;
      rev = "azure-storage-common_12.5.0";
      sha256 = "sha256-RGyV9JA64pyoHcJvTK+Ia0Uz/3tOBHHMmlmypkVFkWE=";
    };

    nativeBuildInputs = [
        pkgs.cmake
        pkgs.git
      ];

    meta = {
      description = "This repository is for active development of the Azure SDK for C++. ";
      homepage = "https://github.com/Azure/azure-sdk-for-cpp";
      changelog = "https://github.com/Azure/azure-sdk-for-cpp/releases";
      license = pkgs.lib.licenses.mit;
      platforms = pkgs.lib.platforms.linux;
      maintainers = [ "Microsoft" "Elias Frank" ];
    };
  };
}
