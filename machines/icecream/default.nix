{lib, ...}: let
  ls = lib.filesystem.listFilesRecursive;
  primary-disk = import values/disko-main-device.nix;
in {
  imports =
    [
      ./disko.nix
      ./hardware.nix
      ./user.nix

    ]
    ++ ls ./modules
    ++ ls ../../modules/system
    ++ ls ../../modules/options;

  boot.loader.limine.biosDevice = primary-disk;
  disko.devices.disk.main.device = primary-disk;
  disko.devices.disk.ssd1.device = import values/disko-ssd1-device.nix;
  system.stateVersion = "26.05";
  networking.hostId = "2896c4e1";
  zramSwap.enable = true;
}
