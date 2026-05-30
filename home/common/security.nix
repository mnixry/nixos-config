{
  pkgs,
  vars,
  config,
  ...
}:
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
    enableZshIntegration = true;
    enableBashIntegration = true;

    pinentry.package = if pkgs.stdenv.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-qt;

    maxCacheTtl = 60 * 60 * 24; # 1 day
    maxCacheTtlSsh = 60 * 60 * 24; # 1 day
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
    settings = {
      "*" = {
        compression = true;
        serverAliveInterval = 5;
        serverAliveCountMax = 10;
      };
      "github.com" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
      };
    };
  };

  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "${config.xdg.dataHome}/password-store";
    };
  };
}
