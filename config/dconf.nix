{ pkgs, ... }:

{
   dconf = {
    enable = true;
    settings = {
      # configure system settings
      "org/gnome/desktop/interface" = {
         color-scheme = "prefer-dark";
         clock-show-seconds = true;
         clock-show-weekday = true;
      };
      
	# launchers
        "org/gnome/settings-daemon/plugins/media-keys" = {
          "custom-keybindings" = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          name = "Launch Brave";
          command = "brave";
          binding = "<Super>b";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          name = "Launch Terminal";
          command = "kitty";
          binding = "<Super>t";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
          name = "Launch Discord";
          command = "discord";
          binding = "<Super>d";
        };

      "org/gnome/desktop/wm/keybindings" = {
        toggle-maximize = ["<Super>m"]; 
	close=["<Alt>F4" "<Super>q" "<Alt>AudioPrev" "<Alt>AudioMicMute"];
	move-to-workspace-1=["<Shift><Super>Home" "<Shift><Super>F1" "<Shift><Super>exclam" "<Shift><Super>AudioMute"];
	move-to-workspace-2=["<Shift><Super>F2" "<Shift><Super>at" "<Shift><Super>AudioLowerVolume"];
	move-to-workspace-3=["<Shift><Super>F3" "<Shift><Super>numbersign" "<Shift><Super>AudioRaiseVolume"];
	move-to-workspace-4=["<Shift><Super>F4" "<Shift><Super>dollar" "<Shift><Super>AudioPrev" "<Shift><Super>AudioMicMute"];
	switch-applications=["<Super>Tab"];
	switch-applications-backward=["<Shift><Super>Tab"];
	switch-to-workspace-1=["<Super>Home" "<Super>F1" "<Super>1" "<Super>AudioMute"];
	switch-to-workspace-2=["<Super>F2" "<Super>AudioLowerVolume"];
	switch-to-workspace-3=["<Super>F3" "<Super>3" "<Super>AudioRaiseVolume"];
	switch-to-workspace-4=["<Super>F4" "<Super>4" "<Super>AudioPrev" "<Super>AudioMicMute"];
	switch-windows=["<Alt>Tab"];
	switch-windows-backward=["<Shift><Alt>Tab"];
      };

      # setup the extensions here
      "org/gnome/shell" = {
        disable-user-extensions = false; # allow user extensions
        enabled-extensions = with pkgs.gnomeExtensions; [
          burn-my-windows.extensionUuid
          clipboard-history.extensionUuid
          gtile.extensionUuid
        ];
      };

      "org/gnome/shell/extensions/clipboard-history" = {
	paste-on-selection = false;
	toggle-menu = ["<Super>v"];
      };

      "org/gnome/shell/extensions/burn-my-windows" = {
        last-extension-version = 42;
	last-prefs-version = 42;
	prefs-open-count = 1;
	# todo: default to the hexagon effect - takes 2 seconds but would be nice to do it declaratively
      };

      "org/gnome/shell/extensions/gtile" = {
	action-move-left=[""];
	action-move-right=[""];
	debug=false;
	global-auto-tiling=false;
	global-presets=true;
	grid-sizes="3x3,6x3";
	preset-resize-1=["<Control><Super>KP_1"];
	preset-resize-11=[""];
	preset-resize-12=[""];
	preset-resize-13=[""];
	preset-resize-14=[""];
	preset-resize-15=[""];
	preset-resize-16=[""];
	preset-resize-17=[""];
	preset-resize-18=[""];
	preset-resize-19=[""];
	preset-resize-2=["<Control><Super>KP_2"];
	preset-resize-3=["<Control><Super>KP_3"];
	preset-resize-4=["<Control><Super>KP_4"];
	preset-resize-5=["<Control><Super>KP_5"];
	preset-resize-6=["<Control><Super>KP_6"];
	preset-resize-7=[""];
	preset-resize-8=[""];
	preset-resize-9=[""];
	resize1="3x1 1:1 1:1";
	resize2="3x1 2:1 2:1";
	resize3="3x1 3:1 3:1";
	resize4="3x1 1:1 2:1";
	resize5="6x1 2:1 5:1";
	resize6="3x1 2:1 3:1";
	show-grid-lines=true;
	show-icon=true;
	theme="Minimal Dark";
      };
    };
  };
}
