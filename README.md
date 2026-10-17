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

## Secret Management (SOPS w/ age)

Getting a public key from a host that should be able to decrypt secrets:

```bash
cat /etc/ssh/ssh_host_ed25519_key.pub | nix run nixpkgs#ssh-to-age
```

## Notes

Evaluating flake outputs for testing before deployment:

```bash
nix --extra-experimental-features 'nix-command flakes' eval 'git+file:///flake#nixosConfigurations.ns1.config.system.build.toplevel'
```

Getting the `hostName` output for example:

```bash
nix --extra-experimental-features 'nix-command flakes' eval 'git+file:///flake#nixosConfigurations.ns1.config.networking.hostName'
```

Finding out where it was set:

```bash
nix --extra-experimental-features 'nix-command flakes' eval --json 'git+file:///flake#nixosConfigurations.ns1.options.networking.hostName.definitionsWithLocations'

```

Building derivations for testing:
```bash
nix --extra-experimental-features 'flakes' repl .
# :b nixosConfigurations.ns1.config.services.service-self-check-heartbeat.script
```
