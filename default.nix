pkgs:
{
  stdenv ? pkgs.stdenvNoCC,
  ...
}@args:
let
  inherit (pkgs) lib;
  mkShell' = pkgs.mkShell.override {
    stdenv = stdenv.override {
      initialPath = [
        pkgs.coreutils
        pkgs.findutils
        pkgs.bashNonInteractive
      ];
    };
  };
  bare = mkShell' { };
  builderVars = builtins.filter (v: v != "name" && builtins.match "[a-z_].*" v != null) (
    builtins.attrNames bare.drvAttrs ++ bare.outputs
  );
  mkShellArgs = removeAttrs args [ "stdenv" ];
in
mkShell' (
  {
    # Good default
    strictDeps = true;
    # Keep stdenv from adding -rpath $out/lib, which points into the nonexistent ./outputs/out
    NIX_NO_SELF_RPATH = true;
  }
  // mkShellArgs
  // {
    shellHook =
      # Derivation attributes, which only the builder and its phases read
      ''
        unset ${toString builderVars}
      ''
      # Set by Nix and stdenv's setup. Read only there or by the builder phases
      + ''
        unset shell dontAddDisableDepTrack HOST_PATH NIX_NO_SELF_RPATH NIX_BUILD_CORES NIX_APPLE_SDK_VERSION
      ''
      # Only use the flags the user specifies
      + ''
        unset NIX_HARDENING_ENABLE
      ''
      # Allow -march=native
      + ''
        unset NIX_ENFORCE_NO_NATIVE
      ''
      # Use ld-prime on macOS
      + lib.optionalString (stdenv.hasCC && stdenv.hostPlatform.isDarwin) ''
        export CCC_OVERRIDE_OPTIONS="# +--start-no-unused-arguments +--ld-path=$(unset DEVELOPER_DIR; /usr/bin/xcrun --find ld) +--end-no-unused-arguments"
      ''
      + args.shellHook or "";
  }
)
