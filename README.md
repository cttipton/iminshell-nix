# NixOS COSMIC VM

This is a learning-oriented NixOS flake for an x86_64 UEFI QEMU/KVM guest. It
uses Chaotic-Nyx to provide the CachyOS kernel package and its binary cache.

## Before installing

- Change `users.users.cody` in `configuration.nix` to your preferred account
  name.
- The VM disk must have an ext4 root filesystem labeled `nixos` and a FAT EFI
  system partition labeled `ESP`, mounted at `/` and `/boot` respectively.
- Use UEFI firmware (OVMF) for the VM. `nixos-install` will ask you to set the
  root password; on first boot, use a console login as root and run `passwd
  cody` (or your chosen username) to set the desktop account password.

The CachyOS kernel comes from the `chaotic-cx/nyx` flake. Its documented
`linuxPackages_cachyos` default is the CachyOS LTO + BORE kernel. This does not
replace the rest of Nixpkgs with Arch/CachyOS packages: those packages use
different package management and system integration.

## Try the configuration

Check that the Nix CLI is installed and flakes work by running:

```sh
nix --version
nix flake show
```

The flake output should list `nixosConfigurations.vm`. If `nix flake show`
reports that `nix-command` or `flakes` is disabled, enable both for this command
with:

```sh
nix --extra-experimental-features 'nix-command flakes' flake show
```

Then evaluate the selected kernel package:

```sh
nix eval .#nixosConfigurations.vm.config.boot.kernelPackages.kernel.name
```

Use the same `--extra-experimental-features 'nix-command flakes'` prefix with
`nix eval` if needed. The `nix.settings.experimental-features` setting in
`configuration.nix` takes effect on the configured NixOS system after you
rebuild; it does not enable flakes on a separate system where you are preparing
the configuration.

After installing NixOS and placing this configuration on the guest, build and
switch to it with:

```sh
sudo nixos-rebuild switch --flake .#vm
```

Update the pinned inputs deliberately with `nix flake update`, then rebuild.
Commit `flake.lock` so future rebuilds use the same revisions.

## CPU tuning

The VM starts with a portable x86_64 target. CPU-specific compiler flags are
left off because the guest must expose those CPU features; an incompatible
`-march` can make the system fail to run. For a VM configured with CPU
passthrough and a processor supporting x86-64-v3, add this to
`configuration.nix` and rebuild:

```nix
nixpkgs.hostPlatform.gcc.arch = "x86-64-v3";
```

This changes the compiler target for packages built from source, but does not
enable LTO globally. Expect many packages to build locally rather than use
Nixpkgs' generic binary cache. The CachyOS kernel already has its own LTO
configuration. Revisit the architecture target if you change the VM CPU model.

## Store cleanup

Automatic daily garbage collection with `--delete-generations +1` keeps only
the newest NixOS generation and removes unreferenced store paths; systemd-boot
also keeps only one boot entry. This intentionally sacrifices easy rollback.
The active system and packages still in use remain in the store, so this is not
a cache-size cap.