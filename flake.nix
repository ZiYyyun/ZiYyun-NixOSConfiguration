{
  description = "ZiYyun NixOS configuration";

  inputs = {
    # Nixpkgs mirror.
    nixpkgs.url = "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-26.05&shallow=1";

    # System integration modules.
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    vscode-server.url = "github:nix-community/nixos-vscode-server";

    # Home Manager.
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Noctalia can be enabled later after the final source is selected.
    # noctalia.url = "github:noctalia-dev/noctalia";
  };

  outputs = { nixpkgs, home-manager, nix-flatpak, vscode-server, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        nix-flatpak.nixosModules.nix-flatpak
        vscode-server.nixosModules.default

        ./configuration.nix
        ./hardware/installation-boot.nix
        ./modules/system/packages/desktop/kde.nix
        ./modules/system/packages/desktop/gnome.nix
        ./modules/system/packages/hardware/thinkpad.nix
        ./modules/system/packages/development/general.nix
        ./modules/system/packages/development/embedded.nix
        ./modules/system/services/flatpak.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ziyun = { ... }: {
            imports = [ ./modules/home-manager/home.nix ];
          };
        }
      ];
    };
  };
}
