# Standard single-disk Btrfs layout for Legacy BIOS systems (GRUB + GPT bios_grub partition)
{ lib, ... }:
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = lib.mkDefault "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          # BIOS boot partition for GRUB on GPT (type EF02)
          boot = {
            size = "1M";
            type = "EF02";
            priority = 1;
          };

          # Main Btrfs partition
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd:3"
                    "noatime"
                    "discard=async"
                    "space_cache=v2"
                  ];
                };

                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [
                    "compress=zstd:3"
                    "noatime"
                    "discard=async"
                    "space_cache=v2"
                  ];
                };

                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd:3"
                    "noatime"
                    "discard=async"
                    "space_cache=v2"
                  ];
                };

                "@log" = {
                  mountpoint = "/var/log";
                  mountOptions = [
                    "compress=zstd:3"
                    "noatime"
                    "discard=async"
                    "space_cache=v2"
                  ];
                };

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
