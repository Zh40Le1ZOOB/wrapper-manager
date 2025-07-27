let
  eval =
    {
      pkgs,
      lib ? pkgs.lib,
      modules ? [ ],
      specialArgs ? { },
    }:
    lib.evalModules {
      modules = [
        ./modules/many-wrappers.nix
      ]
      ++ modules;
      specialArgs = {
        pkgs = extendPkgs pkgs;
      }
      // specialArgs;
    };

  getPkgs =
    pkgs:
    pkgs.lib.packagesFromDirectoryRecursive {
      inherit (pkgs) callPackage newScope;
      directory = ./pkgs;
    };
  extendPkgs = pkgs: pkgs.extend (_: prev: getPkgs prev);
in
{
  lib = {
    inherit eval;
    __functor = _: eval;
    wrapWith =
      pkgs: module:
      (pkgs.lib.evalModules {
        modules = [
          ./modules/wrapper.nix
          module
        ];
        specialArgs = {
          pkgs = extendPkgs pkgs;
        };
      }).config.wrapped;
  };
  inherit getPkgs;
}
