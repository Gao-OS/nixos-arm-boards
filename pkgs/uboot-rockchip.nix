{
  pkgs,
  stdenv,
  lib,
  fetchpatch,
  fetchFromGitHub,
  buildUBoot,
  buildPackages,
}: let
  buildPatchedUBoot = {
    defconfig,
    BL31,
    ROCKCHIP_TPL ? "",
    extraPatches ? [],
  }: let
    inherit defconfig BL31 ROCKCHIP_TPL extraPatches;
    src = fetchFromGitHub {
      owner = "u-boot";
      repo = "u-boot";
      rev = "v2024.10";
      sha256 = "UPy7XM1NGjbEt+pQr4oQrzD7wWWEtYDOPWTD+CNYMHs=";
    };
    version = "v2024.10-0-gf919c3a889"; # git describe --long
  in
    buildUBoot {
      src = src;
      version = version;
      defconfig = defconfig;
      filesToInstall = ["u-boot-rockchip.bin"];

      extraPatches = extraPatches;

      BL31 = BL31;
      ROCKCHIP_TPL = ROCKCHIP_TPL;

      extraMeta = {
        platforms = ["aarch64-linux"];
        license = lib.licenses.unfreeRedistributableFirmware;
      };
    };
  buildRK3588UBoot = defconfig: let
    rkbin = fetchFromGitHub {
      owner = "rockchip-linux";
      repo = "rkbin";
      rev = "b4558da0860ca48bf1a571dd33ccba580b9abe23";
      sha256 = "KUZQaQ+IZ0OynawlYGW99QGAOmOrGt2CZidI3NTxFw8=";
    };
  in
    buildPatchedUBoot {
      inherit defconfig;
      BL31 = "${pkgs.armTrustedFirmwareRK3588}/bl31.elf";
      ROCKCHIP_TPL = rkbin + "/bin/rk35/rk3588_ddr_lp4_2112MHz_lp5_2400MHz_v1.16.bin";
    };
in {
  uBootRadxa-5-ITX = buildRK3588UBoot "rock-5-itx-rk3588_defconfig";
}
