{ lib, ... }:
(import ./base64.nix { inherit lib; })
// (import ./rc4.nix { inherit lib; })
// {
  attrs = import ./attrs.nix { inherit lib; };
  relativeToRoot = lib.path.append ../.;
  scanPaths =
    path:
    map (name: path + "/${name}") (
      builtins.attrNames (
        lib.filterAttrs (
          name: type: type == "directory" || (name != "default.nix" && lib.hasSuffix ".nix" name)
        ) (builtins.readDir path)
      )
    );
}
