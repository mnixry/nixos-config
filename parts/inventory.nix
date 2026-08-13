{ lib, ... }:
let
  extraLibs = import ../lib { inherit lib; };
  hostPaths = extraLibs.scanPaths ../hosts;
  hostDirectories = lib.filter (path: (builtins.readFileType path) == "directory") hostPaths;
  hosts = lib.mapAttrs (
    name: path:
    let
      host = import path;
    in
    assert lib.assertMsg (
      (host.name or name) == name
    ) "Host ${host.name} must live in hosts/${host.name}";
    host // { inherit name; }
  ) (lib.listToAttrs (map (path: lib.nameValuePair (baseNameOf path) path) hostDirectories));
  vars = import ../vars;
in
{
  systems = lib.unique (lib.mapAttrsToList (_: host: host.system) hosts);
  inherit hosts;
  _module.args = { inherit extraLibs hosts vars; };
}
