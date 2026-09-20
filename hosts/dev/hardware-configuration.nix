# Hardware configuration for Gnome Boxes / QEMU virtual machine on x86_64 Linux.
# When installing NixOS on the VM, you can replace this file with the output
# of `nixos-generate-config` or keep the standard virtio/btrfs structure below.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_gpu"
    "virtio_net"
    "xhci_pci"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "9p"
    "9pnet_virtio"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Btrfs filesystem layout with standard subvolumes:
  # @ -> /, @home -> /home, @nix -> /nix
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "compress=zstd"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "compress=zstd"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [
      "subvol=@nix"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
