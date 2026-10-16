{ lib, ... }:

let
  ssdMountOptions = [
    "compress=zstd:3"
    "noatime"
    "discard=async"
    "space_cache=v2"
  ];

  hddMountOptions = [
    "compress=zstd:3"
    "noatime"
    "autodefrag"
    "space_cache=v2"
  ];
in
{
  disko.devices = {
    disk = {
      # ── WD_BLACK SN850X 1TB (NVMe: System + Active Datasets) ──
      nvme = {
        type = "disk";
        device = lib.mkDefault "/dev/disk/by-id/nvme-WD_BLACK_SN850X_1000GB_2252AG468004";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
                extraArgs = [
                  "-n"
                  "BOOT"
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "-L"
                  "nixos"
                ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = ssdMountOptions;
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = ssdMountOptions;
                  };
                  "@cache" = {
                    mountpoint = "/home/gosha20777/.cache";
                    mountOptions = ssdMountOptions;
                  };
                  "@datasets-active" = {
                    mountpoint = "/home/gosha20777/Documents/Datasets/Active";
                    mountOptions = ssdMountOptions;
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = ssdMountOptions;
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = ssdMountOptions;
                  };
                  "@snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = ssdMountOptions;
                  };
                };
              };
            };
          };
        };
      };

      # ── Seagate BarraCuda 8TB (HDD-2: Storage + Inactive Datasets + Media) ──
      data = {
        type = "disk";
        device = lib.mkDefault "/dev/disk/by-id/ata-ST8000DM004-2U9188_ZR14R78K";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "-L"
                  "data"
                ];
                subvolumes = {
                  "@storage" = {
                    mountpoint = "/mnt/storage";
                    mountOptions = hddMountOptions;
                  };
                  "@datasets-storage" = {
                    mountpoint = "/home/gosha20777/Documents/Datasets/Storage";
                    mountOptions = hddMountOptions;
                  };
                  "@videos" = {
                    mountpoint = "/home/gosha20777/Videos";
                    mountOptions = hddMountOptions;
                  };
                  "@music" = {
                    mountpoint = "/home/gosha20777/Music";
                    mountOptions = hddMountOptions;
                  };
                  "@games" = {
                    mountpoint = "/home/gosha20777/Games";
                    mountOptions = hddMountOptions;
                  };
                  "@snapshots" = {
                    mountpoint = "/mnt/storage/.snapshots";
                    mountOptions = hddMountOptions;
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
