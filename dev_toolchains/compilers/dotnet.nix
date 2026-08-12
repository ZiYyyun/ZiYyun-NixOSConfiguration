{ pkgs, ... }:
let
  compilerPackages = import ../libs/compiler-packages.nix { inherit pkgs; };
  mkCompilerShell = import ../libs/compiler-shell.nix;
in
mkCompilerShell {
  inherit pkgs;
  name = "dotnet";
  packages = compilerPackages.dotnet;
  env = {
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
  };
  tools = [ "dotnet SDK" "csharp-ls" ];
  versionCommands = [
    { name = "dotnet"; bin = "dotnet"; command = "dotnet --version"; }
  ];
  message = ".NET shell: dotnet SDK and csharp-ls language server.";
}
