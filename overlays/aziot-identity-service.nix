dirname: inputs: final: prev:
let
  inherit (final) pkgs;
  lib = inputs.self.lib.__internal__;
in
{
  aziot-identity-service = pkgs.stdenv.mkDerivation rec {
    pname = "aziot-idenity-service";
    version = "1.4.6-1";

    src = pkgs.fetchurl {
      url = "https://packages.microsoft.com/ubuntu/22.04/prod/pool/main/a/aziot-identity-service/aziot-identity-service_1.4.6-1_amd64.deb";
      hash = "sha256-4/+vb0Haa17zQ9ralrZIl7/ofji2UHwYGOHBcid5Pow=";
    };

    nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.dpkg pkgs.makeWrapper ];
    buildInputs = [ pkgs.openssl pkgs.tpm2-tss pkgs.stdenv.cc.cc ];
    unpackPhase = "dpkg-deb -R $src .";
    runtimeDependencies = [ ];
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share
      mkdir -p $out/bin
      mkdir -p $out/lib
      mv usr/lib/* $out/lib
      mv usr/share/* $out/share
      mv usr/bin/* $out/bin
      cp -r * $out

      runHook postInstall
    '';

    meta = {
      description = "The IoT Edge OSS project";
      homepage = "https://github.com/Azure/iot-identity-service/";
      changelog = "https://github.com/Azure/iot-identity-service/releases";
      license = pkgs.lib.licenses.mit;
      platforms = pkgs.lib.platforms.linux;
      maintainers = [ "Elias Frank" ];
    };
  };
}
