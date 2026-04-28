{
  lib,
  pkgs,
  inputs,
  vars,
  extraLibs,
  ...
}:
{
  imports = [
    ./common
    ./linux
  ];
}
