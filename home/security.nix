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

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "${vars.user.fullname}";
    userEmail = "${vars.user.email}";
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
    };
  };
}
