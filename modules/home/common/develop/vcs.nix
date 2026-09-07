{ pkgs, vars, ... }:
{
  home.packages = [ pkgs.jj-vine ];

  programs.git = {
    enable = true;
    settings.user = {
      name = "${vars.git.name}";
      email = "${vars.git.email}";
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "${vars.git.name}";
        email = "${vars.git.email}";
      };
      aliases.vine = [
        "util"
        "exec"
        "--"
        "jj-vine"
      ];
      git.private-commits = "description('wip:*') | description('private:*')";
    };
  };

  programs.jjui = {
    enable = true;
    settings = {
      preview.show_at_start = true;
      ssh.hijack_askpass = true;
    };
  };
}
