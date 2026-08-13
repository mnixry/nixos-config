let
  profiles = {
    darwin = import ../../profiles/darwin;
    home = import ../../profiles/home;
  };
in
{
  class = "darwin";
  system = "aarch64-darwin";
  stateVersion = 5;
  homeStateVersion = "26.05";

  user.name = "moonshot";

  profiles = {
    darwin = with profiles.darwin; [ workstation ];
    home = with profiles.home; [
      common
      darwin
    ];
  };
}
