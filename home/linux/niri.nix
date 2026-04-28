{ config, ... }:
{
  programs.niri.settings = {
    cursor.theme = config.home.pointerCursor.name;
  };
}
