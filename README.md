# Setup NixOS

```
sudo -s
loadkeys no-latin1

# Partition
parted /dev/vda -- mklabel gpt
parted /dev/vda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/vda -- set 1 boot on
parted /dev/vda -- mkpart primary 512MiB 100%

# Encrypt and create  p/v/l volumes
cryptsetup luksFormat /dev/vda2
cryptsetup open /dev/vda2 enc
pvcreate /dev/mapper/enc
vgcreate vol1 /dev/mapper/enc
lvcreate -L 16G vol1 -n swap
lvcreate -l 100%FREE vol1 -n root

# Create filesystems
mkfs.vfat -F 32 -n boot /dev/vda1
mkswap -L swap /dev/vol1/swap
mkfs.ext4 -L root /dev/vol1/root

# Mount
mount /dev/vol1/root /mnt
mkdir /mnt/boot
mount /dev/vda1 /mnt/boot
swapon /dev/vol1/swap

# Configuration
mkdir -p /mnt/etc/nixos
cd /mnt/etc/nixos
nix-shell -p git
git clone https://github.com/netbrain/nix ../nixos
nix-generate-config --root /mnt --dir <machine-name>

# Add encryption config to <machine-name>/configuration.nix
boot.initrd.luks.devices = {
  crypted = {
    device = "/dev/disk/by-uuid/<uuid of vda2>";
    preLVM = true;
  };
};

# Install
nixos-install --flake .#<machine-name> --no-root-passwd
```

# Setup Nix & Home Manager standalone

```
sh <(curl -L https://nixos.org/nix/install) --no-daemon
nix run home-manager/master -- --flake github:netbrain/nix switch
# or git clone and then the above with --flake .
```

# Adding secrets

```
sops ./secrets/secrets.yaml

```
