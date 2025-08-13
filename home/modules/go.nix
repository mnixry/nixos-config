{
  config,
  lib,
  ...
}:
let
  description = "Another approach for configuring GOENV";
  inherit (lib) types;
  cfg = config.programs.go;
in
{
  options.programs.go.env = lib.mkOption {
    type = types.attrs;
    default = null;
    example = {
      gopath = "go";
      goamd64 = "v3";
    };
    description = description;
  };

  config = (
    lib.mkIf (cfg.env != null) {
      # ref: https://github.com/golang/go/blob/master/src/cmd/go/internal/envcmd/env.go
      xdg.configFile."go/env".text = (
        lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${lib.toUpper name}=${value}") cfg.env)
      );
    }
  );
}
