{ pkgs, stdenv, lib, fetchpatch, fetchFromGitHub, buildUBoot, buildPackages }:

let
  buildPatchedUBoot =
    { defconfig, BL31, ROCKCHIP_TPL ? "", extraPatches ? [ ] }:
    let
      inherit defconfig BL31 ROCKCHIP_TPL extraPatches;
      src = fetchFromGitHub {
        owner = "u-boot";
        repo = "u-boot";
        rev = "v2024.04";
        sha256 = "IlaDdjKq/Pq2orzcU959h93WXRZfvKBGDO/MFw9mZMg=";
      };
      version = "v2024.04-0-g25049ad5608"; # git describe --long
    in buildUBoot {
      src = src;
      version = version;
      defconfig = defconfig;
      filesToInstall = [ "u-boot-rockchip.bin" ];

      extraPatches = extraPatches;

      BL31 = BL31;
      ROCKCHIP_TPL = ROCKCHIP_TPL;

      extraMeta = {
        platforms = [ "aarch64-linux" ];
        license = lib.licenses.unfreeRedistributableFirmware;
      };
    };
  buildRK3588UBoot = defconfig:
    buildPatchedUBoot {
      inherit defconfig;
      BL31 = "${pkgs.armTrustedFirmwareRK3588}/bl31.elf";
    };
in {
  uBootRadxa-5-ITX = buildRK3588UBoot "roc-pc-rk3588_defconfig";
}
