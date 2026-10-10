# Virtualization stack: QEMU/KVM hypervisor, libvirtd, virt-manager GUI,
# and Windows guest integration tools (VirtIO, SPICE, swtpm).
{ config, pkgs, ... }:
let
  vmDir = "/home/${config.systemSettings.username}/Documents/VMs";
in
{
  # Hypervisor daemon
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [ pkgs.OVMFFull.fd ];
      };
    };
  };

  # Virt-manager desktop GUI
  programs.virt-manager.enable = true;

  # SPICE USB redirection (allows redirecting physical USB devices, e.g. scanners, into VM)
  virtualisation.spiceUSBRedirection.enable = true;

  # Companion tools & guest drivers
  environment.systemPackages = with pkgs; [
    virtio-win # Windows VirtIO drivers ISO (VirtIO SCSI, Net, Balloon, SPICE tools)
    spice-gtk # USB redirection & clipboard support
  ];

  # VM disk storage in ~/Documents/VMs with Btrfs nodatacow (+C) optimization.
  # Symlink /var/lib/libvirt/images -> ~/Documents/VMs so virt-manager's default storage pool
  # automatically creates disks in Documents/VMs without manual pool reconfiguration.
  systemd.tmpfiles.rules = [
    "d ${vmDir} 0755 ${config.systemSettings.username} users -"
    "h ${vmDir} - - - - +C"
    "L+ /var/lib/libvirt/images - - - - ${vmDir}"
  ];
}
