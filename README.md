# nixos-starter

A single, generic [NixOS](https://nixos.org/) flake — the baseline I actually run
across my own machines in 2026, stripped of everything that only made sense on
*my* LAN and pushed out here so you can adopt the shape.

**Authored by [Ross](https://github.com/RossGeordie).** Distilled from the two
boxes that carry my daily life:

- an **HP Elite X360** — laptop, daily driver and Steam machine
- a **Minisforum MS-01** — i9 mini-workstation running headless-ish with a
  remote-desktop overlay

Both live on **NixOS 26.05**, **KDE Plasma 6 (X11)**, **Home Manager**, and a
flake layout identical to this one, so nothing in here is theory — it's the
boring, boring parts of configs I've stopped being surprised by.

---

## What you get

| Layer | Choice |
|---|---|
| Boot | systemd-boot + UEFI variable touching |
| Desktop | Plasma 6 on **X11**, SDDM login |
| Audio | PipeWire (with Pulse compatibility shim) |
| Input/locale | UK layout, en_GB locale — **change to yours** |
| User | one normal account, in `wheel` (sudo) |
| Home Manager | release-matched to nixos-26.05, zsh, a few CLI essentials |
| Nix | flakes on, automatic GC |
| Firewall | on, port 22 open |

Everything else — hardware, WiFi, battery — is either in the example host or
generated for you by Nix's own tools.

## Quick start

```bash
git clone https://github.com/RossGeordie/nixos-starter.git && cd nixos-starter
cp -r hosts/example hosts/machinename        # give it a real name
sudo nixos-hw-sync machinename hosts/machinename/hardware-configuration.nix
nixos-rebuild build --flake .#machinename   # test-compile
nixos-rebuild switch --flake .#machinename  # deploy
```

That's the whole ritual. `nixos-hw-sync` writes the one file you were never
supposed to hand-type.

## Things I deliberately did (so you know to change them)

1. **The user is literally named `user`.** Change the key in `lib/defaults.nix`
   *and* `flake.nix` and `lib/home.nix` to your actual name. Home Manager and
   the NixOS user must agree on the account key.
2. **`Europe/London` + `en_GB` + `uk` keymap.** My bias, my problem — not yours.
3. **`allowUnfree = true`.** Only there because I run Brave. If you use a
   free browser, flip it off and let Nix keep you honest.
4. **X11.** Some of the capture/remote tooling I use is simply more stable
   under X11 than Wayland in 2026. If you don't need it, Plasma on Wayland is
   a two-line change and you get the nicer compositor.

## Extending it

These are the pieces I keep in my own private per-machine configs and would add
to this repo if they were machine-agnostic enough:

- **Steam + Gamescope + GameMode** with ProtonUP and `mangohud`
- **RustDesk** with a session-autostart (X11-only reason, see above)
- **NFS automount block** for network shares (vers=3, automount, nofail)
- **SDDM autologin** for unattended boxes — with the gotcha that it's the
  `settings.Autologin{User,Session}` block, not a standalone module

Tell me if you want any of these promoted to proper shared modules and I'll
write them.

## License

MIT. Use it, fork it, break it, send me a PR with your improvements.
