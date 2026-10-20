{
  outputs = _: {
    lib.mkBetterShell = import ./default.nix;
  };
}
