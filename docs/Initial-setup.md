# Inital setup

This document describes the inital setup that is required
to get started with building NixOS images on a Linux host.

## Host configuration

### Ensure that you have enough memory

Create a swap partition or a swapfile such that the total
amount of memory including swap of the target system is at
least **70 GB**. This value has been confirmed to be enough
to build ReUpNix on an minimal installation of Linux.

If the partition setup of the build host was already completed,
and it's no longer possible to resize the swap partition,
instead a swapfile can be created with the following commands:

```
# dd if=/dev/zero of=/swapfile bs=1M count=64k status=progress
```
```
# chmod 0600 /swapfile
```
```
# mkswap -U clear /swapfile
```
```
# swapon /swapfile
```

To automatically activate the swapfile on boot, the
following command must be run:

```
# echo "/swapfile none swap defaults 0 0" >> /etc/fstab
```

### Resize the /tmp drive

While building Nix will use the `/tmp` directory. For most
linux based operating system this is a tmpfs, meaning
that it only exists in memory. However, by default the size
of the `/tmp` drive is half of the physical installed memory.

You will need at least **32 GB** available on your `/tmp` drive.

Check the avaiable storage on your host with;
```
$ df -h
```

and then resize the `/tmp` drive if nessesary with;
```
# mount -o remount,size=32G /tmp/
```

### Add your current user to the nix-users group

In order to run Nix builds without sudo and as a non-root
user, user must be added to `nix-users` grou with the following
command:


```
# usermod -aG nix-users <<username>>
```

## Install Nix CLI

The following instructions can be used to install the Nix CLI on
your operating system, they might be run as root user.

**Pacman-based operating systems:**
```
# pacman -S nix
```

**Other operating systems:**
```
# sh <(curl -L https://nixos.org/nix/install) --daemon
```

## Configure Nix

### Start the daemon

For systemd based systems the nix-daemon can be started with the
following command:
```
# systemctl start nix-daemon
```
Further, if the nix-daemon should be automaticaly started on
boot, the following command must be run:
```
# systemctl enable nix-daemon
```

### Adjust the config file
Before building with Nix it is required to configure the Nix CLI,
for that the following file must be modifiied:
``/etc/nix/nix.conf``

```
auto-optimise-store = true
build-users-group = nixbld
cores = 0
experimental-features = recursive-nix impure-derivations nix-command flakes
max-jobs = auto
substituters = https://cache.nixos.org/
system-features = nixos-test benchmark big-parallel kvm
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
sandbox = true
sandbox-fallback = false
```
