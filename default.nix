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
      ] ++ modules;
      specialArgs = {
        pkgs = import ./pkgs/extended.nix pkgs;
      } // specialArgs;
    };
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
          pkgs = import ./pkgs/extended.nix pkgs;
        };
      }).config.wrapped;
  };
  helpers = pkgs: import ./pkgs { inherit pkgs; };
}
