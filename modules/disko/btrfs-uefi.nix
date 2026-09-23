# Standard single-disk Btrfs layout for UEFI systems (Timeshift-compatible)
{ lib, ... }:
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = lib.mkDefault "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          # EFI System Partition (ESP) mounted directly at /boot for systemd-boot
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          # Main Btrfs partition occupying the rest of the disk
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                # Root subvolume (Timeshift standard)
                "@" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd:3"
                    "noatime"
                    "discard=async"
                    "space_cache=v2"
                  ];
                };

                # User data subvolume (Timeshift standard)
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [
                    "compress=zstd:3"
                    "noatime"
                    "discard=async"
                    "space_cache=v2"
                  ];
                };

                # Nix store isolated to prevent snapshots from ballooning disk usage
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd:3"
                    "noatime"
                    "discard=async"
                    "space_cache=v2"
                  ];
                };

                # System logs preserved across root rollbacks
                "@log" = {
                  mountpoint = "/var/log";
                  mountOptions = [
                    "compress=zstd:3"
                    "noatime"
                    "discard=async"
                    "space_cache=v2"
                  ];
                };

                # Local snapshots mountpoint
                "@snapshots" = {
                  mountpoint = "/.snapshots";
                  mountOptions = [
                    "compress=zstd:3"
                    "noatime"
                    "discard=async"
                    "space_cache=v2"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
