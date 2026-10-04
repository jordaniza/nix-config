let
  # Reuse this repository's pins and existing machine-selection workflow.
  flake = builtins.getFlake ("path:" + toString ../..);
  pkgs = flake.nixosConfigurations.default.pkgs;
in pkgs.mkShellNoCC {
  packages = [
    pkgs.python3
    pkgs.nix
    pkgs.bash
    pkgs.coreutils
    pkgs.util-linux
    pkgs.qt6.qtdeclarative
    pkgs.quickshell
  ];
  QML_IMPORT_PATH = "${pkgs.qt6.qtdeclarative}/lib/qt-6/qml";
  QT_PLUGIN_PATH = "${pkgs.qt6.qtbase}/lib/qt-6/plugins";
}
