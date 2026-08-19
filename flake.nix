{
  description = "ZiYyun NixOS configuration";

  inputs = {
    # Keep nixpkgs pinned by Git revision. Do not use channel tarballs here:
    # mirror tarballs can be re-packed and then fail narHash verification during
    # installation.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Unstable channel for packages that haven't been backported to the stable
    # branch yet (e.g. cc-switch). Exposed to modules as the `unstable` argument.
    # Pinned to a specific revision via a GitHub proxy because github.com is
    # unreachable from this network. To bump it, replace the rev below with the
    # current `nixos-unstable` HEAD (see `git ls-remote` on the proxy).
    nixpkgs-unstable.url = "https://ghfast.top/https://github.com/NixOS/nixpkgs/archive/e5bdc4a41d4c072fe1e3787eaa0320a384741d44.tar.gz";

    # System integration modules.
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    systems.url = "github:nix-systems/default";
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.flake-parts.follows = "flake-parts";
    nixos-hardware.url = "github:NixOS/nixos-hardware?ref=master";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";
    noctalia.url = "github:noctalia-dev/noctalia";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";

    # Home Manager.
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:nix-community/nixvim/nixos-26.05";
    nixvim.inputs.flake-parts.follows = "flake-parts";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.inputs.systems.follows = "systems";

    # ESP-IDF development (VSCode + idf.py). github.com is unreachable from
    # this network, so inputs are pinned via the ghfast.top proxy like
    # nixpkgs-unstable. esp-dev is written against nixpkgs 25.11 (needs
    # python310, which 26.05 dropped), so it gets its own nixpkgs-esp input
    # instead of following our 26.05. To bump, replace the revs with current
    # HEADs of:
    #   github:mirrexagon/nixpkgs-esp-dev
    #   github:numtide/flake-utils
    #   NixOS/nixpkgs branch nixos-25.11
    nixpkgs-esp.url = "https://ghfast.top/https://github.com/NixOS/nixpkgs/archive/b6018f87da91d19d0ab4cf979885689b469cdd41.tar.gz";
    nixpkgs-esp-dev.url = "https://ghfast.top/https://github.com/mirrexagon/nixpkgs-esp-dev/archive/5287d6e1ca9e15ebd5113c41b9590c468e1e001b.tar.gz";
    nixpkgs-esp-dev.inputs.nixpkgs.follows = "nixpkgs-esp";
    nixpkgs-esp-dev.inputs.flake-utils.follows = "flake-utils";
    flake-utils.url = "https://ghfast.top/https://github.com/numtide/flake-utils/archive/11707dc2f618dd54ca8739b309ec4fc024de578b.tar.gz";
  };

  outputs =
    { nixpkgs, nixpkgs-unstable, nixpkgs-esp, nixpkgs-esp-dev, home-manager, nix-flatpak, vscode-server, nixos-hardware, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      homeManagerModule = {
        home-manager.backupFileExtension = "hm-backup";
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit unstable; };
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
        specialArgs = { inherit inputs unstable; };
        modules = commonModules ++ extraModules;
      };

      mkDevShell = path: import path { inherit pkgs unstable; };

      # ===== ESP32 unified shell =====
      # esp-idf-full (framework + all toolchains, from mirrexagon/nixpkgs-esp-dev)
      # merged with the flashing/serial tools of the old `esp` shell.
      # Built against nixpkgs 25.11 (nixpkgs-esp): esp-dev needs python310,
      # which 26.05 dropped; its own ecdsa 0.19.1 whitelist matches 25.11 too.
      espPkgs = import nixpkgs-esp {
        inherit system;
        overlays = [ inputs.nixpkgs-esp-dev.overlays.default ];
        config.permittedInsecurePackages = [
          "python3.13-ecdsa-0.19.1"
        ];
      };
      espTools = (import ./dev_toolchains/libs/embedded-packages.nix { pkgs = espPkgs; }).esp;
      espShell = espPkgs.mkShell {
        name = "esp";
        packages = with espPkgs; [
          esp-idf-full
        ] ++ espTools;
        shellHook = ''
          echo "ESP unified shell: esp-idf ${espPkgs.esp-idf-full.version} + esptool/espflash/platformio + serial/flash tools"
          echo "  idf.py (framework)   esptool / espflash / platformio (flashing)"
        '';
      };
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
        default = mkDevShell ./dev_toolchains/compilers/c-cpp.nix;

        c = mkDevShell ./dev_toolchains/compilers/c-cpp.nix;
        cpp = mkDevShell ./dev_toolchains/compilers/c-cpp.nix;
        c-cpp = mkDevShell ./dev_toolchains/compilers/c-cpp.nix;
        rust = mkDevShell ./dev_toolchains/compilers/rust.nix;
        python = mkDevShell ./dev_toolchains/compilers/python.nix;
        node = mkDevShell ./dev_toolchains/compilers/node.nix;
        go = mkDevShell ./dev_toolchains/compilers/go.nix;
        java = mkDevShell ./dev_toolchains/compilers/java.nix;
        dotnet = mkDevShell ./dev_toolchains/compilers/dotnet.nix;

        stm = mkDevShell ./dev_toolchains/embedded/stm.nix;
        # Unified ESP32 shell: ESP-IDF + flashing/serial tools (see let above).
        esp = espShell;
        # Backwards-compatible alias for the same shell.
        esp-idf = espShell;
        nordic = mkDevShell ./dev_toolchains/embedded/nordic.nix;
        segger = mkDevShell ./dev_toolchains/embedded/segger.nix;

        arm32 = mkDevShell ./dev_toolchains/embedded/arm32.nix;
        arm64 = mkDevShell ./dev_toolchains/embedded/arm64.nix;
        allwinner = mkDevShell ./dev_toolchains/embedded/allwinner.nix;
        rockchip = mkDevShell ./dev_toolchains/embedded/rockchip.nix;
      };
    };
}
