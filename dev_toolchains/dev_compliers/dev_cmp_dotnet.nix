{ pkgs, ... }:
let
  devCmpPackages = import ../libs/libs_cmp_packages.nix { inherit pkgs; };
  mkDevCmpShell = import ../libs/libs_cmp_shell.nix;
in
mkDevCmpShell {
  inherit pkgs;
  name = "dotnet";
  packages = devCmpPackages.dotnet;
  env = {
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
  };
  tools = [ "dotnet SDK" "csharp-ls" ];
  versionCommands = [
    { name = "dotnet"; bin = "dotnet"; command = "dotnet --version"; }
  ];
  message = ".NET shell: dotnet SDK and csharp-ls language server.";
}
