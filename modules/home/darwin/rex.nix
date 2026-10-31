{
  addressedHosts,
  config,
  lib,
  pkgs,
  profile,
  self,
  ...
}:
let
  # TODO: Remove the watcher, SSH jobs, and ../server.nix agent workaround once
  # Rex forwards the Mac's SSH agent to remote sessions natively.
  watcher = pkgs.runCommandCC "rex-agent-watch" { } ''
    mkdir -p "$out/bin"
    $CC -O2 -fobjc-arc -fblocks -framework AppKit \
      ${./rex-agent-watch.m} -o "$out/bin/rex-agent-watch"
  '';

  agents = pkgs.linkFarm "rex-agent-jobs" (
    lib.mapAttrsToList (hostname: _: {
      name = "${hostname}.plist";
      path = pkgs.writeText "rex-agent-${hostname}.plist" (
        lib.generators.toPlist { escape = true; } {
          Label = "org.nix-community.home.rex-agent.${hostname}";
          ProgramArguments = [
            "/usr/bin/ssh"
            "-A"
            "-n"
            "-tt"
            "-S"
            "none"
            "-o"
            "BatchMode=yes"
            "-o"
            "ClearAllForwardings=yes"
            "-o"
            "ConnectTimeout=10"
            "-o"
            "ServerAliveInterval=30"
            "-o"
            "ServerAliveCountMax=3"
            "-o"
            "LogLevel=ERROR"
            "-l"
            profile.username
            hostname
            "/home/${profile.username}/.local/libexec/rex-forward-agent"
          ];
          RunAtLoad = true;
          KeepAlive = true;
          ThrottleInterval = 30;
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/rex-agent-${hostname}.log";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/rex-agent-${hostname}.log";
        }
      );
    }) addressedHosts
  );
in
{
  imports = [ self.inputs.rex.homeManagerModules.default ];

  programs.rex = {
    enable = true;
    package = null;
    config = lib.concatLines (
      lib.mapAttrsToList (hostname: _: ''
        rex.host ${
          lib.generators.toLua { } {
            label = hostname;
            endpoint = "https://rex-${hostname}.tail50f327.ts.net";
          }
        }
      '') addressedHosts
    );
  };

  launchd.agents.rex-agent-watch = {
    enable = true;
    config = {
      ProgramArguments = [
        "${watcher}/bin/rex-agent-watch"
        "${agents}"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/rex-agent-watch.log";
    };
  };
}
