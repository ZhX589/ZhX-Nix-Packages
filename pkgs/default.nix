{ system ? builtins.currentSystem
, config ? { }
, overlays ? [ ]
}:

let
  pkgs = import <nixpkgs> { inherit system config overlays; };
in
{
  vutronmusic = pkgs.callPackage ./vutronmusic { };
}
