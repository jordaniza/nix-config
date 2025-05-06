# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  inputs,
  device,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    #    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  # binplorer is related to a supply chain attack on some aragon repos. Don't remove it.
  networking.extraHosts = ''
    217.79.240.58  api.etherscan.io
    0.0.0.0 binplorer.com
    0.0.0.0 www.binplorer.com
    0.0.0.0 api.binplorer.com
    0.0.0.0 *.binplorer.com
  '';
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # tailscale
  services.tailscale = {
    enable = true;
  };

  # magic dns with tailscale
  # https://tailscale.com/kb/1063/install-nixos
  networking.nameservers = [
    "149.112.112.112" # du
    "9.9.9.9" # quad9
    "1.1.1.1" # cloudflare
    "8.8.8.8" # google
    "100.100.100.100" # default
  ];
  networking.search = ["kudu-catla.ts.net"];

  # Set your time zone.
  time.timeZone = "Asia/Dubai";
  # time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  services.xserver = {
    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    enable = true;

    # gnome support
    # if you migrate from kde cursor theme might be set to breeze

    # check with `dconf read /org/gnome/desktop/interface/cursor-theme`
    # and if it's wrong reset by using `dconf rest (same path as above)`
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };

    excludePackages = with pkgs; [
      xterm
    ];
  };

  # touchpad and mouse
  services.libinput = {
    enable = true;
    touchpad = {
      accelSpeed = "1.0";
      accelProfile = "flat";
    };
  };

  # keyboard - requires keyd installed
  services.keyd = {
    enable = true;

    # setup the custom keybindings
    keyboards = {
      default = {
        ids = ["*"];
        settings = {
          # sudo keyd monitor to see the keycodes
          main = {
          };

          control = {
            "space" = "backspace";
          };

          alt = {
            "space" = "enter";
          };
        };
      };
    };
  };

  systemd.services.keyd = {
    enable = true;
    serviceConfig = {
      CapabilityBoundingSet = ["CAP_SETGID"];
      Type = "simple";
      ExecStart = "${pkgs.keyd}/bin/keyd";
    };
    wantedBy = ["sysinit.target"];
    requires = ["local-fs.target"];
    after = ["local-fs.target"];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.sudo = {
    enable = true;
    extraConfig = "Defaults timestamp_timeout=30";
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # if on desktop - prevent suspension so we can ssh into it
  services.logind =
    if device == "desktop"
    then {
      extraConfig = ''
        IdleAction=ignore
         IdleActionSec=0
         InhibitDelayMaxSec=0
         HandleLidSwitch=ignore
         HandleLidSwitchDocked=ignore
         HandleSuspendKey=ignore
         HandleHibernateKey=ignore
      '';
    }
    else {};

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  users.groups.keyd = {}; # Create the keyd group

  # Define a user account. Manage user-based packages in home.nix
  users.users.jordan = {
    isNormalUser = true;
    description = "Jordan";
    extraGroups = ["networkmanager" "wheel"];
  };

  # home manager
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      "jordan" = import ./home.nix;
    };
  };

  # exclude gnome packages
  environment.gnome.excludePackages =
    (
      with pkgs; [
        gnome-photos
        gnome-tour
        gnome-text-editor
      ]
    )
    ++ (
      with pkgs.gnome; [
        gnome-music
        gnome-calendar
        gnome-maps
        yelp
        totem
        gnome-weather
        geary
        epiphany
        gnome-calculator
        gnome-clocks
        cheese
        gnome-contacts
        simple-scan
      ]
    );

  # set the zsh shell and set it as the default
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # nix config
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    home-manager
  ];

  # while this seems like a duplication
  # doesn't seem to work otherwise
  # I guess this is TODO
  fonts.packages = with pkgs; [nerdfonts];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      authorizedKeysFile = "/home/jordan/.ssh/authorized_keys";
    };
  };
  # Open ports in the firewall.
  # networking.firewall.alloowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
