<p align="center">
  <a href="https://deepwiki.com/egorchakov/nix-config"><img src="https://deepwiki.com/badge.svg" alt="Ask DeepWiki"></a>
</p>

## NixOS

```nu
sudo nixos-rebuild switch --refresh --flake github:egorchakov/nix-config
```

## nix-darwin

```nu
sudo nix run nix-darwin/master#darwin-rebuild -- switch --refresh --flake github:egorchakov/nix-config
```

## home-manager

```nu
nix run home-manager/master -- switch --refresh --flake github:egorchakov/nix-config
```

Use `nix fmt` for formatting and `just follow` to update input follows explicitly.
