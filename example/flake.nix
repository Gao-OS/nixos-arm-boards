{
  description = "Build NixOS image for Radxa 5 ITX";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    rockchip = { url = "github:Gao-OS/nixos-arm-boards"; };
  };

  nixConfig = {
  };

  outputs = { self, ... }@inputs:
    let
      osConfig = buildPlatform:
        inputs.nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            inputs.rockchip.nixosModules.sdImageRockchip
            ./config.nix
            {
              # Use cross-compilation for uBoot and Kernel.
              rockchip.uBoot =
                inputs.rockchip.packages.${buildPlatform}.uBootRadxa-5-ITX;
              boot.kernelPackages =
                inputs.rockchip.legacyPackages.${buildPlatform}.kernel_linux_6_6_rockchip;
            }
          ];
        };
    in {
      nixosConfigurations.radxa-5-itx = osConfig "x86_64-linux";
    } // inputs.utils.lib.eachDefaultSystem (system: {
      # Set buildPlatform to "x86_64-linux" to benefit from cross-compiled packages in the cache.
      packages.image = (osConfig "x86_64-linux").config.system.build.sdImage;

      # Or use configuration below to cross-compile kernel and uBoot on the current platform.
      # packages.image = (osConfig system).config.system.build.sdImage;

      packages.default = self.packages.${system}.image;
    });
}
