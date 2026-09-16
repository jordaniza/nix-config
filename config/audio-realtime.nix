{device, lib, ...}: let
  directRtkit = {
    "rtportal.enabled" = false;
    "rtkit.enabled" = true;
  };
in {
  services.pipewire = lib.mkIf (device == "desktop") {
    # Work around Realtime portal process-identity failures.
    # Keep RTKit's priority limits and starvation protection.
    extraConfig.pipewire."90-direct-rtkit" = {
      "module.rt.args" = directRtkit;
    };

    extraConfig.pipewire-pulse."90-direct-rtkit" = {
      "module.rt.args" = directRtkit;
    };

    wireplumber.extraConfig."90-direct-rtkit" = {
      # WirePlumber 0.5.10 does not forward module.rt.args.
      # Preserve its default modules while changing only RT routing.
      # Recheck this list when upgrading WirePlumber.
      "override.context.modules" = [
        {
          name = "libpipewire-module-rt";
          args = directRtkit // {
            "nice.level" = -11;
          };
          flags = ["ifexists" "nofail"];
        }
        {name = "libpipewire-module-protocol-native";}
        {name = "libpipewire-module-metadata";}
      ];
    };
  };
}
