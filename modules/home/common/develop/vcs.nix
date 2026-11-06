{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
let
  difft = lib.getExe config.programs.difftastic.package;
in
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

  # Structural diff. Plain `git diff` keeps patch output for scripts;
  # use `git difftool` or the d* aliases below for difft.
  # `jj diff` uses difft by default; `jj diff --git` gives a patch.
  programs.difftastic = {
    enable = true;
    git = {
      enable = true;
      mode = "difftool";
    };
    jujutsu.enable = true;
  };

  programs.git.settings = {
    difftool.prompt = false;
    pager.difftool = true;
    alias = {
      ddiff = "-c diff.external=${difft} diff";
      dshow = "-c diff.external=${difft} show --ext-diff";
      dlog = "-c diff.external=${difft} log -p --ext-diff";
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
