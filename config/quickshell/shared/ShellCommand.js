// Quote each literal argument for Hyprland's shell-based exec dispatcher.
function fromArgv(argv) {
    return argv.map(argument => "'" + argument.replace(/'/g, "'\\''") + "'").join(" ");
}
