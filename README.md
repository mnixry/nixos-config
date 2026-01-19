# Mix's NixOS configuration

## Preface

> 你这辈子就是被 NixOS 毁了，没法像个正常人一样用电脑，
> 对着 Ubuntu Server 敲命令的时候，总是在想，要是这能用一个 `configuration.nix` 描述就好了，[毕竟现在这系统就像纸牌屋，抽掉一张就全塌了](https://www.reddit.com/r/NixOS/comments/1p9163p/nixos_ruined_all_other_distros_for_me/)；看到软件依赖报错的时候，总是在想，系统状态要是只读且原子化更新就好了，帮同事配环境的时候，他说帮我装个旧版本的 Python，你的心怦怦跳，总是在想，他要是污染了全局环境怎么办？他要是搞出了依赖地狱怎么办？然后他直接 sudo pip install 甚至还加了 `--break-system-packages`，屏幕上滚动的每一行日志都充满了不确定性的肮脏，你问你的 Flake 锁文件在哪？这环境脏了怎么回滚？他沉默了一会说哥，我这是 Debian，我就想跑个脚本。
>
> NixOS brain rot is real, and it has destroyed my ability to function in society.
> Every time I touch Ubuntu, I feel dirty. I'm typing commands thinking, _"Where is the declarative config? Why is this system mutable?"_ It feels like Jenga—one wrong move and it's over. I was helping a colleague set up a legacy Python env today and I swear I got PTSD. I’m sweating, thinking about global namespace pollution. Then I watch him type `sudo pip install`... and he actually adds `--break-system-packages`. I watched the terminal output scrolling by and it just looked like imperative sin. Pure entropy. I asked him, _"Where is the Flake? How do we ensure reproducibility? How do we rollback?"_ He just looked at me and said, "Dude, chill. It's Debian. I'm just trying to run a script."

## Highlights

- Flakes + pinned inputs: `nixos-unstable` + a `nixos-25.11` stable input (used for a few packages).
- Ephemeral root: `/` is tmpfs; persistence is declared in `preservation.nix`.
- Disk layout: Btrfs-on-LUKS with subvolumes `@nix`, `@tmp`, `@swap`, `@persistent`, and a swapfile at `/swap/swapfile` (see `system/partition.nix`).
  - Btrfs scrub + `beesd` are enabled.
  - Initrd is systemd-based; LUKS is configured via `boot.initrd.luks.devices.*` (see `system/secureboot.nix`).
- Secure Boot: `lanzaboote` + `sbctl`; PKI bundle at `/var/lib/sbctl` (persisted). `systemd-boot` is disabled.
- Kernel & perf: `linux_xanmod_latest` with LLVM ThinLTO, zstd `-22` initrd, BBR TCP, SCX scheduler (`scx_lavd`). See `system/kernel.nix`.
- Graphics: Intel `xe` + NVIDIA PRIME (open, beta driver) + DisplayLink override. Specialisations: `intel-xe`, `battery-saver`. See `system/hardware.nix`.
- Desktop: SDDM + Plasma 6; `niri` session enabled.
- Input method: Fcitx5 (Wayland frontend) + Rime (`rime-ice`, etc.), integrated with Plasma.
- Apps:
  - Browsers: Firefox Developer Edition (policies + privacy prefs), Ungoogled Chromium
  - Password manager: Bitwarden
  - Sandboxed “nixpaks” (nixpak-based wrappers): Telegram, Lark, QQ, WeChat, Spotify, WPS Office, Wemeet
- Virtualisation/containers: Docker (btrfs, buildx, youki/kata runtimes) + Portainer, libvirt/virt-manager, multi-arch `binfmt`.
- Networking/proxy: `dae` (unstable) with config at `/etc/dae/config.dae` (persisted).
- Security: AppArmor, sudo-rs, auditd rules, TPM2 (pkcs11 + TCTI env), ragenix for secrets.
- Dev tooling: Rust (rust-overlay), Go, Node (pnpm/yarn), Python (pdm/uv/poetry), Cursor/VS Code/JetBrains, starship, atuin, nix-index.

## Repo layout

- `flake.nix`: inputs + `nixosConfigurations.${vars.network.hostname}` (single-host model driven by `vars/`).
- `vars/`: host/user/hardware variables (hostname, user name, boot/root devices, LUKS mapper name, initial hashed password).
- `system/`: base OS (nix settings, kernel, security, locales, hardware, partition layout, secure boot, secrets module).
- `services/`: system services (pipewire/printing/fingerprint, virtualisation, `dae`).
- `desktop/`: desktop defaults + overlays (fonts, debuginfod, `nix-ld`, Plasma/Niri, nixpak-based “nixpaks”, IDA packaging).
- `home/`: Home Manager config (shell, browsers, IME, Plasma theming + Kvantum, dev stacks).
- `libs/`: helpers (e.g. `scanPaths` to auto-import module files in a directory).
- `preservation.nix`: persistence rules for `/persistent` (system + user data).

## License

MIT. See [`LICENSE`](./LICENSE).
