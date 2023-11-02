{ pkgs }: pkgs.stdenv.mkDerivation rec {
  pname = "aziot-edge";
  version = "1.4.20-1";

  src = pkgs.fetchurl {
    url = "https://packages.microsoft.com/ubuntu/22.04/prod/pool/main/a/aziot-edge/aziot-edge_1.4.20-1_amd64.deb";
    hash = "sha256-8X5BydyNeAlPls6wTyQHZF1k57wIRy1xHKQWC88abgY=";
  };

  nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.dpkg pkgs.makeWrapper];
  buildInputs = [ pkgs.openssl pkgs.tpm2-tss pkgs.stdenv.cc.cc ];
  unpackPhase = "dpkg-deb -R $src .";
  runtimeDependencies = [ pkgs.docker ];
  installPhase = ''
    runHook preInstall

    sed -i "s/\/etc\/aziot\//\/var\/aziot\//g" usr/bin/iotedge
    sed -i "s/\/etc\/aziot\//\/var\/aziot\//g" usr/libexec/aziot/aziot-edged
    mkdir -p $out/share
    mkdir -p $out/bin
    mv usr/share/* $out/share
    mv usr/bin/* $out/bin
    cp -r * $out

    runHook postInstall
  '';

  meta = {
    description = "The IoT Edge OSS project";
    homepage = "https://github.com/Azure/iotedge";
    changelog = "https://github.com/Azure/iotedge/releases";
    license = pkgs.lib.licenses.mit;
    platforms = pkgs.lib.platforms.linux;
    maintainers = [ "Elias Frank" ];
  };
}
