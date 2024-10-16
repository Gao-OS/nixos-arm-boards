# NixOS Images for ARM Boards

Flake to build images for arm based boards that require custom uboot firmware.

Utilizes sd-card installer build infrastructure from nixpkgs.

## Image Building

### Installer

Check out `flake.nix` for the list of supported configurations.
To build an installer sd-card image for desired platform using flake execute
`nix build github:Gao-OS/nixos-arm-boards#Radxa-5-ITX` or `nix build .#Radxa-5-ITX`

``` console
$ nix build github:nabam/nixos-arm-boards#Radxa-5-ITX
$ sfdisk --dump result/sd-image/nixos-sd-image-*.img

...

```

Built image then can be copied to sdcard or other memory:

``` console
sudo dd if=./result/sd-image/nixos-sd-image-*.img of=/dev/mmcblk0 status=progress
```

To build image run:

``` console
nix build .#Radxa-5-ITX
```

### Custom Image

Check out [the example](/example) to see how custom images can be built with this flake.

To build the example run: `(cd example && nix flake update && nix build)`.

#### Exported Modules

##### nixosModules.sdImageRockchip

Configures custom image build.

#### nixosModules.sdImageRockchipInstaller

Configures installer image build.
