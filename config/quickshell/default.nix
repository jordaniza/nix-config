{config, lib, pkgs, ...}: let
  quickshell = lib.getExe config.programs.quickshell.package;
  shellConfig = "${config.xdg.configHome}/quickshell";
  themeFiles = import ../theme/render.nix {inherit pkgs;};
  powerAction = pkgs.writeShellApplication {
    name = "power-action";
    text = ''
      case "''${1-}" in
        lock) exec ${pkgs.systemd}/bin/loginctl lock-session ;;
        suspend) exec ${pkgs.systemd}/bin/systemctl suspend ;;
        restart) exec ${pkgs.systemd}/bin/shutdown -r now ;;
        shutdown) exec ${pkgs.systemd}/bin/shutdown now ;;
        *) echo "Unknown power action" >&2; exit 2 ;;
      esac
    '';
  };
  powerStatus = pkgs.writeShellApplication {
    name = "power-menu-status";
    runtimeInputs = [pkgs.coreutils pkgs.procps];
    text = ''
      readonly quickshell=${lib.escapeShellArg quickshell}
      readonly shell_config=${lib.escapeShellArg shellConfig}
    '' + builtins.readFile ./power-status.sh;
  };
  screenshotCopy = pkgs.writeShellApplication {
    name = "screenshot-copy";
    runtimeInputs = [pkgs.coreutils pkgs.wl-clipboard];
    text = builtins.readFile ./copy-screenshot.sh;
  };
  makeMenu = name: target: title: pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = [pkgs.coreutils pkgs.libnotify];
    text = ''
      readonly quickshell=${lib.escapeShellArg quickshell}
      readonly shell_config=${lib.escapeShellArg shellConfig}
      readonly menu_target=${lib.escapeShellArg target}
      readonly menu_title=${lib.escapeShellArg title}
    '' + builtins.readFile ./open-menu.sh;
  };
  powerMenu = makeMenu "power-menu" "power" "Power menu";
  screenshotHistory = makeMenu "screenshot-history" "screenshots" "Screenshots";
  tmuxMenu = makeMenu "tmux-menu" "tmux" "tmux";
  controlsMenu = makeMenu "controls-menu" "controls" "Controls";
  tmuxStatus = pkgs.writeShellApplication {
    name = "tmux-status";
    runtimeInputs = [pkgs.coreutils pkgs.procps pkgs.jq];
    text = ''
      readonly tmux=${lib.escapeShellArg (lib.getExe pkgs.tmux)}
      readonly counts_format_file=${lib.escapeShellArg "${themeFiles.waybarTmuxCounts}"}
      readonly quickshell=${lib.escapeShellArg quickshell}
      readonly shell_config=${lib.escapeShellArg shellConfig}
    '' + builtins.readFile ./tmux-status.sh;
  };
in {
  programs.quickshell = {
    enable = true;
    systemd.enable = true;
  };
  systemd.user.services.quickshell = {
    # This desktop starts Hyprland directly, without a systemd session target.
    # Hyprland's login/logout hooks own when this service runs.
    Install.WantedBy = lib.mkForce [];
    Unit = {
      ConditionEnvironment = ["WAYLAND_DISPLAY" "HYPRLAND_INSTANCE_SIGNATURE"];
      StartLimitIntervalSec = 30;
      StartLimitBurst = 3;
    };
    Service = {
      ExecStart = lib.mkForce "${quickshell} --path ${lib.escapeShellArg shellConfig} --no-duplicate";
      RestartSec = 2;
      # Restart=on-failure is supplied by the Home Manager module.
      Environment = [
        "PATH=${lib.makeBinPath [powerStatus tmuxStatus]}:/run/current-system/sw/bin"
      ];
    };
  };
  home.packages = [powerMenu powerStatus screenshotHistory tmuxMenu tmuxStatus controlsMenu];
  xdg.configFile = {
    "quickshell/config.json".text = builtins.toJSON {
      powerAction = lib.getExe powerAction;
      tmux = lib.getExe pkgs.tmux;
      # The full leader menu: key, label and destination are defined together.
      controlsActions = [
        {key = "p"; label = "Power"; menu = "power";}
        {key = "t"; label = "tmux"; menu = "tmux";}
        {key = "s"; label = "Screenshots"; menu = "screenshots";}
        {
          key = "c"; label = "Clipboard";
          command = [(lib.getExe pkgs.kitty) "--class" "cq-picker" "--title" "Clipboard history"
            "-o" "map=enter" "-o" "map=space" "-e" "${config.home.homeDirectory}/.local/bin/cq" "ls"];
        }
        {
          key = "b"; label = "Bluetooth";
          command = [(lib.getExe pkgs.kitty) "-T" "bluetuith" "-e" (lib.getExe pkgs.bluetuith)];
        }
        {
          key = "i"; label = "Internet";
          command = [(lib.getExe pkgs.kitty) "-T" "nmtui" "-e" "${pkgs.networkmanager}/bin/nmtui"];
        }
        {
          key = "v"; label = "Volume";
          command = [(lib.getExe pkgs.kitty) "-T" "pulsemixer" "-e" (lib.getExe pkgs.pulsemixer)];
        }
      ];
      screenshotCopy = lib.getExe screenshotCopy;
      screenshotDirectory = "${config.home.homeDirectory}/Pictures/Screenshots";
    };
    "quickshell/shell.qml".source = ./shell.qml;
    "quickshell/shared" = {
      source = ./shared;
      recursive = true;
    };
    "quickshell/components" = {
      source = ./components;
      recursive = true;
    };
  };
}
