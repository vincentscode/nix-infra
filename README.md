# Nix Infra

## Automated Updates

Dependabot automatically creates PRs to update the `flake.lock` file.

### Deployment

The contents of this repository are automatically deployed to all defined hosts within 60 seconds of being pushed to GitHub using [comin](https://github.com/nlewo/comin).

## Manual Updates

For those of us who have not succumbed to the call of NixOS for their personal workstation:

```bash
podman run --rm -v "$PWD:/flake:Z" -w /flake nixos/nix nix --extra-experimental-features 'nix-command flakes' flake update
```

Otherwise, probably just:

```bash
nix --extra-experimental-features 'nix-command flakes' flake update
```

### Deployment

```bash
nixos-rebuild switch --flake github:vincentscode/nix-infra[#hostname] --refresh
```

## Notes

Evaluating flake outputs for testing before deployment:

```bash
podman run --rm -v "$PWD:/flake:Z" -w /flake nixos/nix nix --extra-experimental-features 'nix-command flakes' eval 'git+file:///flake#nixosConfigurations.ns1.config.system.build.toplevel'
```

Getting the `hostName` output for example:

```bash
podman run --rm -v "$PWD:/flake:Z" -w /flake nixos/nix nix --extra-experimental-features 'nix-command flakes' eval 'git+file:///flake#nixosConfigurations.ns1.config.networking.hostName'
```

Finding out where it was set:

```bash
podman run --rm -v "$PWD:/flake:Z" -w /flake nixos/nix nix --extra-experimental-features 'nix-command flakes' eval --json 'git+file:///flake#nixosConfigurations.ns1.options.networking.hostName.definitionsWithLocations'

```
