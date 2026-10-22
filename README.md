# mkBetterShell

A wrapper for `pkgs.mkShell` with better defaults.

## Usage

### In shell.nix

```nix
{
  pkgs ? import <nixpkgs> { },
  mkBetterShell ? import (fetchTarball "https://tangled.org/averms.org/mkbettershell/archive/trunk.tar.gz") pkgs,
}:
mkBetterShell {
  packages = [
    pkgs.pnpm
    pkgs.nodejs-slim_26
  ];
}
```

Then, do
```shell
curl -fsSL https://tangled.org/averms.org/mkbettershell/raw/trunk/.envrc.recommended -o .envrc
```

### In flake

```nix
{
  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixpkgs-unstable";
    mkbettershell.url = "https://tangled.org/averms.org/mkbettershell/archive/trunk.tar.gz";
  };

  outputs =
    { nixpkgs, mkbettershell, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          mkBetterShell = mkbettershell.lib.mkBetterShell pkgs;
        in
        {
          default = mkBetterShell {
            packages = [
              pkgs.pnpm
              pkgs.nodejs-slim_26
            ];
          };
        }
      );
    };
}
```

Then, do
```shell
curl -fsSL https://tangled.org/averms.org/mkbettershell/raw/trunk/.envrc.flakerecommended -o .envrc
```

## License

This software is distributed under the Blue Oak Model License 1.0.0.
