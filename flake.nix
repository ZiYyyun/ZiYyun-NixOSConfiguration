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
    noctalia.url = "git+https://github.com/noctalia-dev/noctalia.git";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";

    # Home Manager.
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    # home-manager.url = "git+https://mirror.ghproxy.com/https://github.com/nix-community/home-manager.git";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "git+https://github.com/nix-community/nixvim.git?ref=nixos-26.05";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
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
        home-manager.backupFileExtension = "hm-backup";
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.ziyun = { ... }: {
          imports = [
            vscode-server.homeModules.default
            inputs.nixvim.homeModules.nixvim
            ./modules/home
            ./packages/home
          ];
        };
      };

      commonModules = [
        /* Modules */
        home-manager.nixosModules.home-manager
        homeManagerModule

        inputs.noctalia.nixosModules.default

        ./configuration.nix

        ./hosts/common/installation-boot.nix
        ./modules/system
        ./packages/system

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

      nixosConfigurations.niri-default = mkSystem [
        ./hosts/niri-default
      ];

      nixosConfigurations.gnome-default = mkSystem [
        ./hosts/gnome-default
      ];

      nixosConfigurations.desktop-default = mkSystem [
        ./hosts/desktop-default
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
        default = mkDevShell ./dev_toolchains/dev_compliers/dev_cmp_c-cpp.nix;

        c = mkDevShell ./dev_toolchains/dev_compliers/dev_cmp_c-cpp.nix;
        cpp = mkDevShell ./dev_toolchains/dev_compliers/dev_cmp_c-cpp.nix;
        c-cpp = mkDevShell ./dev_toolchains/dev_compliers/dev_cmp_c-cpp.nix;
        rust = mkDevShell ./dev_toolchains/dev_compliers/dev_cmp_rust.nix;
        python = mkDevShell ./dev_toolchains/dev_compliers/dev_cmp_python.nix;
        node = mkDevShell ./dev_toolchains/dev_compliers/dev_cmp_node.nix;
        go = mkDevShell ./dev_toolchains/dev_compliers/dev_cmp_go.nix;
        java = mkDevShell ./dev_toolchains/dev_compliers/dev_cmp_java.nix;
        dotnet = mkDevShell ./dev_toolchains/dev_compliers/dev_cmp_dotnet.nix;

        stm = mkDevShell ./dev_toolchains/dev_embedded/dev_emb_stm.nix;
        esp = mkDevShell ./dev_toolchains/dev_embedded/dev_emb_esp.nix;
        nordic = mkDevShell ./dev_toolchains/dev_embedded/dev_emb_nordic.nix;

        arm32 = mkDevShell ./dev_toolchains/dev_embedded/dev_emb_arm32.nix;
        arm64 = mkDevShell ./dev_toolchains/dev_embedded/dev_emb_arm64.nix;
        allwinner = mkDevShell ./dev_toolchains/dev_embedded/dev_emb_allwinner.nix;
        rockchip = mkDevShell ./dev_toolchains/dev_embedded/dev_emb_rockchip.nix;
      };
    };
}
