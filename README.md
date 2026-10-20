# mkBetterShell

An alternative to `pkgs.mkShell`.

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
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
    mkbettershell.url = "https://tangled.org/averms.org/mkbettershell/archive/trunk.tar.gz";
  };

  outputs =
    { nixpkgs, mkbettershell, ... }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    {
      devShells = nixpkgs.lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = mkbettershell.lib.mkBetterShell pkgs {
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
