{ pkgs }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "iotedge";
  version = "1.4.25";

  src = pkgs.fetchFromGitHub {
    owner = "Azure";
    repo = pname;
    rev = version;
    sha256 = "sha256-WESWCGn5dmZige0pVy+rzbjdyK9BvelZyBeWO1Y09bg=";
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
}
