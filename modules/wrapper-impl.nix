{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
  inherit (builtins) mapAttrs;
  cleanEnvVars = envVars: mapAttrs (_: env: removeAttrs env [ "asFlags" ]) envVars;
  cleanPrograms =
    programs:
    mapAttrs (
      _: program: removeAttrs program [ "wrapFlags" ] // { envVars = cleanEnvVars program.envVars; }
    ) programs;
in
{
  options = {
    wrapped = mkOption {
      type = types.package;
      readOnly = true;
      description = "(Read-only) The final wrapped package";
    };

    overrideAttrs = mkOption {
      type = with types; functionTo attrs;
      description = ''
        Function to override attributes from the final package.
      '';
      default = lib.id;
      defaultText = lib.literalExpression "lib.id";
      example = lib.literalExpression ''
        old: {
          pname = "''${pname}-with-settings";
        }
      '';
    };

    postBuild = mkOption {
      type = types.str;
      default = "";
      description = "Raw commands to execute after the wrapping process has finished";
      example = ''
        echo "Running sanity check"
        $out/bin/nvim '+q'
      '';
    };
  };

  config = {
    wrapped =
      (
        (pkgs.mkWrapper {
          inherit (config)
            basePackage
            extraPackages
            prependFlags
            appendFlags
            pathAdd
            extraWrapperFlags
            wrapperType
            ;
          envVars = cleanEnvVars config.envVars;
          programs = cleanPrograms config.programs;
        }).overrideAttrs
        (_: prev: { buildCommand = prev.buildCommand + config.postBuild; })
      ).overrideAttrs
        config.overrideAttrs;
  };
}
