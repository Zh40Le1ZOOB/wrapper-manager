{ pkgs }:
{
  mkWrapper = pkgs.callPackage ./mk-wrapper.nix { };
}
