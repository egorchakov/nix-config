{ ... }: {
  imports = [
    ./shared.nix
    ./gui.nix
    ./darwin/apps.nix
    ./darwin/aerospace.nix
    ./darwin/terminal.nix
  ];
}
