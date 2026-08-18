{ pkgs, config, ... }:
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

    pinentry.package =
      if pkgs.stdenv.hostPlatform.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-qt;

    maxCacheTtl = 60 * 60 * 24; # 1 day
    maxCacheTtlSsh = 60 * 60 * 24; # 1 day
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        Compression = true;
        ServerAliveInterval = 5;
        ServerAliveCountMax = 10;
        SetEnv.TERM = "xterm-256color";
      };
      "github.com" = {
        HostName = "ssh.github.com";
        Port = 443;
        User = "git";
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
