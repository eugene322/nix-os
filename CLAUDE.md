# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a declarative NixOS configuration using flakes, home-manager, disko, impermanence, sops-nix, and stylix. The system implements an ephemeral root ("erase your darlings") pattern where `/` is wiped on every boot and restored from a pristine snapshot.

**Key architectural principle**: The root subvolume (`@`) is reset to `@-blank` on every boot via an initrd systemd service. Only explicitly persisted state survives reboots.

**Package channels**: Uses stable `nixos-25.05` for system packages, with `nixos-unstable` available for specific packages that need latest versions (e.g., `claude-code`).

## Critical Git Workflow

**IMPORTANT**: NixOS flakes only see files tracked by git. After ANY modification to `.nix` files, you MUST run `git add -A` before building/testing, or changes will be invisible to the build system and may cause "file not found" errors.

## Common Commands

All commands assume you're in `~/workspace/nix-os` (or wherever the repo is cloned). Shell aliases are defined in `home/shell.nix`.

### Build and Apply Changes
```bash
git add -A                # REQUIRED before any build operation
rebuild                   # sudo nixos-rebuild switch --flake ~/workspace/nix-os#desktop
```

### Update Dependencies
```bash
update                    # nix flake update && rebuild
```

### Rollback
```bash
sudo nixos-rebuild switch --rollback
# Or select a previous generation from the bootloader menu
```

### Garbage Collection
```bash
cleanup                   # nix-collect-garbage -d && nixos-rebuild boot
# Automatic GC runs weekly (see modules/nixos/nix.nix)
```

### Testing Without Applying
```bash
git add -A
nix flake check                              # validate flake structure
nixos-rebuild build --flake .#desktop        # build without switching
nix fmt                                      # format with nixfmt-rfc-style
```

### Development Shell
```bash
nix develop               # enter shell with git, nixd, nixfmt-rfc-style, sops, age
```

### Secrets Management (sops-nix)
```bash
# One-time setup:
ssh-to-age < /persist/etc/ssh/ssh_host_ed25519_key.pub   # get host age key
cp .sops.yaml.example .sops.yaml                          # configure encryption keys
nix develop -c sops secrets/secrets.yaml                  # create/edit secrets

# Then uncomment relevant secrets in modules/nixos/secrets.nix and rebuild
```

### Snapshot Management (snapper)
```bash
sudo snapper -c home list              # list /home snapshots
sudo snapper -c persist list           # list /persist snapshots
sudo snapper -c home undochange A..B   # rollback /home to snapshot range
```

## Architecture

### Modular Structure

- `flake.nix` — Central entry point defining all inputs and the `desktop` NixOS configuration
- `hosts/desktop/` — Host-specific settings (thin layer)
  - `configuration.nix` — Imports hardware config, disk layout, and all system modules
  - `disk-config.nix` — Disko disk partitioning with Btrfs subvolumes
  - `hardware-configuration.nix` — Generated hardware config (not in git initially)
- `modules/nixos/` — Reusable system modules
  - `default.nix` — Aggregates all modules; comment out lines to disable features
  - Individual modules for nix settings, boot, networking, locale, users, security, secrets, impermanence, snapper, stylix, desktop (Hyprland), nvidia
- `home/` — home-manager configuration for user `eugene`
  - `default.nix` — User packages and session variables
  - Individual modules for shell (zsh), git, development tools, desktop apps
- `templates/` — Dev environment starters for direnv (devenv/flake-based)

### Ephemeral Root (Impermanence)

The system uses an aggressive impermanence pattern implemented in `modules/nixos/impermanence.nix`:

1. **Boot process**: An initrd systemd service (`rollback`) runs before mounting `/`, deletes the current `@` subvolume, and recreates it from the pristine `@-blank` snapshot
2. **What survives**:
   - Separate Btrfs subvolumes: `/home`, `/nix`, `/persist`, `/var/log`, `/.snapshots`, `/tmp`, `/swap`
   - Files/directories explicitly listed in `environment.persistence."/persist"` (e.g., `/var/lib/nixos`, `/etc/machine-id`, SSH host keys, NetworkManager connections, Bluetooth state)
3. **What is erased**: Everything else in `/` that isn't on a separate subvolume or explicitly persisted

**When adding stateful services**: If state disappears after reboot, add the path to `environment.persistence."/persist".directories` or `.files` in `modules/nixos/impermanence.nix`.

### Disk Layout (Disko + Btrfs)

Defined in `hosts/desktop/disk-config.nix`:
- 1 GiB ESP (FAT32) at `/boot`
- Remainder as single Btrfs partition with label `nixos`, containing subvolumes:
  - `@` → `/` (ephemeral, reset to `@-blank` each boot)
  - `@home` → `/home`
  - `@nix` → `/nix`
  - `@persist` → `/persist`
  - `@log` → `/var/log`
  - `@snapshots` → `/.snapshots`
  - `@tmp` → `/tmp`
  - `@swap` → `/swap` (with 8GB swapfile, CoW disabled)

All subvolumes use `compress=zstd` and `noatime`.

### Home Manager Integration

Home-manager runs as a NixOS module (not standalone). User configuration is at `home/default.nix` and imported via `flake.nix` line 69:
```nix
users.eugene = import ./home;
```

Shell aliases (`rebuild`, `update`, `cleanup`) are defined in `home/shell.nix` and assume the repo lives at `~/workspace/nix-os`.

### Secrets (sops-nix)

- Configuration scaffold: `modules/nixos/secrets.nix`
- Encrypted secrets file: `secrets/secrets.yaml` (created manually with `sops`)
- Host decryption key derived from `/persist/etc/ssh/ssh_host_ed25519_key` (must persist across boots)
- Secrets stay commented in `secrets.nix` until properly configured

### Desktop Environment

Hyprland (Wayland tiling compositor) is configured at two levels:
- **System**: `modules/nixos/desktop.nix` — enables Hyprland, portals, PipeWire audio
- **User**: `home/desktop.nix` — keybindings, workspaces, animations, waybar, rofi

**Key Hyprland keybindings** (modifier = SUPER/Windows key):
- `SUPER + Return` — Open terminal (kitty)
- `SUPER + D` — Application launcher (rofi)
- `SUPER + Q` — Close window
- `SUPER + B` — Open browser (firefox)
- `SUPER + E` — File manager (thunar)
- `SUPER + V` — Toggle floating
- `SUPER + F` — Fullscreen
- `SUPER + 1-9` — Switch workspace
- `SUPER + SHIFT + 1-9` — Move window to workspace
- `SUPER + H/J/K/L` or arrow keys — Move focus
- `SUPER + SHIFT + H/J/K/L` — Move window
- `SUPER + S` — Scratchpad toggle
- `SUPER + C` — Clipboard history (cliphist)
- `Print` — Screenshot area
- `SUPER + M` — Exit Hyprland

**Components**:
- **waybar** — Status bar (top) with workspaces, clock, system info
- **rofi** — Application launcher and window switcher
- **dunst** — Notification daemon
- **swww** — Wallpaper daemon (wallpaper set by stylix)
- **cliphist** — Clipboard manager

Colors and fonts are managed by stylix for consistent theming.

### Hardware-Specific Modules

- `modules/nixos/nvidia.nix` — NVIDIA open drivers, remove import on AMD/Intel systems
- `hosts/desktop/hardware-configuration.nix` — Generated with `nixos-generate-config --no-filesystems` on target hardware

## Binary Caches

Configured in `modules/nixos/nix.nix`:
- `cache.nixos.org` (official)
- `nix-community.cachix.org`
- `cuda-maintainers.cachix.org` (for NVIDIA/CUDA builds)

## Formatting and LSP

- Formatter: `nixfmt-rfc-style` (run with `nix fmt`)
- LSP: `nixd` (available in `nix develop`)

## Installation Notes

This is a reference for understanding the setup (full install instructions in README.md):

1. The `@-blank` snapshot MUST be created during initial install (after disko formats but before nixos-install), while `@` is still empty
2. `hardware-configuration.nix` is generated on the target machine with `--no-filesystems` flag (disko provides filesystem config)
3. User password MUST be set declaratively (`hashedPassword` in `modules/nixos/users.nix`) or via SSH keys, as it won't survive the first reboot otherwise

## Unstable Packages

Some packages (like `claude-code`) are installed from `nixos-unstable` to get the latest versions. To add more unstable packages:

1. In `home/default.nix` (or other home modules), use `pkgs-unstable.package-name` instead of just `package-name`
2. Example: `pkgs-unstable.neovim` instead of `neovim`
3. For system-level packages, add `pkgs-unstable` to module arguments and use similarly

The unstable channel is defined in `flake.nix` as a separate input and passed to home-manager via `extraSpecialArgs`.

## Host Configuration

Single host defined: `desktop` (x86_64-linux). To add hosts, duplicate `hosts/desktop/` and add a new `nixosConfigurations.<hostname>` entry in `flake.nix`.
