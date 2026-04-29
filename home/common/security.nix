{ pkgs, vars, ... }:
{
  programs.gpg = {
    enable = true;
    mutableKeys = false;
    mutableTrust = false;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    pinentry.package = if pkgs.stdenv.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-qt;
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "${vars.git.name}";
      email = "${vars.git.email}";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      compression = true;
    };
  };
}
