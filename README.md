<p align="center">
  <a href="https://deepwiki.com/egorchakov/nix"><img src="https://deepwiki.com/badge.svg" alt="Ask DeepWiki"></a>
</p>

# nix config

## NixOS

```bash
sudo nixos-rebuild switch --refresh --flake github:egorchakov/nix-config
```

## nix-darwin

```bash
sudo nix run nix-darwin/master#darwin-rebuild -- switch --refresh --flake github:egorchakov/nix-config
```

## home-manager

```bash
nix run home-manager/master -- switch --refresh --flake github:egorchakov/nix-config
```
