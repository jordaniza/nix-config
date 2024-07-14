# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:
let 
  btrfsUUID = "e151ec67-e360-4039-9549-d4c367fa7d4c";
  swapFileSizeMB = 32 * 1024;
in
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # btrfs subvolumes will need manual mounting the first time the device is setup
  # create the /mnt directory
  # mount the luks drive to it if not already
  # create the btrfs subvolumes at sudo btrfs subvolume create /mnt/@whatever
  # unmount /mnt
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/${btrfsUUID}";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/${btrfsUUID}";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/swap" =
    { device = "/dev/disk/by-uuid/${btrfsUUID}";
      fsType = "btrfs";
      options = [ "subvol=@swap" ];
    };
  
  boot.initrd.luks.devices."luks-288f3d0b-d963-4649-bba2-dab419f89373".device = "/dev/disk/by-uuid/288f3d0b-d963-4649-bba2-dab419f89373";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/049C-3FCF";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = swapFileSizeMB;   
    }
   ];

  # Swap settings
  systemd.tmpfiles.rules = [
    "d /swap 0755 root root - -"
    "f /swap/swapfile 0600 root root ${toString swapFileSizeMB}M"
  ];

  system.activationScripts.createSwapFile.text = ''
    if ! mountpoint -q /swap; then
      mount -o subvol=@swap /dev/disk/by-uuid/${btrfsUUID} /swap
    fi
    if [ ! -f /swap/swapfile ]; then
      dd if=/dev/zero of=/swap/swapfile bs=1M count=${toString swapFileSizeMB}
      truncate -s 0 /swap/swapfile
      chattr +C /swap/swapfile
      fallocate -l ${toString swapFileSizeMB}M /swap/swapfile
      chmod 600 /swap/swapfile
      mkswap /swap/swapfile
      swapon /swap/swapfile
    fi
    
  '';


  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
