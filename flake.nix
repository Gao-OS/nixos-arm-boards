{
  description = "Build NixOS images for arm boards";

  inputs = {
      # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, ... }@inputs:
    let
      # Use cross-compilation for uBoot and Kernel.
      pkgs = system:
        import inputs.nixpkgs {
          inherit system;
          crossSystem.system = "aarch64-linux";
          config.allowUnfree = true; # for arm-trusted-firmware
        };

      pkgs-unstable = system:
        import inputs.nixpkgs-unstable {
          inherit system;
          crossSystem.system = "aarch64-linux";
          config.allowUnfree = true; # for arm-trusted-firmware
        };

      uBoot = system:
        (pkgs-unstable system).callPackage ./pkgs/uboot-rockchip.nix { };
      kernel = system:
        (pkgs-unstable system).callPackage ./pkgs/linux-rockchip.nix { };

      boards = system: {
        "Radxa-5-ITX" = {
          uBoot = (uBoot system).uBootRadxa-5-ITX;
          kernel = (kernel system).linux_6_6_rockchip;
          extraModules = [ ];
        };
      };

      osConfigs = system:
        builtins.mapAttrs (name: value:
          inputs.nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";

            modules = [
              self.nixosModules.sdImageRockchipInstaller
              {
                system.stateVersion = "24.05";

                rockchip.uBoot = value.uBoot;
                boot.kernelPackages = value.kernel;
              }
              # Cross-compiling the whole system is hard, install from caches or compile with emulation instead.
              # { nixpkgs.crossSystem.system = "aarch64-linux"; nixpkgs.system = system;}
            ] ++ value.extraModules;
          }) (boards system);

      images = system:
        builtins.mapAttrs (name: value: value.config.system.build.sdImage)
        (osConfigs system);
    in {
      nixosModules = {
        sdImageRockchipInstaller =
          import ./modules/sd-card/sd-image-rockchip-installer.nix;
        sdImageRockchip = import ./modules/sd-card/sd-image-rockchip.nix;
      };
    } // inputs.flake-utils.lib.eachDefaultSystem (system: {
      legacyPackages = {
        kernel_linux_6_6_rockchip = (kernel system).linux_6_6_rockchip;
        kernel_linux_6_9_rockchip = (kernel system).linux_6_9_rockchip;
      };
      packages = (images system) // {
        uBootRadxa-5-ITX = (uBoot system).uBootRadxa-5-ITX;
      };
      formatter = (import inputs.nixpkgs { inherit system; }).alejandra;
    });
}
