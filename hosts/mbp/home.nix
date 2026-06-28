{ ... }: {
  imports = [
    ../../modules/home/shared.nix
    ../../modules/home/gui.nix
    ../../modules/home/darwin/apps.nix
    ../../modules/home/darwin/aerospace.nix
    ../../modules/home/darwin/terminal.nix
  ];
}
