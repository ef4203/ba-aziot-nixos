.PHONY: run clean

default:
	nix-build

image:
	nix-shell -p nixos-generators --run "nixos-generate --format vm-nogui --configuration ./build/image.nix -o ./out --show-trace"

run:
	nix-collect-garbage
	bash out/bin/run-nixos-vm

clean:
	nix-store --gc
	nix-collect-garbage
	rm -f *.qcow2
	rm -rf result*
	rm -rf out
