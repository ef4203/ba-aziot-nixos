dirname: inputs: final: prev:
let
  inherit (final) pkgs;
  lib = inputs.self.lib.__internal__;
in
{
  aziot-edge = pkgs.rustPlatform.buildRustPackage rec {
    pname = "iotedge";
    version = "1.4.26";

    src = pkgs.fetchFromGitHub {
      owner = "Azure";
      repo = pname;
      rev = version;
      sha256 = "sha256-0UykcNsh/hTtGWzjy7oBJFG4UGvjebX4Y2nAVdHA1C4=";
    };
    sourceRoot = "source/edgelet/";
    cargoLock = {
      lockFile = "${src}/edgelet/Cargo.lock";
      allowBuiltinFetchGit = true;
    };

    nativeBuildInputs = [ pkgs.pkg-config pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.openssl pkgs.tpm2-tss pkgs.stdenv.cc.cc ];

    meta = {
      description = "The IoT Edge OSS project";
      homepage = "https://github.com/Azure/iotedge";
      changelog = "https://github.com/Azure/iotedge/releases";
      license = pkgs.lib.licenses.mit;
      platforms = pkgs.lib.platforms.linux;
      maintainers = [ "Microsoft" "Elias Frank" ];
    };
  };
}
