{
  description = "A simple NixOS flake with Home Manager and Noctalia";

  inputs = {
    # NixOS 官方源
    nixpkgs.url = "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-26.05&shallow=1";

    # flatpak 支持
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    # Home Manager（必须）
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Noctalia（添加）
    # noctalia.url = "github:noctalia-dev/noctalia";   # 替换为实际仓库地址
    # 如果你使用 npins 或 tarball，也可以，但这里直接用 git
  };

  outputs = { self, nixpkgs, home-manager, nix-flatpak, vscode-server, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        nix-flatpak.nixosModules.nix-flatpak
        vscode-server.nixosModules.default
        # 你原有的配置
        ./configuration.nix
        ./modules/nixos/packages/desktop/kde.nix
        ./modules/nixos/packages/desktop/gnome.nix
        ./modules/nixos/packages/hardware/thinkpad.nix
        ./modules/nixos/packages/development/general.nix
        ./modules/nixos/packages/development/embedded.nix
        ./modules/nixos/services/flatpak.nix
        # Home Manager 模块（必须）
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ziyun = { config, pkgs, ... }: {
            imports = [ ./modules/home-manager/home.nix ];
         };
        }
      ];
    };
  };
}
