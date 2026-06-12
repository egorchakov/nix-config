{
  self,
  pkgs,
  profile,
  ...
}:
{
  imports = [ ./darwin/homebrew.nix ];

  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  system = {
    primaryUser = profile.username;
    configurationRevision = self.rev or self.dirtyRev or null;
    stateVersion = 6;
  };

  environment.shells = with pkgs; [
    bashInteractive
    zsh
    nushell
  ];

  environment.systemPackages = with pkgs; [ nextdns ];

  users.users."${profile.username}" = {
    home = "/Users/${profile.username}";
    shell = pkgs.nushell;
  };

}
