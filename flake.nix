{
  description = "ZiYyun NixOS configuration";

  inputs = {
    # Nixpkgs mirror.
    nixpkgs.url = "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-26.05&shallow=1";

    # System integration modules.
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Home Manager.
    home-manager.url = "github:nix-community/home-manager";
    # home-manager.url = "git+https://mirror.ghproxy.com/https://github.com/nix-community/home-manager.git";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Noctalia can be enabled later after the final source is selected.
    # noctalia.url = "github:noctalia-dev/noctalia";
    # noctalia.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, home-manager, nix-flatpak, vscode-server, nixos-hardware, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      homeManagerModule = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.ziyun = { ... }: {
          imports = [ ./modules/home-manager/home.nix ];
        };
      };

      commonModules = [
        /* Modules */
        home-manager.nixosModules.home-manager
        homeManagerModule
        vscode-server.nixosModules.default

        # inputs.noctalia.nixosModules.default

        ./configuration.nix

        ./modules/system/packages/hosts/installation-boot.nix
        # ./modules/system/packages/hosts/thinkpad.nix
        ./modules/system/packages/desktop/kde.nix
        ./modules/system/packages/desktop/gnome.nix
        # ./modules/system/packages/desktop/noctalia.nix
        ./modules/system/packages/development/default.nix
        ./modules/system/packages/development/general.nix
        ./modules/system/packages/development/embedded.nix
        ./modules/system/services/input-method.nix

      ];

      mkSystem = extraModules: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = commonModules ++ extraModules;
      };

      mkDevShell = path: import path { inherit pkgs; };
    in
    {
      nixosConfigurations.nixos = mkSystem [
        ./modules/system/packages/hosts/hardware-configuration.nix
        nix-flatpak.nixosModules.nix-flatpak
        ./modules/system/services/flatpak.nix
      ];

      # Use this when nix-flatpak blocks evaluation and you want to test the
      # rest of the configuration in a container-like build environment.
      nixosConfigurations.docker-test = mkSystem [
        ./modules/system/packages/hosts/docker.nix
      ];

      nixosConfigurations.ThinkPad-x270 = mkSystem [
        nix-flatpak.nixosModules.nix-flatpak
        ./modules/system/packages/hosts/ThinkPad-x270.nix
        ./modules/system/services/flatpak.nix
      ];

      nixosConfigurations.ThinkPad-x230i = mkSystem [
        nix-flatpak.nixosModules.nix-flatpak
        ./modules/system/packages/hosts/ThinkPad-x230i.nix
        ./modules/system/services/flatpak.nix
      ];

      nixosConfigurations.ThinkPad-P14s = mkSystem [
        nix-flatpak.nixosModules.nix-flatpak
        ./modules/system/packages/hosts/ThinkPad-P14s.nix
        ./modules/system/services/flatpak.nix
      ];

      devShells.${system} = {
        default = mkDevShell ./shells/targets/stm.nix;

        stm = mkDevShell ./shells/targets/stm.nix;
        esp = mkDevShell ./shells/targets/esp.nix;
        nordic = mkDevShell ./shells/targets/nordic.nix;

        arm32 = mkDevShell ./shells/targets/arm32.nix;
        arm64 = mkDevShell ./shells/targets/arm64.nix;
        allwinner = mkDevShell ./shells/targets/allwinner.nix;
        rockchip = mkDevShell ./shells/targets/rockchip.nix;
      };
    };
}
