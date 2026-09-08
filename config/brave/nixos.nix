{...}: {
  # Brave reads managed policies from /etc, so this belongs in NixOS, not HM.
  # Explicit --profile-directory shortcuts still open their selected profile.
  environment.etc."brave/policies/managed/profile-picker.json".text = builtins.toJSON {
    ProfilePickerOnStartupAvailability = 2;
  };
}
