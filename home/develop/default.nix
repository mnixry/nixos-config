{ extraLibs, ... }:
{
  imports = extraLibs.scanPaths ./.;

  programs.awscli = {
    enable = true;
  };
}
