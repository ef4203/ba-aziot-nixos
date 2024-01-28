.PHONY: default run dry

# Prints the help message for the example.
default:
	nix run .#example -- --help

# Starts a QEMU VM with an example NixOS configuration and the Azure IoT package.
# The `--install=always`  flag ensures that the VM configuration is awalys
# installed, and we don't have a dirty VM to experiment with.
run:
	nix run .#example --show-trace -- run-qemu --install=always

dry:
	nix run '.#example' --show-trace -- run-qemu --install=always --dry-run
