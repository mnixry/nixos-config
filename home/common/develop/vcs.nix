{ vars, ... }: {
  programs.git = {
    enable = true;
    settings.user = {
      name = "${vars.git.name}";
      email = "${vars.git.email}";
    };
  };

  programs.jujutsu = {
    enable = true;
    settings.user = {
      name = "${vars.git.name}";
      email = "${vars.git.email}";
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
