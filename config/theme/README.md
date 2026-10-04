# Theme

Edit colors, shared font families and corner radius in `palette.nix`. Edit
component styles in the native files here. Other modules import this module or
reference its installed files; do not add inline CSS or local color overrides.

`render.nix` owns every explicit template substitution:

| Input | Output consumer |
| --- | --- |
| `gtk-colors.css.in` | Shared GTK color declarations imported by both CSS files |
| `waybar.css` | Bar styling |
| `wofi.css` | Launcher styling |
| `hyprland.conf.in` | Window borders, gaps, decorations and animations |
| `kitty.conf.in` | Terminal palette, typography, padding and tab styling |
| `tmux.conf.in` | Dracula chevrons, hidden session label, pane borders and selection colors |
| `mako.conf.in` | Notification appearance, including critical border color |
| `quickshell/Theme.qml.in` | Shared QML colors and typography |

`pkgs.replaceVars` substitutes named `@token@` placeholders and rejects missing
or unused replacements at build time. Native GTK references such as
`@rice_accent` remain untouched. CSS imports use absolute store paths. Kitty
and tmux use native includes; Mako includes its installed theme file. Home
Manager installs the outputs through `default.nix`. The tmux status layout reproduces
the previous Dracula chevrons directly, with its colors supplied by the shared
palette; the external Dracula status plugin is not needed.

`hyprlock.nix` owns lock-screen appearance using native Nix settings. Authentication
and enablement remain in the component module. `gtk.nix` owns GTK fonts, the
existing Adwaita-dark integration and GNOME's named purple accent. Nautilus and
other libadwaita apps use their supported dark appearance; their internal colors
and geometry are not forced to match Dracula. The named GNOME accent is a
separate palette setting because it cannot accept arbitrary RGB values.

The terminal palette also colors ordinary ANSI-based TUIs such as `lf`. Applications
with their own explicit themes (including the existing Neovim Dracula setup)
retain those. Wallpaper selection, bar module content/layout and application
behavior remain outside this migration. The ignored Kitty styling keys `letter_spacing`, `enable_ligatures` and
`window_title_format` are removed; native `disable_ligatures never` retains the
existing default ligature behavior.

Follow the repository preview/approval process. The user builds and activates
configuration changes; there is no runtime file rewriting.

Quickshell loads the centrally installed `~/.config/theme/quickshell/` through
the `~/.config/quickshell/theme` consumer link declared in `default.nix`. Its
relative QML imports must stay inside the Quickshell configuration root.
Edit palette colors/font families in `palette.nix`; edit QML typography sizes in
`quickshell/Theme.qml.in`; `MenuSurface.qml`,
`MenuRow.qml`, `MenuError.qml` and `PowerAppearance.qml` for component appearance;
`Icons.qml` for the icon set. All remain in this directory;
`render.nix` is the only template adapter. Opening, keyboard behavior and action
commands belong in `config/quickshell/`. QML styling uses properties, not CSS.

Installed include files use `~/.config/theme/` (Hyprland, Mako and Quickshell).
Waybar and Wofi receive their theme-owned CSS at their native `style.css` paths
for automatic discovery. These are Home Manager links to generated theme outputs;
their source styles and rendering still live exclusively in this directory.
