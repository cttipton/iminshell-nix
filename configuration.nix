{ pkgs, ... }:
{
  networking.hostName = "nixos-vm";
  networking.networkmanager.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 1;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [
    "ahci"
    "nvme"
    "xhci_pci"
    "virtio_blk"
    "virtio_pci"
    "virtio_scsi"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  users.users.cody = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.settings.keep-derivations = false;
  nix.settings.keep-outputs = false;

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-generations +1";
  };

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Etc/UTC";

  system.stateVersion = "26.05";
}