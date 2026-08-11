{
  description = "ZiYyun NixOS configuration";

  inputs = {
    # Nixpkgs mirror.
    nixpkgs.url = "https://mirrors.ustc.edu.cn/nix-channels/nixos-26.05/nixexprs.tar.xz";

    # System integration modules.
    flake-parts.url = "git+https://gh.llkk.cc/https://github.com/hercules-ci/flake-parts.git";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    nixpkgs-lib.url = "git+https://gh.llkk.cc/https://github.com/nix-community/nixpkgs.lib.git";
    systems.url = "git+https://gh.llkk.cc/https://github.com/nix-systems/default.git";
    nix-flatpak.url = "git+https://gh.llkk.cc/https://github.com/gmodena/nix-flatpak.git?ref=latest";
    vscode-server.url = "git+https://gh.llkk.cc/https://github.com/nix-community/nixos-vscode-server.git";
    vscode-server.inputs.flake-parts.follows = "flake-parts";
    nixos-hardware.url = "git+https://gh.llkk.cc/https://github.com/NixOS/nixos-hardware.git?ref=master";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";
    noctalia.url = "git+https://gh.llkk.cc/https://github.com/noctalia-dev/noctalia.git";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";

    # Home Manager.
    home-manager.url = "git+https://gh.llkk.cc/https://github.com/nix-community/home-manager.git?ref=release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "git+https://gh.llkk.cc/https://github.com/nix-community/nixvim.git?ref=nixos-26.05";
    nixvim.inputs.flake-parts.follows = "flake-parts";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.inputs.systems.follows = "systems";
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
