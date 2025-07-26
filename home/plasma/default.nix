{
  inputs,
  extraLibs,
  ...
}:
{
  imports = [ inputs.plasma-manager.homeManagerModules.plasma-manager ] ++ extraLibs.scanPaths ./.;

  programs.plasma = {
    enable = true;

    powerdevil = {
      AC = {
        whenSleepingEnter = "hybridSleep";
        powerProfile = "performance";
        autoSuspend.action = "nothing";
      };
      battery = {
        whenSleepingEnter = "standbyThenHibernate";
        powerProfile = "powerSaving";
      };
      lowBattery = {
        whenLaptopLidClosed = "hibernate";
      };
    };

    configFile = {
      baloofilerc."Basic Settings"."Indexing-Enabled" = false;
    };

    fonts =
      let
        mkGeneralFont = size: {
          family = "Sans Serif";
          pointSize = size;
        };
      in
      {
        fixedWidth = {
          family = "Monospace";
          pointSize = 10;
        };
        general = mkGeneralFont 10;
        menu = mkGeneralFont 10;
        small = mkGeneralFont 10;
        toolbar = mkGeneralFont 10;
        windowTitle = mkGeneralFont 10;
      };
  };
}
