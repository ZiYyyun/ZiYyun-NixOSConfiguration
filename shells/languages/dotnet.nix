{ pkgs, ... }:
let
  mkLanguageShell = import ../lib/mk-language-shell.nix;
in
mkLanguageShell {
  inherit pkgs;
  name = "dotnet";
  packages = with pkgs; [
    dotnet-sdk
    csharp-ls
  ];
  env = {
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
  };
  message = ".NET shell: dotnet SDK and csharp-ls language server.";
}
