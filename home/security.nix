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
    pinentry.package = pkgs.pinentry-qt;
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "${vars.user.fullname}";
      email = "${vars.user.email}";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      compression = true;
    };
    matchBlocks."github.com" = {
      host = "github.com";
      hostname = "ssh.github.com";
      port = 443;
      user = "git";
      controlMaster = "auto";
      controlPath = "~/.ssh/control-%r@%h:%p";
      controlPersist = "yes";
    };
  };
}
