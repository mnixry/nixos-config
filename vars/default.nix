{
  git = {
    name = "Mix";
    email = "32300164+mnixry@users.noreply.github.com";
  };

  linux = {
    hostname = "mix-laptop-21tl";
    user = {
      name = "mix";
      fullname = "HexMix";
      initialHashedPassword = "$gy$j9T$5Oax3RFzgwFa0qQdVLktl.$pKJKEnCVf6TBcJZL3cWV7yIxUDhFhj9iYJgHC5ujzH0";
    };
    hardware = {
      bootDevice = "/dev/disk/by-partuuid/c52e2372-9927-46e2-b626-d1b658ab622a";
      rootDevice = "/dev/disk/by-uuid/febcf993-9a92-4ed9-8bb2-8df8bc810af6";
      luksName = "system";
    };
  };

  darwin = {
    hostname = "mix-moonshot";
    user = {
      name = "moonshot";
    };
  };
}
