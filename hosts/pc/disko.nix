{ lib, ... }:

let
  btrfsMountOptions = [
    "compress=zstd:3"
    "noatime"
    "discard=async"
    "space_cache=v2"
  ];
in
{
  disko.devices = {
    disk = {
      # ── Samsung 970 PRO (System + Active Data) ──
      samsung = {
        type = "disk";
        device = lib.mkDefault "/dev/disk/by-id/nvme-Samsung_SSD_970_PRO_512GB_S5JYNS0N907879H";
        content = {
          type = "gpt";
          partitions = {
            # EFI System Partition
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
            # Main System Partition
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = btrfsMountOptions;
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = btrfsMountOptions;
                  };
                  "@cache" = {
                    mountpoint = "/home/gosha20777/.cache";
                    mountOptions = btrfsMountOptions;
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = btrfsMountOptions;
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = btrfsMountOptions;
                  };
                  "@snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = btrfsMountOptions;
                  };
                };
              };
            };
          };
        };
      };

      # ── WD SN550 (Games + Media) ──
      wd = {
        type = "disk";
        device = lib.mkDefault "/dev/disk/by-id/nvme-WDC_WDS500G2B0C-00PXH0_2108B9449712";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@games" = {
                    mountpoint = "/home/gosha20777/Games";
                    mountOptions = btrfsMountOptions;
                  };
                  "@pictures" = {
                    mountpoint = "/home/gosha20777/Pictures";
                    mountOptions = btrfsMountOptions;
                  };
                  "@music" = {
                    mountpoint = "/home/gosha20777/Music";
                    mountOptions = btrfsMountOptions;
                  };
                  "@videos" = {
                    mountpoint = "/home/gosha20777/Videos";
                    mountOptions = btrfsMountOptions;
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
