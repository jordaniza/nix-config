# Hand-maintained desktop hardware configuration.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  pciAddress = "0000:01:00.0";
in {
  _module.args.customHardware = {
    gpu = {
      renderNode = "/dev/dri/by-path/pci-${pciAddress}-render";
      driPrime =
        "pci-${builtins.replaceStrings [":" "."] ["_" "_"] pciAddress}";
    };
  };

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4992bdb3-5e7a-40d9-a078-c07871e6584f";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/69B1-4350";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/c5d9b2fe-421d-4dfa-a6f7-ce2dbe0efae0";}
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp12s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp13s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Stable card names for Hyprland's colon-separated GPU priority list.
  services.udev.extraRules = lib.mkIf config.programs.hyprland.enable ''
    SUBSYSTEM=="drm", KERNEL=="card[0-9]*", KERNELS=="${pciAddress}", SYMLINK+="dri/rx580"
    SUBSYSTEM=="drm", KERNEL=="card[0-9]*", KERNELS=="0000:11:00.0", SYMLINK+="dri/integrated"
  '';

  # Match the successful RX580-primary session test on this desktop only.
  environment.sessionVariables = lib.mkIf config.programs.hyprland.enable {
    AQ_DRM_DEVICES = "/dev/dri/rx580:/dev/dri/integrated";
  };

  # GPU acceleration settings
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      mesa
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
}
