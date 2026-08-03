{
  description = "ZiYyun NixOS configuration";

  inputs = {
    # Nixpkgs mirror.
    nixpkgs.url = "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-26.05&shallow=1";

    # System integration modules.
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    # Home Manager.
    home-manager.url = "github:nix-community/home-manager/release-26.05";
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
        home-manager.users.ziyun = { pkgs, ... }: {
          imports = [
            ./modules/home-manager/home.nix
            vscode-server.homeModules.default
          ];

          services.vscode-server = {
            enable = true;
            enableFHS = true;
            nodejsPackage = pkgs.nodejs;
          };
        };
      };

      commonModules = [
        /* Modules */
        home-manager.nixosModules.home-manager
        homeManagerModule

        # inputs.noctalia.nixosModules.default

        ./configuration.nix

        ./hosts/common/installation-boot.nix
        ./modules/system

      ];

      mkSystem = extraModules: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = commonModules ++ extraModules;
      };

      mkDevShell = path: import path { inherit pkgs; };
    in
    {
      nixosConfigurations.kde-default = mkSystem [
        ./hosts/kde-default
      ];

      nixosConfigurations.gnome-default = mkSystem [
        ./hosts/gnome-default
      ];

      # Use this when nix-flatpak blocks evaluation and you want to test the
      # rest of the configuration in a container-like build environment.
      nixosConfigurations.docker-test = mkSystem [
        ./hosts/docker-test
      ];

      nixosConfigurations.ThinkPad-x270 = mkSystem [
        ./hosts/ThinkPad-x270
      ];

      nixosConfigurations.ThinkPad-x230i = mkSystem [
        ./hosts/ThinkPad-x230i
      ];

      nixosConfigurations.ThinkPad-P14s = mkSystem [
        ./hosts/ThinkPad-P14s
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
