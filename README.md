# Mix's NixOS configuration

Personal NixOS configuration for `mix-laptop-21tl` using flakes. It features an ephemeral root, secure boot, NVIDIA + Intel PRIME, and a curated developer/desktop environment.

## Highlights

- **Flakes + Unstable**: Pinned to `nixos-unstable` via `flake.nix`.
- **Ephemeral root**: `/` on tmpfs with persistence managed by `preservation` ("erase your darlings"). See `preservation.nix` and `system/partition.nix`.
- **Disk/LUKS**: Encrypted Btrfs on LUKS with FIDO2 support. Devices/labels come from `vars/default.nix`.
- **Secure Boot**: `lanzaboote` + `sbctl`, PKI under `/var/lib/sbctl` (persisted). Systemd-boot is disabled.
- **Kernel/perf**: CachyOS kernel, zstd `-22` initrd, BBR TCP, SCX scheduler (`scx_lavd`). See `system/kernel.nix`.
- **Graphics**: Intel Meteor Lake (xe) + NVIDIA PRIME (open) + DisplayLink override. Specialisations: `intel-xe`, `battery-saver`. See `system/hardware.nix`.
- **Desktop**: KDE Plasma 6 (SDDM) with optional `niri`. Fcitx5 + Rime (ICE), Plasma theming, Kvantum.
- **Apps**: Browsers (Firefox Dev Edition hardened, Ungoogled Chromium). Nixpaks: Telegram, Lark, QQ, Spotify.
- **Virtualisation**: libvirtd/QEMU, Docker (btrfs, buildx, youki), Portainer container, multi-arch `binfmt`.
- **Networking/Proxy**: `dae` service; config at `/etc/dae/config.dae` (persisted).
- **Developer toolchain**: Rust (rust-overlay), Go (configured env), Node (pnpm/yarn), Python (uv, pdm, poetry), editors (Cursor/VS Code), starship, atuin, nix-index.
- **Security**: AppArmor, sudo-rs, extensive auditd rules, TPM2 (pkcs11 + env), debuginfod.

## Repo layout

- **`flake.nix`**: Inputs and `nixosConfigurations.${vars.network.hostname}`.
- **`vars/`**: Host/user/hardware variables (hostname, LUKS/root/boot devices).
- **`system/`**: Base OS (nix settings, kernel, security, locales, hardware, partition, secure boot, secrets integration).
- **`services/`**: System services (audio/pipewire, printing, fingerprint, virtualisation, `dae`).
- **`desktop/`**: Display manager/Plasma/Niri, fonts, nix-ld libs, nixpaks overlays.
- **`home/`**: Home Manager (shell, browsers, IME, Plasma, dev stacks).
- **`libs/`**: Helpers (e.g., `scanPaths` to auto-import module files in a directory).
- **`preservation.nix`**: Persistent paths under `/persistent` for the ephemeral root model.

## Target and assumptions

- Target host: `mix-laptop-21tl` (set in `vars/default.nix`).
- Filesystem: Btrfs-on-LUKS with devices specified in `vars/default.nix`.
- Hardware profile: Intel Meteor Lake + NVIDIA PRIME; adjust `system/hardware.nix` for other machines.

## Quick start (existing system)

```bash
# 1) Clone
git clone https://github.com/<you>/nixos-config.git
cd nixos-config

# 2) Adjust variables for your machine
$EDITOR vars/default.nix   # hostname, user, boot/root devices, luks name

# 3) Switch to this configuration
sudo nixos-rebuild switch --flake .#mix-laptop-21tl
```

### Fresh install (clean machine)

1. Partition, create LUKS + Btrfs subvolumes compatible with `system/partition.nix` (subvols: `@nix`, `@tmp`, `@swap`, `@persistent`).
2. Mount subvolumes per that layout, `nixos-generate-config` is not required here (flake provides modules).
3. Copy this repo to the target filesystem and set `vars/default.nix` accordingly.
4. Install:

```bash
sudo nixos-install --flake /mnt/path/to/nixos-config#mix-laptop-21tl
```

### Secure Boot (lanzaboote)

On first boot (once):

```bash
sudo sbctl create-keys
sudo sbctl enroll-keys
sudo sbctl status
```

Keys live in `/var/lib/sbctl` and are persisted via `preservation.nix`.

## Specialisations

Two specialisations are available via the boot menu:

- `intel-xe`: Forces Intel `xe` driver, blacklists `i915` for device ID.
- `battery-saver`: Enables powertop auto-tuning.

## Developer environment

- Rust (rust-overlay)
- Go (tooling + env)
- Python (pdm/uv/poetry)
- Node (pnpm/yarn)
- Editors (Cursor/VS Code)
- starship
- atuin
- nix-index

## Rebuild, update, rollback

```bash
# Rebuild current config
sudo nixos-rebuild switch --flake .#mix-laptop-21tl

# Update inputs
nix flake update
sudo nixos-rebuild switch --flake .#mix-laptop-21tl

# Optional: nh helpers (installed in Home Manager)
nh os switch        # shorthand wrapper for rebuild
nh clean all        # GC/cleanup

# Roll back to the previous generation
sudo nixos-rebuild --rollback
```

## Persistence model

- Only paths listed in `preservation.nix` are kept under `/persistent` across reboots. Add more paths there if needed.
- User directories (Downloads, Documents, tool caches, editor configs, etc.) are persisted. System directories like `/var/lib/docker`, `/var/lib/libvirt`, `/var/lib/sbctl`, `/etc/ssh`, NetworkManager connections, etc., are also preserved.

## License

This project is licensed under the MIT License. See [`LICENSE`](./LICENSE) for details.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
