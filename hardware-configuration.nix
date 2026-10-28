{ lib, ... }:

{
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];

  boot.initrd.kernelModules = [ ];

  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  # hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;
}
