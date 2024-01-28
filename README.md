# Azure IoT Edge on NixOS
Microsoft's Azure IoT Edge software as Nix packages

## Host Setup
For detailed instructions on how to build this project, please refer to the
[Initlial Setup](docs/Initial-setup.md) documentation.

## Running a demo
For a demonstration, you can run a VM in Qemu, via the following script.

```sh
nix run '.#example' --show-trace -- run-qemu --install=always
```
