{
  config,
  lib,
  ...
}:
# System audit config, ref:
# - https://github.com/arianvp/nixos-stuff/blob/master/configs/framework/audit.nix
# - https://cyber.trackr.live/stig/Anduril_NixOS/1/1
{
  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
  };

  security.apparmor = {
    enable = true;
    enableCache = true;
  };

  # Don't allow any  binaries outside of nix store
  # fileSystems."/".options = [ "nosuid" "nodev" "noexec" ];

  # nix store can have executables
  # fileSystems."/nix/store" = { device = "none"; options = [ "bind" "nosuid" "nodev" ]; };

  boot.kernelParams = [ "audit=1" ];
  security.audit =
    let
      inherit (config.nixpkgs.hostPlatform) linuxArch;
    in
    {
      enable = true;
      # audit usage of any  suid/guid binaries.
      # On NixOS it is guaranteed that no suid binaries are present out side of /run/wrappers
      rules =
        [
          # ANIX-00-000210
          # NixOS must generate audit records for all usage of privileged commands.
          "-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k execpriv"
          "-a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -k execpriv"
          "-a always,exit -F arch=b32 -S execve -C gid!=egid -F egid=0 -k execpriv"
          "-a always,exit -F arch=b64 -S execve -C gid!=egid -F egid=0 -k execpriv"

          # ANIX-00-000270
          # Successful/unsuccessful uses of the mount syscall in NixOS must generate an
          # audit record.
          "-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=unset -k privileged-mount"
          "-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=unset -k privileged-mount"

          # ANIX-00-000280
          # Successful/unsuccessful uses of the rename, unlink, rmdir, renameat, and unlinkat system calls in NixOS must generate an audit record.
          # NOTE: this is extremely noisy
          # "-a always,exit -F arch=b32 -S rename,unlink,rmdir,renameat,unlinkat -F auid>=1000 -F auid!=unset -k delete"
          # "-a always,exit -F arch=b64 -S rename,unlink,rmdir,renameat,unlinkat -F auid>=1000 -F auid!=unset -k delete"

          # ANIX-00-000290
          # Successful/unsuccessful uses of the init_module, finit_module, and delete_module system calls in NixOS must generate an audit record.
          "-a always,exit -F arch=b32 -S init_module,finit_module,delete_module -F auid>=1000 -F auid!=unset -k module_chng"
          "-a always,exit -F arch=b64 -S init_module,finit_module,delete_module -F auid>=1000 -F auid!=unset -k module_chng"
        ]
        ++ (lib.mapAttrsToList (
          _: wrap:
          "-a always,exit -F arch=${linuxArch} -F path=${config.security.wrapperDir}/${wrap.program} -F perm=x -F auid>=1000 -F auid!=unset -k security.wrappers.${wrap.program}"
        ) config.security.wrappers)
        ++ [
        ];
    };
  systemd.sockets."systemd-journald-audit".wantedBy = [ "sockets.target" ];
  security.auditd.enable = true;
}
